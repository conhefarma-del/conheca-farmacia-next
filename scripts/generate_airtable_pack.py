#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Gera o pack CSV para o Airtable (base de pesquisa) a partir das migrações SQL.

Fonte única de verdade: os ficheiros em supabase/migrations/. O script faz um
REPLAY de todas as migrações em ordem de ficheiro (a numeração pode ter saltos
— 062, 065, ... — e nunca é assumida uma sequência rígida):

  - INSERT INTO public.drugs            -> cria fármaco (por slug)
  - INSERT INTO public.drug_interactions-> cria par (por par de slugs)
  - UPDATE public.drug_interactions     -> altera os campos indicados
  - INSERT nas 3 novas dimensões        -> cria alimento/doença/gravidez
    (padrão JOIN (VALUES ...) AS v(...))

Semântica igual ao Postgres: INSERT cria apenas se a chave não existe
(ON CONFLICT DO NOTHING); UPDATE altera no lugar. Ficheiros novos (062, 065)
são descobertos automaticamente — não é preciso editar listas de números.

Uso:
    python scripts/generate_airtable_pack.py

Saída: _temp/airtable-pack/<tabela>.csv (regeneração completa e idempotente).
"""
import csv
import hashlib
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MIGRATIONS_DIR = os.path.join(ROOT, 'supabase', 'migrations')
OUT_DIR = os.path.join(ROOT, '_temp', 'airtable-pack')

NEW_DIM_TABLES = ['drug_food_interactions', 'drug_disease_interactions',
                  'drug_pregnancy_info']

# Mapeamento coluna SQL (drug_interactions) -> campo do pack
COL_TO_PACK = {
    'severity': 'severidade',
    'summary_pt': 'resumo_pt', 'summary_en': 'resumo_en',
    'summary_pro_pt': 'resumo_pro_pt', 'summary_pro_en': 'resumo_pro_en',
    'explanation_pt': 'explicacao_pt', 'explanation_en': 'explicacao_en',
    'mechanism_pt': 'mecanismo_pt', 'mechanism_en': 'mecanismo_en',
    'management_pt': 'conselho_pt', 'management_en': 'conselho_en',
    'monitoring_pt': 'monitorizacao_pt', 'monitoring_en': 'monitorizacao_en',
    'red_flags_pt': 'red_flags_pt', 'red_flags_en': 'red_flags_en',
    'source_pt': 'fonte_pt', 'source_en': 'fonte_en',
}
ASSIGN_RE = re.compile(r"([a-z_]+)\s*=\s*('(?:[^']|'')*'|now\(\)|NULL)", re.I)


# ---------------------------------------------------------------- scanner SQL
def read_file(name):
    with open(os.path.join(MIGRATIONS_DIR, name), encoding='utf-8') as fh:
        return fh.read()


def skip_ws(text, i):
    """Avança por espaços e comentários SQL (-- e /* */)."""
    n = len(text)
    while i < n:
        c = text[i]
        if c in ' \t\r\n':
            i += 1
        elif text.startswith('--', i):
            j = text.find('\n', i)
            i = n if j == -1 else j + 1
        elif text.startswith('/*', i):
            j = text.find('*/', i)
            i = n if j == -1 else j + 2
        else:
            break
    return i


def read_balanced(text, i):
    """Lê um grupo (...). Devolve (conteúdo interno, índice após o ')' final)."""
    assert text[i] == '('
    depth = 0
    quote = None
    j = i
    n = len(text)
    while j < n:
        c = text[j]
        if quote:
            if c == quote:
                if quote == "'" and j + 1 < n and text[j + 1] == "'":
                    j += 2
                    continue
                quote = None
            j += 1
            continue
        if c in ("'", '"'):
            quote = c
        elif c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
            if depth == 0:
                return text[i + 1:j], j + 1
        j += 1
    raise ValueError('parêntesis não fechado a partir de %d' % i)


def split_top(text):
    """Divide por vírgulas ao nível zero, respeitando aspas e parêntesis."""
    parts = []
    depth = 0
    start = 0
    quote = None
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if quote:
            if c == quote:
                if quote == "'" and i + 1 < n and text[i + 1] == "'":
                    i += 2
                    continue
                quote = None
            i += 1
            continue
        if c in ("'", '"'):
            quote = c
        elif c == '(':
            depth += 1
        elif c == ')':
            depth -= 1
        elif c == ',' and depth == 0:
            parts.append(text[start:i].strip())
            start = i + 1
        i += 1
    parts.append(text[start:].strip())
    return parts


def unquote(s):
    """Remove aspas simples SQL, resolvendo '' -> '.
    Suporta também strings E'...' do Postgres (\n -> quebra de linha real)."""
    s = s.strip()
    if len(s) >= 3 and s[0] == 'E' and s[1] == "'" and s[-1] == "'":
        body = s[2:-1].replace("''", "'")
        body = body.replace('\\\\', '\\')
        body = body.replace('\\n', '\n')
        return body
    if len(s) >= 2 and s[0] == "'" and s[-1] == "'":
        return s[1:-1].replace("''", "'")
    return None


def parse_array(tok):
    """ARRAY['a','b'] ou '{}' -> lista de strings; caso contrário None."""
    tok = tok.strip()
    s = unquote(tok)
    if s == '{}':
        return []
    if tok.startswith('ARRAY[') and tok.endswith(']'):
        out = []
        for part in split_top(tok[len('ARRAY['):-1]):
            v = unquote(part)
            out.append(v if v is not None else part.strip())
        return out
    return None


def parse_inserts(text, table):
    """INSERT INTO <table> (cols) VALUES ... -> lista de (columns, rows);
    cada row é dict coluna -> token cru. Só forms com VALUES."""
    out = []
    pattern = r'INSERT\s+INTO\s+public\.' + re.escape(table) + r'\s*\('
    for m in re.finditer(pattern, text, re.IGNORECASE):
        cols_inner, i = read_balanced(text, m.end() - 1)
        columns = [c.strip() for c in split_top(cols_inner)]
        i = skip_ws(text, i)
        if not text.startswith('VALUES', i):
            continue  # e.g. INSERT ... SELECT (novas dimensões -> parse_new_dim_blocks)
        i = skip_ws(text, i + len('VALUES'))
        rows = []
        while True:
            i = skip_ws(text, i)
            if i >= len(text) or text[i] != '(':
                break
            inner, i = read_balanced(text, i)
            tokens = split_top(inner)
            rows.append(dict(zip(columns, tokens)))
            i = skip_ws(text, i)
            if i < len(text) and text[i] == ',':
                i += 1
                continue
            break
        out.append((columns, rows))
    return out


SLUG_SUBQ_RE = re.compile(
    r"SELECT\s+id\s+FROM\s+public\.drugs\s+WHERE\s+slug\s*=\s*'([^']+)'")
VAR_SELECT_RE = re.compile(
    r"SELECT\s+id\s+INTO\s+(v_\w+)\s+FROM\s+public\.drugs\s+WHERE\s+slug\s*=\s*'([^']+)'")


def pair_slugs(token, var_map):
    """Extrai os dois slugs de um token LEAST(...)/GREATEST(...)."""
    subs = SLUG_SUBQ_RE.findall(token)
    if len(subs) == 2:
        return subs
    vars_found = re.findall(r'\b(v_\w+)', token)
    if len(vars_found) == 2:
        return var_map[vars_found[0]], var_map[vars_found[1]]
    raise ValueError('não consegui extrair o par de: %s' % token[:100])


# Nos pares INSERT ... SELECT, a severidade vem OU como coluna v.severity OU
# como literal na lista SELECT (variante 062: ... GREATEST(..), 'moderate',
# v.summary_pt ...). Captura o literal, quando existir.
SELECT_SEVERITY_RE = re.compile(
    r"SELECT\s+LEAST\(a\.id,\s*b\.id\)\s*,\s*GREATEST\(a\.id,\s*b\.id\)\s*,\s*"
    r"'([^']+)'")


def select_severity_literal(text):
    m = SELECT_SEVERITY_RE.search(text)
    return m.group(1) if m else None


def statement_end(s, start=0):
    """Índice do primeiro ';' fora de literais de string (as citações têm ';')."""
    quote = None
    i = start
    n = len(s)
    while i < n:
        c = s[i]
        if quote:
            if c == quote:
                if quote == "'" and i + 1 < n and s[i + 1] == "'":
                    i += 2
                    continue
                quote = None
            i += 1
            continue
        if c == "'":
            quote = "'"
        elif c == ';':
            return i
        i += 1
    return n


def parse_join_values(text):
    """Padrão (JOIN|FROM) (VALUES (t1),(t2)) AS v(c1, c2, ...).
    Devolve lista de (v_cols, [tuplas de tokens]) — uma por bloco
    (VALUES ...) AS v(...). Comentários SQL entre tuplos são ignorados.

    Caso `FROM (VALUES` (pares fármaco-fármaco nas migrações 062+): o bloco
    chega no `SELECT ... FROM (VALUES ...) AS v(slug_a, slug_b, ...)`."""
    blocks = []
    for m in re.finditer(r'(?:JOIN|FROM)\s*\(VALUES', text):
        outer_open = m.end() - len('VALUES') - 1  # '(' imediatamente antes de VALUES
        i = skip_ws(text, outer_open + len('VALUES') + 1)  # depois de '(VALUES'
        tuples = []
        while True:
            i = skip_ws(text, i)
            if i >= len(text) or text[i] != '(':
                break
            inner, i = read_balanced(text, i)
            tuples.append(split_top(inner))
            i = skip_ws(text, i)
            if i < len(text) and text[i] == ',':
                i += 1
                continue
            break
        i = skip_ws(text, i)
        if i < len(text) and text[i] == ')':  # fecha o grupo (VALUES ...)
            i = skip_ws(text, i + 1)
        m2 = re.match(r'AS\s+v\s*\(', text[i:])
        if not m2:
            continue
        vcols_inner, _ = read_balanced(text, i + m2.end() - 1)
        v_cols = [c.strip() for c in split_top(vcols_inner)]
        blocks.append((v_cols, tuples))
    return blocks


PAIR_AB_SLUG_RE = re.compile(r"\b([ab])\.slug\s*=\s*'([^']+)'")


def parse_insert_select_pairs(text):
    """Padrão 083/085/094: INSERT INTO drug_interactions (cols)
    SELECT LEAST(a.id, b.id), GREATEST(a.id, b.id), 'severity', 'summary_pt', …
    FROM public.drugs a, public.drugs b WHERE a.slug='x' AND b.slug='y' …;
    Devolve lista de dicts {'columns', 'values', 'a', 'b'} (valores raw)."""
    out = []
    pattern = r'INSERT\s+INTO\s+public\.drug_interactions\s*\('
    for m in re.finditer(pattern, text, re.IGNORECASE):
        cols_inner, i = read_balanced(text, m.end() - 1)
        columns = [c.strip() for c in split_top(cols_inner)]
        i = skip_ws(text, i)
        if not text.startswith('SELECT', i):
            continue  # VALUES (já tratado) ou outros
        fm = re.search(r'\bFROM\s+public\.drugs\s+[ab]\s*,\s*public\.drugs\s+[ab]\b',
                       text[i:])
        if not fm:
            continue
        tokens = split_top(text[i + len('SELECT'):i + fm.start()])
        stmt_end = statement_end(text, m.start())
        slugs = dict(PAIR_AB_SLUG_RE.findall(text[m.start():stmt_end]))
        if len(slugs) != 2 or 'a' not in slugs or 'b' not in slugs:
            continue
        values = {}
        for col, tok in zip(columns[2:], tokens[2:]):
            values[col] = tok
        out.append({'columns': columns, 'values': values,
                    'a': slugs['a'], 'b': slugs['b']})
    return out


def parse_new_dim_blocks(text, table):
    """Blocos JOIN (VALUES ...) dentro do statement INSERT INTO <table> ...;"""
    blocks = []
    pattern = r'INSERT\s+INTO\s+public\.' + re.escape(table) + r'\b'
    for m in re.finditer(pattern, text, re.IGNORECASE):
        end = statement_end(text, m.start())
        blocks.extend(parse_join_values(text[m.start():end]))
    return blocks


# ------------------------------------------------------------- mapeamento CSV
FARMACOS_HEADERS = ['slug', 'nome_generico_pt', 'nome_generico_en', 'marcas',
                    'classe_pt', 'classe_en', 'atc', 'estado']
FONTES_HEADERS = ['slug', 'publicacao', 'titulo', 'url', 'acessado_em',
                  'dominio_publico', 'notas']
FF_HEADERS = ['slug', 'farmaco_a_slug', 'farmaco_b_slug', 'severidade',
              'resumo_pt', 'resumo_en', 'resumo_pro_pt', 'resumo_pro_en',
              'explicacao_pt', 'explicacao_en', 'mecanismo_pt', 'mecanismo_en',
              'conselho_pt', 'conselho_en', 'monitorizacao_pt', 'monitorizacao_en',
              'red_flags_pt', 'red_flags_en', 'fonte_pt', 'fonte_en', 'estado',
              'data_revisao']

# 8.ª tabela: perfil editorial + farmacologia, 1:1 com Fármacos (farmaco_slug).
PERFIL_HEADERS = ['slug', 'farmaco_slug',
                  'perfil_publico_pt', 'perfil_publico_en',
                  'perfil_pro_pt', 'perfil_pro_en',
                  'indicacoes_pt', 'indicacoes_en',
                  'efeitos_secundarios_pt', 'efeitos_secundarios_en',
                  'precaucoes_pt', 'precaucoes_en',
                  'farmacodinamica_pt', 'farmacodinamica_en',
                  'mecanismo_acao_pt', 'mecanismo_acao_en',
                  'metabolismo_pt', 'metabolismo_en',
                  'absorcao_pt', 'absorcao_en',
                  'meia_vida_pt', 'meia_vida_en',
                  'fonte_perfil_pt', 'fonte_perfil_en',
                  'fonte_farmacologia_pt', 'fonte_farmacologia_en',
                  'estado']
ALIMENTO_HEADERS = ['slug', 'farmaco_slug', 'entidade_slug', 'entidade_pt',
                    'entidade_en', 'severidade', 'mecanismo_pt', 'mecanismo_en',
                    'conselho_pt', 'conselho_en', 'fonte_pt', 'fonte_en', 'estado']
DOENCAS_HEADERS = ['slug', 'nome_pt', 'nome_en']
DOENCA_HEADERS = ['slug', 'farmaco_slug', 'doenca_slug', 'tipo_interacao',
                  'severidade', 'motivo_pt', 'motivo_en', 'conselho_pt', 'conselho_en',
                  'fonte_pt', 'fonte_en', 'estado']
GRAVIDEZ_HEADERS = ['slug', 'farmaco_slug', 'pregnancy_category', 'risk_pt',
                    'risk_en', 'trimester_pt', 'trimester_en', 'lactation_pt',
                    'lactation_en', 'contraception_pt', 'contraception_en',
                    'fonte_pt', 'fonte_en', 'estado']


def estado(status):
    return 'publicado' if (status or 'published') == 'published' else 'rascunho'


def s(row, key):
    """Valor de string de um token SQL (vazio se ausente/inalterado)."""
    tok = row.get(key)
    v = unquote(tok) if tok else ''
    return v or ''


def write_csv(fname, headers, rows):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, fname)
    with open(path, 'w', encoding='utf-8-sig', newline='') as fh:
        writer = csv.writer(fh)
        writer.writerow(headers)
        for row in rows:
            writer.writerow([row.get(h, '') for h in headers])
    return len(rows)


def main():
    # Estado reconstruído por replay das migrações em ordem de ficheiro.
    drug_rows = {}
    pairs = {}
    food, disease, preg = {}, {}, {}
    cond_names = {}
    # 8.ª tabela: perfil editorial + farmacologia (1:1 com drugs) e códigos ATC.
    profiles = {}
    atc_map = {}

    files = sorted(f for f in os.listdir(MIGRATIONS_DIR) if f.endswith('.sql'))
    for fname in files:
        text = read_file(fname)
        var_map = {m.group(1): m.group(2) for m in VAR_SELECT_RE.finditer(text)}

        # --- Fármacos (INSERT cria por slug; UNIQUE + DO NOTHING) ---
        for _cols, rows in parse_inserts(text, 'drugs'):
            for row in rows:
                slug = s(row, 'slug')
                if slug and slug not in drug_rows:
                    aliases = parse_array(row.get('aliases') or '') or []
                    drug_rows[slug] = {
                        'slug': slug,
                        'nome_generico_pt': s(row, 'name_pt'),
                        'nome_generico_en': s(row, 'name_en'),
                        'marcas': '; '.join(aliases),
                        'classe_pt': s(row, 'class_pt'),
                        'classe_en': s(row, 'class_en'),
                        'atc': '',
                        'estado': estado(s(row, 'status')),
                    }

        # --- Pares fármaco-fármaco (INSERT cria; UPDATE altera) ---
        for _cols, rows in parse_inserts(text, 'drug_interactions'):
            for row in rows:
                a, b = pair_slugs(row['drug_a_id'], var_map)
                key = tuple(sorted([a, b]))
                if key in pairs:
                    continue
                pairs[key] = {
                    'a': key[0], 'b': key[1],
                    'severidade': s(row, 'severity'),
                    'resumo_pt': s(row, 'summary_pt'), 'resumo_en': s(row, 'summary_en'),
                    'resumo_pro_pt': s(row, 'summary_pro_pt'),
                    'resumo_pro_en': s(row, 'summary_pro_en'),
                    'explicacao_pt': s(row, 'explanation_pt'),
                    'explicacao_en': s(row, 'explanation_en'),
                    'mecanismo_pt': s(row, 'mechanism_pt'), 'mecanismo_en': s(row, 'mechanism_en'),
                    'conselho_pt': s(row, 'management_pt'), 'conselho_en': s(row, 'management_en'),
                    'monitorizacao_pt': s(row, 'monitoring_pt'),
                    'monitorizacao_en': s(row, 'monitoring_en'),
                    'red_flags_pt': s(row, 'red_flags_pt'), 'red_flags_en': s(row, 'red_flags_en'),
                    'fonte_pt': s(row, 'source_pt'), 'fonte_en': s(row, 'source_en'),
                    'estado': estado(s(row, 'status')),
                    'data_revisao': s(row, 'updated_at')[:10],
                }

        # Pares no estilo 062+: INSERT INTO drug_interactions (...) SELECT ...
        # FROM (VALUES ...) AS v(slug_a, slug_b, [severity,] ...) JOIN drugs ...
        # (o parser de VALUES acima não apanha este padrão SELECT/FROM).
        for v_cols, tuples in parse_new_dim_blocks(text, 'drug_interactions'):
            try:
                ia = v_cols.index('slug_a')
                ib = v_cols.index('slug_b')
            except ValueError:
                continue
            sev_col = v_cols.index('severity') if 'severity' in v_cols else None
            sev_lit = select_severity_literal(text)
            for t in tuples:
                if len(t) != len(v_cols):
                    continue
                a = unquote(t[ia])
                b = unquote(t[ib])
                if not a or not b:
                    continue
                key = tuple(sorted([a, b]))
                if key in pairs:
                    continue
                if sev_col is not None:
                    sev = s(dict(zip(v_cols, t)), 'severity')
                elif sev_lit:
                    sev = sev_lit
                else:
                    sev = ''
                r = dict(zip(v_cols, t))
                pairs[key] = {
                    'a': key[0], 'b': key[1],
                    'severidade': sev,
                    'resumo_pt': s(r, 'summary_pt'), 'resumo_en': s(r, 'summary_en'),
                    'resumo_pro_pt': s(r, 'summary_pro_pt'),
                    'resumo_pro_en': s(r, 'summary_pro_en'),
                    'explicacao_pt': s(r, 'explanation_pt'),
                    'explicacao_en': s(r, 'explanation_en'),
                    'mecanismo_pt': s(r, 'mechanism_pt'), 'mecanismo_en': s(r, 'mechanism_en'),
                    'conselho_pt': s(r, 'management_pt'), 'conselho_en': s(r, 'management_en'),
                    'monitorizacao_pt': s(r, 'monitoring_pt'),
                    'monitorizacao_en': s(r, 'monitoring_en'),
                    'red_flags_pt': s(r, 'red_flags_pt'), 'red_flags_en': s(r, 'red_flags_en'),
                    'fonte_pt': s(r, 'source_pt'), 'fonte_en': s(r, 'source_en'),
                    'estado': estado(s(r, 'status')),
                    'data_revisao': s(r, 'updated_at')[:10],
                }

        # UPDATEs de drug_interactions: aplicam apenas os campos indicados.
        for body in text.split('UPDATE public.drug_interactions')[1:]:
            stmt = body[:statement_end(body)]
            slugs = sorted(set(SLUG_SUBQ_RE.findall(stmt)))
            if len(slugs) != 2:
                continue
            key = tuple(sorted(slugs))
            if key not in pairs:
                continue
            for m in ASSIGN_RE.finditer(stmt):
                pack_key = COL_TO_PACK.get(m.group(1).lower())
                if pack_key:
                    raw = m.group(2)
                    pairs[key][pack_key] = unquote(raw) if raw.startswith("'") else ''

        # --- Novas dimensões (JOIN (VALUES ...) AS v(...); estado='published') ---
        for table in NEW_DIM_TABLES:
            for v_cols, tuples in parse_new_dim_blocks(text, table):
                for t in tuples:
                    if len(t) != len(v_cols):
                        continue
                    r = dict(zip(v_cols, t))
                    drug = s(r, 'slug')
                    if not drug:
                        continue
                    if table == 'drug_food_interactions':
                        ent = s(r, 'entity_slug')
                        if (drug, ent) not in food:
                            food[(drug, ent)] = {
                                'slug': '%s_%s' % (drug, ent),
                                'farmaco_slug': drug,
                                'entidade_slug': ent,
                                'entidade_pt': s(r, 'entity_pt'),
                                'entidade_en': s(r, 'entity_en'),
                                'severidade': s(r, 'severity'),
                                'mecanismo_pt': s(r, 'mechanism_pt'),
                                'mecanismo_en': s(r, 'mechanism_en'),
                                'conselho_pt': s(r, 'advice_pt'),
                                'conselho_en': s(r, 'advice_en'),
                                'fonte_pt': s(r, 'source_pt'),
                                'fonte_en': s(r, 'source_en'),
                                'estado': 'publicado',
                            }
                    elif table == 'drug_disease_interactions':
                        cond = s(r, 'condition_slug')
                        if cond and cond not in cond_names:
                            cond_names[cond] = {'slug': cond,
                                                'nome_pt': s(r, 'condition_pt'),
                                                'nome_en': s(r, 'condition_en')}
                        if (drug, cond) not in disease:
                            disease[(drug, cond)] = {
                                'slug': '%s_%s' % (drug, cond),
                                'farmaco_slug': drug,
                                'doenca_slug': cond,
                                'tipo_interacao': s(r, 'interaction_type'),
                                'severidade': s(r, 'severity'),
                                'motivo_pt': s(r, 'reason_pt'),
                                'motivo_en': s(r, 'reason_en'),
                                'conselho_pt': s(r, 'advice_pt'),
                                'conselho_en': s(r, 'advice_en'),
                                'fonte_pt': s(r, 'source_pt'),
                                'fonte_en': s(r, 'source_en'),
                                'estado': 'publicado',
                            }
                    elif drug not in preg:
                        preg[drug] = {
                            'slug': '%s_gravidez' % drug,
                            'farmaco_slug': drug,
                            'pregnancy_category': s(r, 'pregnancy_category'),
                            'risk_pt': s(r, 'risk_pt'), 'risk_en': s(r, 'risk_en'),
                            'trimester_pt': s(r, 'trimester_pt'),
                            'trimester_en': s(r, 'trimester_en'),
                            'lactation_pt': s(r, 'lactation_pt'),
                            'lactation_en': s(r, 'lactation_en'),
                            'contraception_pt': s(r, 'contraception_pt'),
                            'contraception_en': s(r, 'contraception_en'),
                            'fonte_pt': s(r, 'source_pt'), 'fonte_en': s(r, 'source_en'),
                            'estado': 'publicado',
                        }

        # --- Pares estilo 083/085/094: INSERT ... SELECT com literais,
        #     FROM public.drugs a, public.drugs b WHERE a.slug='x' AND b.slug='y' ---
        for blk in parse_insert_select_pairs(text):
            key = tuple(sorted([blk['a'], blk['b']]))
            if key in pairs:
                continue
            r = blk['values']
            pairs[key] = {
                'a': key[0], 'b': key[1],
                'severidade': s(r, 'severity'),
                'resumo_pt': s(r, 'summary_pt'), 'resumo_en': s(r, 'summary_en'),
                'resumo_pro_pt': s(r, 'summary_pro_pt'),
                'resumo_pro_en': s(r, 'summary_pro_en'),
                'explicacao_pt': s(r, 'explanation_pt'),
                'explicacao_en': s(r, 'explanation_en'),
                'mecanismo_pt': s(r, 'mechanism_pt'), 'mecanismo_en': s(r, 'mechanism_en'),
                'conselho_pt': s(r, 'management_pt'), 'conselho_en': s(r, 'management_en'),
                'monitorizacao_pt': s(r, 'monitoring_pt'),
                'monitorizacao_en': s(r, 'monitoring_en'),
                'red_flags_pt': s(r, 'red_flags_pt'), 'red_flags_en': s(r, 'red_flags_en'),
                'fonte_pt': s(r, 'source_pt'), 'fonte_en': s(r, 'source_en'),
                'estado': estado(s(r, 'status')),
                'data_revisao': s(r, 'updated_at')[:10],
            }

        # --- Perfil editorial + farmacologia (tabelas 1:1 com drugs) ---
        for table in ['drug_profiles', 'drug_pharmacology']:
            for v_cols, tuples in parse_new_dim_blocks(text, table):
                for t in tuples:
                    if len(t) != len(v_cols):
                        continue
                    r = dict(zip(v_cols, t))
                    drug = s(r, 'slug')
                    if not drug:
                        continue
                    prof = profiles.setdefault(drug, {
                        'slug': drug, 'farmaco_slug': drug,
                        'perfil_publico_pt': '', 'perfil_publico_en': '',
                        'perfil_pro_pt': '', 'perfil_pro_en': '',
                        'indicacoes_pt': '', 'indicacoes_en': '',
                        'efeitos_secundarios_pt': '', 'efeitos_secundarios_en': '',
                        'precaucoes_pt': '', 'precaucoes_en': '',
                        'farmacodinamica_pt': '', 'farmacodinamica_en': '',
                        'mecanismo_acao_pt': '', 'mecanismo_acao_en': '',
                        'metabolismo_pt': '', 'metabolismo_en': '',
                        'absorcao_pt': '', 'absorcao_en': '',
                        'meia_vida_pt': '', 'meia_vida_en': '',
                        'fonte_perfil_pt': '', 'fonte_perfil_en': '',
                        'fonte_farmacologia_pt': '', 'fonte_farmacologia_en': '',
                        'estado': 'publicado',
                    })
                    if table == 'drug_profiles':
                        prof['perfil_publico_pt'] = s(r, 'overview_public_pt')
                        prof['perfil_publico_en'] = s(r, 'overview_public_en')
                        prof['perfil_pro_pt'] = s(r, 'overview_pro_pt')
                        prof['perfil_pro_en'] = s(r, 'overview_pro_en')
                        prof['indicacoes_pt'] = s(r, 'indications_pt')
                        prof['indicacoes_en'] = s(r, 'indications_en')
                        prof['efeitos_secundarios_pt'] = s(r, 'side_effects_pt')
                        prof['efeitos_secundarios_en'] = s(r, 'side_effects_en')
                        prof['precaucoes_pt'] = s(r, 'precautions_pt')
                        prof['precaucoes_en'] = s(r, 'precautions_en')
                        prof['fonte_perfil_pt'] = s(r, 'source_pt')
                        prof['fonte_perfil_en'] = s(r, 'source_en')
                    else:
                        prof['farmacodinamica_pt'] = s(r, 'pharmacodynamics_pt')
                        prof['farmacodinamica_en'] = s(r, 'pharmacodynamics_en')
                        prof['mecanismo_acao_pt'] = s(r, 'mechanism_pt')
                        prof['mecanismo_acao_en'] = s(r, 'mechanism_en')
                        prof['metabolismo_pt'] = s(r, 'metabolism_pt')
                        prof['metabolismo_en'] = s(r, 'metabolism_en')
                        prof['absorcao_pt'] = s(r, 'absorption_pt')
                        prof['absorcao_en'] = s(r, 'absorption_en')
                        prof['meia_vida_pt'] = s(r, 'half_life_pt')
                        prof['meia_vida_en'] = s(r, 'half_life_en')
                        prof['fonte_farmacologia_pt'] = s(r, 'source_pt')
                        prof['fonte_farmacologia_en'] = s(r, 'source_en')

        # --- Códigos ATC (migração 084: UPDATE ... FROM (VALUES) AS v(slug, atc_code)) ---
        for v_cols, tuples in parse_join_values(text):
            if 'slug' not in v_cols or 'atc_code' not in v_cols:
                continue
            i_slug = v_cols.index('slug')
            i_atc = v_cols.index('atc_code')
            for t in tuples:
                if len(t) != len(v_cols):
                    continue
                slug = unquote(t[i_slug])
                atc = unquote(t[i_atc])
                if slug and atc:
                    atc_map[slug] = atc

    # Aplicar ATC aos fármacos (a 084 só atualiza os que já existiam).
    for sg in drug_rows:
        if sg in atc_map:
            drug_rows[sg]['atc'] = atc_map[sg]

    # -------------------------------------------------------------- tabelas CSV
    ff_rows = []
    for key in sorted(pairs):
        p = pairs[key]
        ff_rows.append({
            'slug': '%s_%s' % (p['a'], p['b']),
            'farmaco_a_slug': p['a'], 'farmaco_b_slug': p['b'],
            'severidade': p['severidade'],
            'resumo_pt': p['resumo_pt'], 'resumo_en': p['resumo_en'],
            'resumo_pro_pt': p.get('resumo_pro_pt', ''),
            'resumo_pro_en': p.get('resumo_pro_en', ''),
            'explicacao_pt': p.get('explicacao_pt', ''),
            'explicacao_en': p.get('explicacao_en', ''),
            'mecanismo_pt': p['mecanismo_pt'], 'mecanismo_en': p['mecanismo_en'],
            'conselho_pt': p['conselho_pt'], 'conselho_en': p['conselho_en'],
            'monitorizacao_pt': p['monitorizacao_pt'],
            'monitorizacao_en': p['monitorizacao_en'],
            'red_flags_pt': p['red_flags_pt'], 'red_flags_en': p['red_flags_en'],
            'fonte_pt': p['fonte_pt'], 'fonte_en': p['fonte_en'],
            'estado': p['estado'], 'data_revisao': p['data_revisao'],
        })

    alimento_rows = [food[k] for k in food]
    doenca_rows = [disease[k] for k in disease]

    doencas = cond_names  # nomes capturados durante o replay (condition_pt/en)

    gravidez_rows = [preg[k] for k in preg]

    # 8.ª tabela: perfil editorial + farmacologia, 1:1 com Fármacos
    perfil_rows = [profiles[k] for k in sorted(profiles)]

    # -------------------------------------------------------------- 4. Fontes
    def pub_of(url):
        if 'dailymed.nlm.nih.gov' in url:
            return 'FDA DailyMed'
        if 'medicines.org.uk' in url:
            return 'EMC-UK (MHRA)'
        if 'hres.ca' in url:
            return 'Health Canada'
        if 'infarmed' in url.lower():
            return 'INFARMED'
        return 'Outra'

    def slug_of(url, pub):
        m = re.search(r'/emc/product/(\d+)/smpc', url)
        if m:
            return 'emc-uk-product-%s' % m.group(1)
        m = re.search(r'setid=([0-9a-fA-F-]{8})', url)
        if m:
            return 'dailymed-%s' % m.group(1)
        m = re.search(r'dpd_pm/(\d+)', url)
        if m:
            return 'hc-dpd-pm-%s' % m.group(1)
        return 'fonte-' + hashlib.md5(url.encode('utf-8')).hexdigest()[:8]

    def title_of(left, pub):
        left = left.rstrip(' :–-—')
        if 'corroboração' in left or 'corroborated' in left:
            m = re.search(r'(?:Monografia do Produto|Product Monograph)\s+([^(:]+)', left)
            if m:
                return '%s (%s)' % (m.group(1).strip(), pub)
        for sep in (' — ', ' - '):
            if sep in left:
                left = left.split(sep, 1)[1]
                break
        left = re.sub(r'\s*(label|SmPC|smpc|smPC|Product Monograph)\s*$', '', left,
                      flags=re.I).strip()
        left = re.sub(r'^(rótulo aprovado|approved|Monografia do Produto|SmPC aprovada|smPC aprovada)\s+',
                      '', left, flags=re.I).strip()
        name = re.sub(r'\s*\([^)]*\)\s*$', '', left).strip()
        if not name:
            name = pub
        return '%s (%s)' % (name, pub)

    fontes = {}
    all_source_pt = ([p['fonte_pt'] for p in pairs.values()] +
                     [r['fonte_pt'] for r in alimento_rows] +
                     [r['fonte_pt'] for r in doenca_rows] +
                     [r['fonte_pt'] for r in gravidez_rows] +
                     [r['fonte_perfil_pt'] for r in perfil_rows] +
                     [r['fonte_farmacologia_pt'] for r in perfil_rows])
    for text in all_source_pt:
        for url in re.findall(r'https?://[^\s;]+', text):
            url = url.rstrip('.,;:')
            if not url or url in fontes:
                continue
            pub = pub_of(url)
            fontes[url] = {
                'slug': slug_of(url, pub),
                'publicacao': pub,
                'titulo': title_of(text.split(url)[0], pub),
                'url': url,
                'acessado_em': '',
                'dominio_publico': 'true' if pub != 'Outra' else 'false',
                'notas': '',
            }
    fontes_rows = [fontes[u] for u in sorted(fontes)]

    # ------------------------------------------------------------- escrita CSV
    n = {}
    n['01-farmacos.csv'] = write_csv('01-farmacos.csv', FARMACOS_HEADERS,
                                     [drug_rows[sg] for sg in sorted(drug_rows)])
    n['02-fontes.csv'] = write_csv('02-fontes.csv', FONTES_HEADERS, fontes_rows)
    n['03-interacoes-farmaco-farmaco.csv'] = write_csv(
        '03-interacoes-farmaco-farmaco.csv', FF_HEADERS, ff_rows)
    n['04-interacoes-alimento-bebida.csv'] = write_csv(
        '04-interacoes-alimento-bebida.csv', ALIMENTO_HEADERS, alimento_rows)
    n['05-doencas.csv'] = write_csv('05-doencas.csv', DOENCAS_HEADERS,
                                    [doencas[sg] for sg in sorted(doencas)])
    n['06-interacoes-doenca.csv'] = write_csv('06-interacoes-doenca.csv',
                                              DOENCA_HEADERS, doenca_rows)
    n['07-gravidez-lactacao.csv'] = write_csv('07-gravidez-lactacao.csv',
                                              GRAVIDEZ_HEADERS, gravidez_rows)
    n['08-perfil-farmacologia.csv'] = write_csv('08-perfil-farmacologia.csv',
                                                PERFIL_HEADERS, perfil_rows)

    print('Pack gerado em %s (%d migrações analisadas)' % (OUT_DIR, len(files)))
    for fname, count in sorted(n.items()):
        print('  %-38s %4d registos' % (fname, count))
    print('Total fármacos: %d | pares FF: %d | fontes únicas: %d | perfis+farmacologia: %d'
          % (len(drug_rows), len(pairs), len(fontes), len(perfil_rows)))


if __name__ == '__main__':
    main()
