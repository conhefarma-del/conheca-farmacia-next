# ERROS RECORRENTES — Consultar ANTES de criar qualquer migração

> **ESTE DOCUMENTO É OBRIGATÓRIO.** Ler ANTES de escrever qualquer INSERT/UPDATE.
> Cada erro listado já ocorreu pelo menos 2 vezes nesta sessão.

---

## ERRO 1: FALTA `'published'` NO INSERT

**O que acontece:** O INSERT tem X colunas mas o SELECT tem X-1 valores (falta `'published'`).

**Causa:** Esquecer de incluir o valor do status na última posição do SELECT.

**Exemplo ERRADO:**
```sql
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)        -- 8 colunas
SELECT d.id,
  'Resumo público', 'Public overview',
  'Resumo profissional', 'Professional overview',
  'Fonte PT', 'Fonte EN'               -- 7 valores (FALTA 'published')!
FROM ...
```

**Exemplo CORRECTO:**
```sql
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)        -- 8 colunas
SELECT d.id,
  'Resumo público', 'Public overview',
  'Resumo profissional', 'Professional overview',
  'Fonte PT', 'Fonte EN',
  'published'                            -- 8 valores ✓
FROM ...
```

**REGRAS:**
- Se a coluna `status` está na lista de colunas → incluir `'published'` no SELECT
- Se a coluna `status` NÃO está na lista → não incluir (usa DEFAULT)
- **Verificar SEMPRE:** contar colunas = contar valores no SELECT

---

## ERRO 2: ORDEM CANÓNICA (drug_a_id < drug_b_id)

**O que acontece:** O constraint `drug_interactions_canonical_order` rejeita o INSERT porque `drug_a_id > drug_b_id`.

**Causa:** Não verificar os UUIDs antes de criar os pares.

**Solução PERMANENTE:** Atribuir UUID fixo a fármacos novos (ex: `a0000000-0000-4000-8000-000000000001`) e calcular a ordem antes.

**Antes de criar pares, SEMPRE:**
```javascript
// Verificar ordem de TODOS os pares
const nimesulida = 'a0000000-0000-4000-8000-000000000001';
const drugs = { 'warfarina': '4369efeb-...', 'litio': '49033762-...' };
Object.entries(drugs).forEach(([slug, uuid]) => {
  console.log(uuid < nimesulida ? slug + ' < nimesulida' : 'nimesulida < ' + slug);
});
```

**Hex comparação:** `'a' > '4'`, `'f' > 'c'`, etc. Não confundir com decimal!

---

## ERRO 3: NOMES DE COLUNAS INCORRECTOS

**Consultar SEMPRE `docs/SCHEMA_TABELAS_INTERACOES.md` antes de escrever.**

| ❌ ERRADO | ✅ CORRETO | TABELA |
|-----------|-----------|--------|
| `disease_slug` | `condition_slug` | drug_disease_interactions |
| `disease_pt/en` | `condition_pt/en` | drug_disease_interactions |
| `mechanism_pt/en` (disease) | `reason_pt/en` | drug_disease_interactions |
| `pregnancy_info_pt/en` | `risk_pt/en` | drug_pregnancy_info |
| `lactation_info_pt/en` | `lactation_pt/en` | drug_pregnancy_info |
| `fertility_info_pt/en` | `contraception_pt/en` | drug_pregnancy_info |
| `explanation_pt/en` | `mechanism_pt/en` | drug_interactions |
| `recommendation_pt/en` | `management_pt/en` | drug_interactions |
| `'caution'` (interaction_type) | `'precaution'` | drug_disease_interactions |

---

## ERRO 4: TUPLES COM NÚMERO ERRADO DE VALORES

**O que acontece:** `VALUES lists must all be all be the same length`

**Causa:** Esquecer campos (geralmente `red_flags_pt/en` que são novos).

**Colunas por tabela (contar SEMPRE):**

| Tabela | Colunas (excluding id, timestamps) |
|--------|-------------------------------------|
| `drug_interactions` | 16 (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en, management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en, source_pt, source_en, source_url) |
| `drug_food_interactions` | 8 (drug_id, entity_slug, entity_pt, entity_en, mechanism_pt, mechanism_en, advice_pt, advice_en) |
| `drug_disease_interactions` | 11 (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity, reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en) |
| `drug_pregnancy_info` | 11 (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en, lactation_pt, lactation_en, contraception_pt, contraception_en, source_pt, source_en) |
| `drug_profiles` | 8 (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en, source_pt, source_en, status) |
| `drug_pharmacology` | 13 (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en, metabolism_pt, metabolism_en, absorption_pt, absorption_en, half_life_pt, half_life_en, source_pt, source_en, status) |

---

## ERRO 5: `ON d.slug = v.slug` EM VEZ DE `WHERE d.slug = v.slug`

