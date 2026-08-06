#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Verificação pós-ligação: conta registos com o campo de ligação preenchido."""
import os, json, urllib.parse, urllib.request

BASE_ID = os.environ.get('AIRTABLE_BASE_ID', '')
PAT = os.environ.get('AIRTABLE_PAT', '')

def q(s): return urllib.parse.quote(s, safe='')

def get(path):
    if not BASE_ID or not PAT:
        raise SystemExit('Define AIRTABLE_BASE_ID e AIRTABLE_PAT no ambiente.')
    req = urllib.request.Request('https://api.airtable.com/v0' + path, method='GET')
    req.add_header('Authorization', 'Bearer ' + PAT)
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read().decode('utf-8'))

CHECKS = [
    ('Interações Fármaco-Fármaco', 'farmaco_a', 384),
    ('Interações Fármaco-Fármaco', 'farmaco_b', 384),
    ('Interações Alimento/Bebida', 'farmaco', 116),
    ('Interações Doença', 'farmaco', 198),
    ('Interações Doença', 'doenca', 198),
    ('Gravidez/Lactação', 'farmaco', 102),
]
def get_all(table, field):
    out = []
    offset = None
    while True:
        qs = 'fields%5B%5D=' + q(field)
        if offset:
            qs += '&offset=' + urllib.parse.quote(offset, safe='')
        d = get('/' + q(BASE_ID) + '/' + q(table) + '?' + qs)
        out.extend(d['records'])
        offset = d.get('offset')
        if not offset:
            return out

for table, field, expected in CHECKS:
    data = get_all(table, field)
    filled = sum(1 for r in data if r['fields'].get(field))
    print(f'{table}.{field}: {filled}/{len(data)} preenchidos (esperado ~{expected})')