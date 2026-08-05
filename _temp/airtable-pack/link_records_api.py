#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Liga registos no Airtable por slug/id via REST API — alternativa à extensão
Scripting (mais fiável, sem dependências externas).

Uso:
    python link_records_api.py            # pré-visualiza (dry-run, não escreve)
    python link_records_api.py --run      # aplica as ligações

Configuração: preenche AIRTABLE_BASE_ID e AIRTABLE_PAT abaixo, ou define-as
como variáveis de ambiente.
"""
import json
import os
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

# --- Configuração -----------------------------------------------------------
BASE_ID = os.environ.get('AIRTABLE_BASE_ID', '')  # ex.: app9xxxxxxxxxxxxxx
PAT     = os.environ.get('AIRTABLE_PAT', '')      # ex.: pat5xxxxxxxxxxxxxxxxx
# ----------------------------------------------------------------------------

API = 'https://api.airtable.com/v0'

# (tabela_origem, campo_de_origem, campo_de_ligacao_a_preencher, tabela_alvo)
RELS = [
    ('Interações Fármaco-Fármaco', 'farmaco_a_slug', 'farmaco_a', 'Fármacos'),
    ('Interações Fármaco-Fármaco', 'farmaco_b_slug', 'farmaco_b', 'Fármacos'),
    ('Interações Alimento/Bebida', 'farmaco_slug', 'farmaco', 'Fármacos'),
    ('Interações Doença', 'farmaco_slug', 'farmaco', 'Fármacos'),
    ('Interações Doença', 'doenca_slug', 'doenca', 'Doenças'),
    ('Gravidez/Lactação', 'farmaco_slug', 'farmaco', 'Fármacos'),
]


def q(s):
    return urllib.parse.quote(s, safe='')


def api_call(method, path, body=None):
    url = API + path
    data = json.dumps(body).encode('utf-8') if body is not None else None
    req = urllib.request.Request(url, data=data, method=method)
    req.add_header('Authorization', 'Bearer ' + PAT)
    req.add_header('Content-Type', 'application/json')
    try:
        with urllib.request.urlopen(req) as resp:
            return json.loads(resp.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        msg = e.read().decode('utf-8', 'replace')
        print('ERRO HTTP', e.code, msg)
        sys.exit(1)


def get_all_records(table_name, fields):
    """Lê todos os registos de uma tabela pedindo apenas os campos indicados."""
    out = []
    offset = None
    while True:
        params = [('fields[]', f) for f in fields]
        qs = urllib.parse.urlencode(params)
        path = '/{base}/{table}?{qs}'.format(
            base=q(BASE_ID), table=q(table_name), qs=qs)
        if offset:
            path += '&offset=' + q(offset)
        data = api_call('GET', path)
        out.extend(data.get('records', []))
        offset = data.get('offset')
        if not offset:
            return out


def table_schema():
    """Devolve {nome_da_tabela: metadados} incluindo nomes exatos dos campos."""
    data = api_call('GET', '/meta/bases/' + q(BASE_ID) + '/tables')
    return {t['name']: t for t in data['tables']}


def main():
    if not BASE_ID or not PAT:
        print('Falta AIRTABLE_BASE_ID e/ou AIRTABLE_PAT.')
        print('  - BASE_ID: copia o segmento "appXXXX" do URL da tua base')
        print('  - PAT: airtable.com/create/tokens -> Create new token')
        sys.exit(1)

    run = '--run' in sys.argv
    print('Modo: ' + ('APLICAR ligações' if run else 'PRÉ-VISUALIZAÇÃO (usa --run para aplicar)'))

    tables = table_schema()

    for (from_table, from_key, link, to_table) in RELS:
        if from_table not in tables:
            print(f'AVISO: tabela "{from_table}" não existe na base — a saltar.')
            continue
        if to_table not in tables:
            print(f'AVISO: tabela "{to_table}" não existe na base — a saltar.')
            continue

        # Campo primário da tabela-alvo = o slug (pode ter BOM no nome).
        primary = tables[to_table]['fields'][0]['name']
        targets = get_all_records(to_table, [primary])
        tmap = {}
        for r in targets:
            v = r['fields'].get(primary)
            if v is not None:
                tmap[v] = r['id']

        # Confirma que o campo de ligação existe na tabela de origem (evita
        # erros 422/UNKNOWN_FIELD a meio da gravação).
        link_candidates = [f['name'] for f in tables[from_table]['fields']
                           if f['type'] == 'multipleRecordLinks']
        if link not in link_candidates:
            print(f'AVISO: campo de ligação "{link}" não existe em "{from_table}". '
                  f'Campos de ligação existentes: {link_candidates}')
            continue

        sources = get_all_records(from_table, [from_key])
        updates = []
        linked = 0
        missing = 0
        for r in sources:
            val = r['fields'].get(from_key)
            tid = None
            if isinstance(val, str):
                tid = tmap.get(val)
            elif isinstance(val, list) and val:
                first = val[0]
                tid = first.get('id') if isinstance(first, dict) else None
            if tid is not None and not isinstance(tid, str):
                print('   [debug] tid não é string:', repr(tid), 'de val:', repr(val)[:120])
                tid = None
            if tid:
                updates.append({'id': r['id'], 'fields': {link: [tid]}})
                linked += 1
            else:
                missing += 1

        print(f'{from_table} -> {to_table}: {linked} ligadas, {missing} sem alvo')

        if run and updates:
            for i in range(0, len(updates), 10):  # API permite 10 por pedido
                api_call('PATCH', '/{b}/{t}'.format(b=q(BASE_ID), t=q(from_table)),
                         {'records': updates[i:i + 10]})
                time.sleep(0.25)  # limite de 5 pedidos/segundo

    print('OK.' if run else 'Pré-visualização concluída. Corre com --run para aplicar.')


if __name__ == '__main__':
    main()