**O que acontece:** Syntax error ou referência a coluna inexistente.

**Causa:** Confundir `ON` (para JOINs) com `WHERE` (para filtros).

**Padrão CORRECTO para INSERT único:**
```sql
SELECT d.id, ...
FROM public.drugs d
WHERE d.slug = 'nome_farmaco'    -- WHERE, não ON!
ON CONFLICT ...
```

**Padrão CORRECTO para INSERT múltiplo:**
```sql
SELECT d.id, ...
FROM public.drugs d
JOIN (VALUES ('slug1'), ('slug2')) AS v(slug)
ON d.slug = v.slug               -- ON aqui é correcto (é um JOIN)
ON CONFLICT ...
```

---

## CHECKLIST PRÉ-MIGRAÇÃO

Antes de escrever QUALQUER INSERT:

- [ ] Ler `docs/SCHEMA_TABELAS_INTERACOES.md` para nomes de colunas
- [ ] Contar colunas no INSERT = contar valores no SELECT
- [ ] Se `status` está na lista → incluir `'published'` no SELECT
- [ ] Verificar ordem canónica de TODOS os pares drug_interactions
- [ ] Usar `WHERE` (não `ON`) para INSERTs de fármaco único
- [ ] Usar `JOIN ... ON` para INSERTs múltiplos via VALUES
- [ ] Verificar `interaction_type` = `'precaution'` ou `'contraindication'` (não `'caution'`)
- [ ] Verificar `pregnancy_category` = `'contraindicated'`, `'caution'`, `'compatible'`, `'no_data'`
- [ ] **DEPOIS de escrever**: correr script de validação de ordem canónica contra UUIDs reais na BD (não apenas fixos)
- [ ] **Incluir red_flags_pt e red_flags_en** em TODOS os tuples drug_interactions (mesmo que vazios '')
- [ ] Em `UPDATE ... FROM`, a tabela-alvo não pode aparecer num JOIN LATERAL da cláusula FROM (ver ERRO 6)
- [ ] Em blocos VALUES, cada tuple tem o MESMO nº de valores que os aliases do `AS v(...)` — perfis e farmacologia em migrações separadas (ver ERRO 8)
- [ ] **VALIDAÇÃO OBRIGATÓRIA antes de commit** (ver secção "FLUXO DE VALIDAÇÃO ESTRUTURAL"):
  ```bash
  node _temp/_validar_sql_basico.mjs <ficheiro.sql>
  node _temp/_auditar_bloco.mjs <ficheiro.sql>
  node _temp/_validar_267.mjs   # se for migração de interações
  ```
- [ ] Verificar contra a BD real que os pares drug_interactions novos não existem já (ON CONFLICT protege, mas o par duplicado é ruído)
- [ ] DDL com CHECK/trigger sobre dados existentes: testar o padrão (regex/enum/limite) contra TODAS as linhas antes de escrever (ver ERRO 9) e simular a lógica em Node contra a BD real
- [ ] Regexes e padrões nunca se testam inline no bash — gravar script em `_temp/` e correr como ficheiro (ver ERRO 9)
- [ ] UPDATE que remapeia os dois lados de um par com ordem obrigatória: produzir JÁ a ordem canónica no SET (LEAST/GREATEST) — CHECKs avaliam-se por linha, não no COMMIT (ver ERRO 10)
- [ ] UPDATE ... FROM ... JOIN: o alias do target (e a tabela target sem alias) só aparece no SET e no WHERE — nunca no ON do JOIN (ver ERROS 6 e 11); correr `_temp/_detetar_alias_on.mjs` antes de commit
- [ ] Nomes próprios/páginas em EN sem apóstrofo (`Graves Disease`, não `Graves' Disease`) — o apóstrofo em string quebra o SQL e em comentário quebra o validador de aspas (ver ERRO 12a)
- [ ] Simulações read-only em Node: comparar UUIDs como strings, nunca com `Math.min`/`Math.max` (ver ERRO 12b); se a simulação disser "nada a fazer", verificar o script antes de concluir
- [ ] Listas em comentário sem `X)` isolado (dá depth negativa no validador de parênteses): usar `A —`/`(A)`/`1.` (ver ERRO 12c)
- [ ] Fusão de duplicados: decidir sobre a chave **pós-remapeamento** (colisões de 2.ª ordem com ambos os lados duplicados — ver ERRO 13); simular e verificar 0 chaves duplicadas, 0 fora de ordem, 0 órfãos
- [ ] Incluir no âmbito slugs de duplicados **já arquivados** que ainda tenham pares/fichas activos (ver ERRO 13, corolário)

---

## ERRO 6: REFERÊNCIA À TABELA-ALVO DENTRO DE JOIN LATERAL DO UPDATE (2026-09-29)

**O que acontece:** `ERROR: 42P10 invalid reference to FROM-clause entry for table "di"` ao aplicar o UPDATE.

**Causa:** Numa migração de merge (254) usei:
```sql
UPDATE public.drug_interactions di
SET drug_a_id = ..., drug_b_id = d.other_id
FROM _m254_ids i
JOIN LATERAL (
  SELECT CASE WHEN di.drug_a_id = ... THEN ... END AS other_id  -- ❌ "di" aqui
) d ON true
WHERE ...
```
O Postgres **não permite referenciar a tabela-alvo do UPDATE** (`di`) dentro de
subqueries/JOINs da cláusula `FROM` — só nas cláusulas `SET` e `WHERE`.

**Correção (padrão CASE inline):**
```sql
UPDATE public.drug_interactions di
SET drug_a_id = i.sobrevivente_id,
    drug_b_id = CASE WHEN di.drug_a_id = i.duplicado_id THEN di.drug_b_id ELSE di.drug_a_id END,
    updated_at = now()
FROM _ids i
WHERE (di.drug_a_id = i.duplicado_id OR di.drug_b_id = i.duplicado_id)
  AND CASE WHEN di.drug_a_id = i.duplicado_id THEN di.drug_b_id ELSE di.drug_a_id END > i.sobrevivente_id;
```

**Regra:** condição derivada da linha-alvo → inline no `SET`/`WHERE`; só metadados
independentes (temp tables, CTEs) na cláusula `FROM`.

---

## ERRO 7: REMAPEAMENTO QUE VIOLA O UNIQUE ANTES DE RESOLVER COLISÕES (2026-09-29)

**O que acontece:** `ERROR: 23505 duplicate key value violates unique constraint
"drug_interactions_pair_unique"` ao aplicar o UPDATE de remapeamento.

**Causa:** na migração 254, o passo de remapear `drug_a_id/drug_b_id` do duplicado
para o sobrevivente corria ANTES do passo que arquivava as linhas em conflito.
O `UNIQUE (drug_a_id, drug_b_id)` dispara **durante o próprio UPDATE** —
quando a primeira linha remapeada colide com uma linha pré-existente do
sobrevivente, a migração falha (e a transação revierte).

**Correção (ordem certa de operações):**
```sql
-- 4A: snapshot das linhas a mover (temp table com par normalizado LEAST/GREATEST)
CREATE TEMP TABLE _move AS SELECT di.id AS linha_id, ... FROM ... WHERE is_archived = false;

-- 4B: resolver colisões ARQUIVANDO perdedoras (sem tocar em drug_a_id/drug_b_id)
--     4B.1 arquiva a linha do duplicado se a do sobrevivente for >= severidade
--     4B.2 arquiva a do sobrevivente se a do duplicado for >

-- 4C: só agora remapear, com guarda NOT EXISTS contra colisões remanescentes
UPDATE ... SET drug_a_id = CASE ... WHERE ... AND NOT EXISTS (SELECT 1 ... mesmo par ...);
```

**Regras:**
- Numa tabela com UNIQUE natural (par, slug, etc.), **nunca** remapear a chave
  antes de remover/arquivar os conflitos — o constraint avalia-se linha a linha.
- Usar `LEAST/GREATEST` para comparar pares independentemente da orientação.
- A guarda `NOT EXISTS` no UPDATE final dá idempotência (reaplicar = 0 mudanças).

---

## ERRO 8: MISTURA DE COLUNAS DE PERFIS E FARMACOLOGIA NO MESMO VALUES (2026-09-30)

**O que acontece:** `ERROR: INSERT has more expressions than target columns` ao
aplicar a migração. Numa migração com `INSERT INTO drug_profiles ... 13 colunas`,
12 de 13 tuples tinham **17 valores** — falha latente que só aparece ao aplicar.

**Causa (migração 265, Lote 3):** ao gerar os tuples, os 4 campos de
farmacocinética (metabolismo/absorção PT-EN) que pertencem à migração de
farmacologia (`drug_pharmacology`, colunas 266/270) ficaram intercalados nos
tuples de perfis (`drug_profiles`, 13 colunas). O tuple ficou assim:

```sql
-- ❌ ERRADO — 17 valores para 13 colunas de drug_profiles:
('testosterona',
 E'Overview público PT',        -- overview_public_pt
 E'Public overview EN',         -- overview_public_en
 E'Overview pro PT',            -- overview_pro_pt
 E'Overview pro EN',            -- overview_pro_en
 E'Metabolismo PT',             -- ❌ NÃO É COLUNA de drug_profiles!
 E'Metabolism EN',              -- ❌
 E'Absorção PT',                -- ❌
 E'Absorption EN',              -- ❌
 E'Meia-vida PT',               -- ❌
 E'Half-life EN',               -- ❌
 E'• Indicação 1\n• Indicação 2',  -- indicações_pt
 E'• Indication 1\n• Indication 2', -- indications_en
 E'• Efeito 1\n• Efeito 2',        -- side_effects_pt
 ...
 E'Fonte PT', E'Fonte EN'),
-- (e as colunas do AS v() continuam a declarar 13 aliases → desalinhamento total)

-- ✅ CORRECTO — 13 valores: slug + 12 colunas de perfil (sem status, que
--    entra no SELECT via literal 'published'):
('testosterona',
 E'Overview público PT',        -- overview_public_pt
 E'Public overview EN',         -- overview_public_en
 E'Overview pro PT',            -- overview_pro_pt
 E'Overview pro EN',            -- overview_pro_en
 E'• Indicação 1\n• Indicação 2',  -- indications_pt
 E'• Indication 1\n• Indication 2', -- indications_en
 E'• Efeito 1\n• Efeito 2',        -- side_effects_pt
 E'• Side effect 1\n• Side effect 2', -- side_effects_en
 E'• Precaução 1\n• Precaução 2',  -- precautions_pt
 E'• Precaution 1\n• Precaution 2', -- precautions_en
 E'Fonte PT', E'Fonte EN'),
```

**Contagem de referência (ver docs/SCHEMA_TABELAS_INTERACOES.md):**

| INSERT | Colunas de tabela | + slug no VALUES | + status no SELECT |
|--------|-------------------|------------------|--------------------|
| `drug_profiles` | 12 (drug_id + 11) | 13 (slug + 12) | `'published'` no SELECT |
| `drug_pharmacology` | 13 (drug_id + 12) | 14 (slug + 13) | `'published'` no SELECT |

**Porquê é perigoso:** o padrão `JOIN (VALUES ...) AS v(...)` só falha no
Postgres se o **número de valores ≠ número de aliases do `AS v(...)`**. Como o
SELECT mapeia alias a alias, um tuple com campos extra desalinha tudo — e se o
desalinhamento for consistente (mesmo nº de campos em todos os tuples), o
INSERT até pode passar e gravar dados nas colunas erradas.

**Prevenção (validadores, ver secção seguinte):**
```bash
# 1. Contar campos de topo por tuple vs aliases do AS v(...)
node _temp/_auditar_bloco.mjs supabase/migrations/NNN_ficheiro.sql

# 2. Aspas pares por linha + parênteses equilibrados fora de strings
node _temp/_validar_sql_basico.mjs supabase/migrations/NNN_ficheiro.sql
```

**Regras:**
- Cada migração escreve SÓ PARA A SUA TABELA: perfis → `drug_profiles`;
  farmacologia → `drug_pharmacology`. Nunca misturar campos das duas num tuple.
- Os campos de farmacocinética (metabolismo, absorção, meia-vida) pertencem
  **exclusivamente** a `drug_pharmacology`; indicações, efeitos adversos e
  precauções pertencem **exclusivamente** a `drug_profiles`.
- Em strings `E'...'`, usar `\n` para newlines reais (não `\\n`, que grava
  barra-n literal no site) e evitar apóstrofos não-escapados dentro da string.

---

## ERRO 9: CONSTRAINT CHECK CRIADA SEM TESTAR O PADRÃO CONTRA OS DADOS EXISTENTES (2026-10-01)

**O que acontece:** `ERROR: 23514 check constraint "drugs_atc_code_format_chk" of
relation "drugs" is violated by some row` ao aplicar a migração — e, como o SQL
editor corre tudo numa transação, **a migração inteira faz rollback** (nem as
tabelas de referência nem o trigger ficam criados).

**Causa (migração 276, guardas ATC):** a regex do CHECK foi escrita de cabeça,
sem testar contra os 375 ATC reais da BD:

```sql
-- ❌ ERRADO — exige DÍGITOS nos subgrupos 3/4:
CHECK (atc_code ~ '^[A-Z][0-9]{2}([A-Z][0-9]{2}([A-Z][0-9]{2})?)?$')
-- viola TODOS os códigos reais: C01CA04, J01XX09, …

-- ✅ CORRECTO — no ATC real, os níveis 3/4 são LETRAS e o nível 5 são 2 dígitos:
CHECK (atc_code ~ '^[A-Z][0-9]{2}([A-Z]{1,2}[0-9]{2})?$')
-- cobre J01 (nível 3), C01CA04 (nível 5) e J01XX09 (nível 7)
```

**Porquê é insidioso:** o teste de validação em Node correu **inline** no bash
(`node --input-type=module -e "…"`) e o escaping do bash corrompeu a regex — o
`\$` da âncora de fim virou literal `$`, o teste marcou "violações" falsas e
depois, ao "corrigir", pareceu confirmar a regex errada. Só um teste em
**ficheiro** (`_temp/_teste_atc_regex.mjs`) produziu resultados fiáveis e
revelou o bug real (375/375 violações com a regex original; 0 com a correta).

**Regras:**
- **Nunca criar um CHECK contra uma tabela populada sem antes correr o padrão
  (regex, tamanho, enum) contra TODAS as linhas existentes** — via service key
  ou `SELECT count(*) FROM t WHERE NOT (condição)` num SQL editor.
- Alternativa para tabelas grandes/arriscadas: `ADD CONSTRAINT … NOT VALID`
  (aplica só a novas linhas) seguido de `VALIDATE CONSTRAINT` num momento
  controlado — mas a validação prévia continua obrigatória.
- **Regexes NUNCA se testam inline no bash** — o escaping (`\$`, `!`, aspas)
  corrompe padrões silenciosamente. Gravar sempre um script em ficheiro:
  ```bash
  node _temp/_teste_atc_regex.mjs   # valida a regex EXACTA da migração vs a BD
  ```
- Validadores existentes (ERRO 8, secção seguinte) não cobrem CHECKs/triggers —
  para DDL com validação de dados, criar script de simulação dedicado que
  replique a lógica da constraint em Node contra a BD real (o padrão usado na
  276 para simular o trigger de coerência classe↔letra antes de aplicar).

---

## ERRO 10: ASSUMIR QUE O CHECK SÓ AVALIA NO COMMIT — UPDATE QUE DEIXA LINHAS INVERTIDAS (2026-10-01)

**O que acontece:** `ERROR: 23514 ... violates check constraint
"drug_interactions_canonical_order"` ao correr um UPDATE de remapeamento, mesmo
que um statement posterior corrija o estado — **e volto a falhar depois de
adicionar o passo correctivo**.

**Causa (migração 283, fusão de duplicados):** o passo 4C remapeava o UUID do
duplicado para o do sobrevivente com `CASE WHEN … THEN sobrevivente_id` em cada
campo. Como os UUIDs dos duplicados underscore eram "baixos" e os dos
sobreviventes "altos", 4 pares ficavam com `drug_a_id > drug_b_id` — a violar o
CHECK de ordem canónica (ERRO 2). A primeira "correção" acrescentou um passo 4D
com swap posterior, baseado na suposição de que **o CHECK só se avalia no
COMMIT**. É falso:

```text
❌ SUPSIÇÃO ERRADA: "a transação absorve o estado intermédio (o CHECK
   avalia-se por statement)" — não é por statement de fim de transação:
   é POR LINHA, IMEDIATAMENTE, dentro de cada UPDATE.
```

O PostgreSQL valida CHECK constraints **row-by-row, no momento do UPDATE** — o
statement seguinte (4D) nunca chega a correr porque o 4C já falhou. O rollback
total (ERRO 9) repetiu-se com o mesmo erro detentor.

**Correção (definitiva):** o remapeamento tem de produzir linhas canónicas DE
IMEDIATO — ordenar os UUIDs no próprio SET:

```sql
-- ✅ CORRECTO — LEAST/GREATEST sobre os valores PÓS-substituição:
UPDATE public.drug_interactions di
SET drug_a_id = LEAST(
      CASE WHEN di.drug_a_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_a_id END,
      CASE WHEN di.drug_b_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_b_id END),
    drug_b_id = GREATEST(
      CASE WHEN di.drug_a_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_a_id END,
      CASE WHEN di.drug_b_id = m.duplicado_id THEN m.sobrevivente_id ELSE di.drug_b_id END)
FROM _m283_ids m
WHERE di.drug_a_id = m.duplicado_id OR di.drug_b_id = m.duplicado_id;

-- ❌ ERRADO — estado intermédio invertido espera por um "passo 4D" posterior
--    que nunca corre (o 4C falha primeiro, linha a linha).
```

**Regras:**
- **CHECK constraints avaliam-se POR LINHA e IMEDIATAMENTE** em INSERT/UPDATE —
  nunca confiar em "um statement mais à frente corrige o estado".
- Um UPDATE de remapeamento que possa trocar/alterar os dois lados de um par com
  ordem obrigatória (canónica, cronológica, hierárquica) deve **produzir já a
  ordem certa** (LEAST/GREATEST, CASE ordenado, ou ORDER BY em query wrapper) —
  não depender de um passo correctivo subsequente.
- Para correções que exigem estado intermédio inválido de verdade (raro), a
  única via segura é **abater a constraint, correr o UPDATE, recriar a
  constraint** dentro da mesma transação — documentado aqui como último recurso;
  preferir sempre o desenho que nunca passa por estado inválido.
- "A transação absorve o estado intermédio" aplica-se a **deferred constraints**
  (declaradas `DEFERRABLE INITIALLY DEFERRED`) — não é o comportamento por omissão
  de um CHECK.

---

## ERRO 11: ALIAS DO TARGET DE UPDATE REFERENCIADO NO ON DE UM JOIN (42P01) (2026-10-01)

**Generalização do ERRO 6** (que documenta o caso `JOIN LATERAL`, 42P10): o
mesmo problema de scope surge em qualquer JOIN do `FROM` de um UPDATE —
JOIN directo incluído.

**O que acontece:** `ERROR: 42P01: invalid reference to FROM-clause entry for
table "ddi"` apontando para a linha do `ON` — num UPDATE que compila
semanticamente à primeira vista (a tabela e o alias existem!).

**Causa (migração 283, passo 5 — remapeamento de doença/alimento):** num
`UPDATE tabela alias SET ... FROM ... JOIN outra ON ...`, o alias do **target**
(`ddi`/`dfi`) só pode aparecer no `SET` e no `WHERE` — **nunca no `ON`** do
JOIN. O parser do PostgreSQL resolve o `FROM` primeiro (como um SELECT
independente) e, nessa fase, o alias do target ainda não está no scope:

```sql
-- ❌ ERRADO — keep.condition_slug = ddi.condition_slug dentro do ON:
UPDATE public.drug_disease_interactions ddi
SET is_archived = true
FROM _m283_ids i
JOIN public.drug_disease_interactions keep
  ON keep.drug_id = i.sobrevivente_id
 AND keep.is_archived = false
 AND keep.condition_slug = ddi.condition_slug     -- 42P01 aqui
WHERE ddi.drug_id = i.duplicado_id;

-- ✅ CORRECTO — a condição com o alias do target vai para o WHERE:
UPDATE public.drug_disease_interactions ddi
SET is_archived = true
FROM _m283_ids i
JOIN public.drug_disease_interactions keep
  ON keep.drug_id = i.sobrevivente_id
 AND keep.is_archived = false
WHERE ddi.drug_id = i.duplicado_id
  AND keep.condition_slug = ddi.condition_slug;   -- OK: target no WHERE
```

**Porquê é insidioso:** o mesmo UPDATE funciona quando a condição usa os aliases
do próprio FROM (`keep.id <> t.linha_id` — o `keep` é alias do JOIN, válido no
ON). O erro só explode nas linhas que cruzam o target com o FROM, e a mensagem
("There is an entry for table..., but it cannot be referenced from this part of
the query") não diz onde está a fronteira do scope. Um inner join é
semanticamente equivalente nos dois sítios, pelo que a correcção é sempre
segura: mover para o WHERE.

**Regras:**
- Num `UPDATE t alias SET ... FROM ... JOIN x ON ...`, o `alias` do target
  **aparece exclusivamente no SET e no WHERE**. No FROM/JOIN/ON referem-se
  apenas as tabelas/aliases do próprio FROM.
- Referências à tabela target **sem alias** (ex.: `keep.condition_slug =
  drug_disease_interactions.condition_slug`) sofrem do mesmo problema — o
  nome da tabela target também não pode ser referenciado dentro do ON do FROM.
- Para UPDATE self-join (a target aparece também no FROM), usar aliases
  distintos e manter a condição cruzada no WHERE; se for inevitável no ON,
  reescrever como subquery `WHERE id IN (SELECT ...)`.
- Detector: `_temp/_detetar_alias_on.mjs <ficheiro.sql>` varre todos os
  statements UPDATE de um ficheiro e sinaliza referências ao alias do target
  dentro da secção FROM/JOIN/ON (sai com `exit 1` se houver).
- Ver também ERRO 6 (JOIN LATERAL, 42P10) — a regra é a mesma: o target só
  vive no SET/WHERE; a diferença é só a fase em que o Postgres o detecta.

---

## ERRO 12: NOME PRÓPRIO COM APÓSTROFO E UUIDs EM SCRIPTS NODE (2026-10-02)

Duas armadilhas de validação encontradas na migração 289 — nenhuma é erro de
SQL inválido, mas ambas produzem falsos diagnósticos.

**12a — apóstrofo em nome próprio (o validador de aspas não distingue
contexto).** `Graves' Disease` tem nº ímpar de `'`: dentro de uma string SQL
fecha o literal (erro de sintaxe); **dentro de um comentário `--` não estraga
nada, mas faz o `_validar_sql_basico.mjs` falhar** — e um FAIL de aspas num
comentário é ruído que pode esconder um FAIL real de string no mesmo ficheiro.

```sql
-- ❌ FAIL aspas ímpares nas linhas N (comentário: "Graves' Disease")
-- ✅ escrever sem apóstrofo: "Graves Disease" (mantém a citação bibliográfica)
```

**Regra:** ao citar nomes próprios/páginas em EN (Graves, Crohn, Wilson,
patient's...), escrever **sem apóstrofo** e correr o validador antes do commit.
Se o apóstrofo for indispensável numa string, escapar `''` (dois plicas).

**12b — `Math.min`/`Math.max` em UUIDs em scripts Node dá `NaN`.** Uma
simulação read-only da PARTE C comparava ids com `Math.min(darq.id, dpar.id)`:
o `Math.min` coage para Number e devolve `NaN`, pelo que **nenhum** par era
encontrado (`orfaoExiste: false`) e a conclusão seria "a PARTE C não faz nada /
não há órfãos" — quando havia 4. O SQL está correcto (`LEAST(a,b)` sobre tipo
`uuid` compara bytes); o que estava errado era a validação em JS.

```js
// ❌ Math.min("3be6ac1a-...", "c47c2a9b-...") → NaN  (nunca casa nada)
// ✅ comparar como strings
const lo = (x, y) => (x < y ? x : y), hi = (x, y) => (x < y ? y : x);
```

**Regra:** em scripts de simulação, comparar UUIDs como **strings** (ordem
lexicográfica = ordem de bytes do `uuid` no Postgres para hex minúsculo). Se
uma simulação de migração devolver "nada a fazer", desconfiar do script antes
de concluir que a BD está vazia do problema.

**12c — rótulos `A)` / `B)` / `C)` em comentários dão depth negativa.** O
`_validar_sql_basico.mjs` conta parênteses **mesmo dentro de comentários** (é
intencional: apanha tuples sem `)` de fecho, e o custo é este falso positivo),
pelo que uma lista de itens em comentário escrita como `A)` abre zero e fecha
um → `FAIL parênteses (depth=-3, negativo=true)` com três itens.

```sql
-- ❌ FAIL parênteses (depth=-3, negativo=true)
--   A) Justificação explícita ...
--   B) Justificação apenas ...
--   C) Sem justificação ...

-- ✅ usar travessão
--   A — Justificação explícita ...
```

**Regra:** listas em comentário usam `—`, `:`, `·` ou numeração `1.`/`1)` — se
usar parêntese de fecho, abrir também (`(A)`). O balanço global do ficheiro
(`abre == fecha`) pode dar 546/546 e ainda assim falhar por linha; o validador
é o critério, não a contagem global.

---

## ERRO 13: FUSÃO DE DUPLICADOS — COLISÃO DE SEGUNDA ORDEM (2026-10-02)

**Generalização do ERRO 7** para o caso em que **os dois lados de uma linha
são duplicados**. O padrão da 283 (e o que a 290 usou inicialmente) compara as
chaves dos pares **antes** do remapeamento: para cada linha do duplicado
procura uma linha equivalente já existente no sobrevivente. Isso só detecta
colisões de primeira ordem.

**O que falha:** na consolidação dos 6 duplicados, a linha
`ferro × acido_ascorbico` (moderate) tem **ambos** os ids duplicados
(`ferro → sulfato-ferroso`, `acido_ascorbico → acido-ascorbico`). Ela não
colide com `acido-ascorbico × sulfato-ferroso` (minor) por chave crua — só
colide **depois** de substituir os dois lados. Com a lógica da 283, essa linha
ficaria activa a apontar para dois fármacos arquivados: um **par órfão**, com
a severidade errada (minor em vez de moderate) e invisível na verificação
"nenhum par activo aponta para arquivado".

```sql
-- ❌ padrão da 283: chave CRUA (não vê a colisão de 2.ª ordem)
JOIN keep ON LEAST(keep.drug_a_id, keep.drug_b_id) = t.par_a

-- ✅ 290: calcular a chave FINAL de cada linha e decidir por grupo
CREATE TEMP TABLE _m290_cand AS
SELECT c.linha_id,
       LEAST(c.sub_a, c.sub_b)    AS nova_a,
       GREATEST(c.sub_a, c.sub_b) AS nova_b,
       c.severity,
       CASE WHEN c.sub_a <> c.drug_a_id OR c.sub_b <> c.drug_b_id THEN 1 ELSE 0 END AS precisa_remap
FROM (SELECT di.id AS linha_id, di.drug_a_id, di.drug_b_id, di.severity,
             COALESCE(i1.sobrevivente_id, di.drug_a_id) AS sub_a,
             COALESCE(i2.sobrevivente_id, di.drug_b_id) AS sub_b
      FROM public.drug_interactions di
      LEFT JOIN _m290_ids i1 ON i1.duplicado_id = di.drug_a_id
      LEFT JOIN _m290_ids i2 ON i2.duplicado_id = di.drug_b_id
      WHERE di.is_archived = false) c;
```

**Ordem de desempate (determinística):** maior severidade → a que **não**
precisa de remapeamento (é a linha do sobrevivente, critério da 283) → menor
`id`. Sem o terceiro critério o resultado depende da ordem de leitura.

**Regra:** ao fundir duplicados, decidir **sobre a chave pós-remapeamento**,
não sobre os ids originais; e simular a fusão inteira em Node antes de escrever
o SQL, verificando três invariantes: (1) 0 chaves duplicadas (violaria
UNIQUE), (2) 0 linhas com `drug_a_id > drug_b_id` (violaria o CHECK, ERRO 10),
(3) 0 pares activos a apontar para fármacos arquivados (órfãos).
Ver `_temp/_simular_passo3.mjs` (290) e `_temp/_ordem_canonica_290.mjs`.

**Corolário — duplicado já arquivado com linhas pendentes:** um merge anterior
pode ter arquivado o fármaco mas deixado pares/fichas activos dele (caso
`losartano`, arquivado, com o par `espironolactona × losartano` e uma ficha de
gravidez ainda activos). A migração de consolidação deve incluir esses slugs
no seu âmbito mesmo com `is_archived = true` — filtrar só por
`d.is_archived = false` esconde-os.

---

## FLUXO DE VALIDAÇÃO ESTRUTURAL (OBRIGATÓRIO ANTES DE COMMIT)

Dois validadores Node em `_temp/` correm sobre o ficheiro SQL **antes** do
commit. Ambos saem com `exit 1` se falharem (integrável em CI/hook).

### 1. `_temp/_validar_sql_basico.mjs` — integridade lexical

Verifica por cada ficheiro SQL passado como argumento:
- **aspas pares por linha** — cada linha tem nº par de `'` (apanha apóstrofos
  não-escapados como o `warfarin's` que rompeu a string na 267);
- **parênteses equilibrados fora de strings** — depth final 0 e nunca negativo
  (apanha tuples sem `)` de fecho, como aconteceu na 270).

```bash
# um ficheiro ou vários
node _temp/_validar_sql_basico.mjs supabase/migrations/267_interacoes_lote23_lnme.sql
node _temp/_validar_sql_basico.mjs supabase/migrations/26[89]*.sql supabase/migrations/27*.sql
```

Saída por ficheiro: `OK   <ficheiro>` ou `FAIL <ficheiro> <detalhe>`, seguido de
`=== TODOS OK ===` / `=== FALHOU ===`.

### 2. `_temp/_auditar_bloco.mjs` — nº de campos por tuple nos blocos VALUES

Valida que **cada tuple de cada bloco `FROM/JOIN (VALUES ... ) AS v(...)` tem
exactamente o mesmo nº de valores de topo que o nº de aliases do `AS v(...)`** —
ou seja, apanha o ERRO 8 e o ERRO 4 automaticamente. Suporta múltiplos blocos
por ficheiro (ex.: 268 tem o bloco de INSERT + o bloco do UPDATE de class_id)
e ignora linhas de comentário `--`.

```bash
node _temp/_auditar_bloco.mjs supabase/migrations/265_lote3_lnme_perfis.sql
# saída:
# --- bloco (VALUES na linha 24, 13 colunas, 13 tuples)
# OK  clomifeno valores: 13 | esperado: 13
# *** MISMATCH *** testosterona valores: 15 | esperado: 13   ← ERRO 8 apanhado
# === TODOS OS BLOCOS OK === / === FALHOU ===
```

### 3. `_temp/_validar_267.mjs` — validador dedicado de interações (LEAST/GREATEST)

Para migrações de pares `drug_interactions` no padrão 259/267/271/272:
conta tuples `(LEAST(`, fechos `'published', now()`, severidades válidas,
refs de slug (= tuples × 4), pares únicos (sem duplicados) e idempotência.

```bash
node _temp/_validar_267.mjs
```

### Sequência recomendada antes de commit de qualquer migração

```bash
# 1. lexical (aspas + parênteses)
node _temp/_validar_sql_basico.mjs supabase/migrations/<ficheiro>.sql

# 2. blocos VALUES vs colunas (apanha ERRO 4 e ERRO 8)
node _temp/_auditar_bloco.mjs supabase/migrations/<ficheiro>.sql

# 3. se for migração de interações (padrão LEAST/GREATEST):
node _temp/_validar_267.mjs   # editar o caminho para o ficheiro novo

# 4. contra a BD real (service key em .env.local): pares já existentes?
node --input-type=module -e "... query drug_interactions ..."   # ver 267/271/272

# 5. só depois: git add + commit + push
```

**Histórico:** os validadores 1 e 2 foram criados a 2026-09-30 depois de
apanharem, em ficheiros já comitados, um apóstrofo não-escapado (267), tuples
sem `)` de fecho (270) e o ERRO 8 na 265 — corrigidos nos commits `b34c2ec`,
`cbbae09` e seguintes.
