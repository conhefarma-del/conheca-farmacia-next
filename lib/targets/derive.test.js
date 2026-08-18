import { test } from 'node:test'
import assert from 'node:assert/strict'
import {
  normalizeName,
  drugSearchNames,
  splitList,
  matchItem,
  deriveRolesForTarget,
  findAutoInteraction,
} from './derive.js'

// ---- normalizeName ----
test('normalizeName remove acentos e normaliza', () => {
  assert.equal(normalizeName('Ácido acetilsalicílico'), 'acido acetilsalicilico')
  assert.equal(normalizeName('CETOCONAZOL'), 'cetoconazol')
  assert.equal(normalizeName('  Erva-de-São-João  '), 'erva de sao joao')
  assert.equal(normalizeName(''), '')
})

// ---- drugSearchNames ----
test('drugSearchNames usa nome + aliases, mais longo primeiro', () => {
  const drug = { name_pt: 'Ácido acetilsalicílico', aliases: ['Aspirina', 'AAS'] }
  const names = drugSearchNames(drug)
  assert.equal(names[0], 'acido acetilsalicilico')
  assert.ok(names.includes('aspirina'))
  assert.ok(names.includes('aas'))
})

test('drugSearchNames deduplica', () => {
  const drug = { name_pt: 'Cetoconazol', aliases: ['Nizoral', 'Cetoconazol'] }
  const names = drugSearchNames(drug)
  assert.equal(names.length, 2)
})

// ---- splitList ----
test('splitList separa por vírgulas e limpa parênteses', () => {
  const items = splitList('Inibidores: cetoconazol, itraconazol, fluconazol (fraco), sumo de toranja.')
  assert.deepEqual(items, ['cetoconazol', 'itraconazol', 'fluconazol', 'sumo de toranja'])
})

test('splitList sem prefixo', () => {
  assert.deepEqual(splitList('digoxina, dabigatrano, rivaroxabano (parcial)'), ['digoxina', 'dabigatrano', 'rivaroxabano'])
})

// ---- matchItem ----
const drugs = [
  { id: 'd1', slug: 'simvastatina', name_pt: 'Simvastatina', aliases: ['Zocor'] },
  { id: 'd2', slug: 'cetoconazol', name_pt: 'Cetoconazol', aliases: ['Nizoral'] },
  { id: 'd3', slug: 'rifampicina', name_pt: 'Rifampicina', aliases: ['Rifadin'] },
  { id: 'd4', slug: 'acido-acetilsalicilico', name_pt: 'Ácido acetilsalicílico', aliases: ['Aspirina', 'AAS'] },
  { id: 'd5', slug: 'digoxina', name_pt: 'Digoxina', aliases: ['Digoxin'] },
]

test('matchItem casa nome direto', () => {
  const searchNames = drugs.map((d) => ({ slug: d.slug, names: drugSearchNames(d) }))
  assert.equal(matchItem('cetoconazol', searchNames), 'cetoconazol')
  assert.equal(matchItem('Simvastatina', searchNames), 'simvastatina')
})

test('matchItem casa por alias (aspirina → AAS)', () => {
  const searchNames = drugs.map((d) => ({ slug: d.slug, names: drugSearchNames(d) }))
  assert.equal(matchItem('aspirina', searchNames), 'acido-acetilsalicilico')
})

test('matchItem devolve null para não-fármacos', () => {
  const searchNames = drugs.map((d) => ({ slug: d.slug, names: drugSearchNames(d) }))
  assert.equal(matchItem('sumo de toranja', searchNames), null)
  assert.equal(matchItem('erva-de-são-joão', searchNames), null)
  assert.equal(matchItem('ácido araquidónico', searchNames), null)
})

// ---- deriveRolesForTarget ----
test('deriva substrato/inibidor/indutor de CYP3A4 com dados reais', () => {
  const target = {
    id: 't1',
    slug: 'cyp3a4',
    substrates_pt: 'Substratos: simvastatina, atorvastatina, ciclosporina, claritromicina, sildenafil.',
    inhibitors_pt: 'Inibidores: cetoconazol, itraconazol, claritromicina, ritonavir, sumo de toranja.',
    inducers_pt: 'Indutores: rifampicina, carbamazepina, erva-de-são-joão (hipericão).',
    source_pt: 'DailyMed/FDA — rótulo aprovado.',
  }
  const roles = deriveRolesForTarget(target, drugs)
  assert.ok(roles.some((r) => r.role === 'substrate' && r.drugSlug === 'simvastatina'))
  assert.ok(roles.some((r) => r.role === 'inhibitor' && r.drugSlug === 'cetoconazol'))
  assert.ok(roles.some((r) => r.role === 'inducer' && r.drugSlug === 'rifampicina'))
  // sumo de toranja e erva-de-são-joão NÃO geram linhas
  assert.ok(!roles.some((r) => r.drugSlug === 'sumo-de-toranja'))
  // source preenchido
  const cet = roles.find((r) => r.role === 'inhibitor' && r.drugSlug === 'cetoconazol')
  assert.equal(cet.source, 'DailyMed/FDA — rótulo aprovado.')
})

test('deriva substrato P-gp com digoxina', () => {
  const target = {
    id: 't2',
    slug: 'p-gp',
    substrates_pt: 'Substratos: digoxina, dabigatrano, loperamida, colchicina.',
    inhibitors_pt: 'Inibidores: amiodarona, claritromicina, ritonavir.',
    inducers_pt: 'Indutores: rifampicina.',
    source_pt: 'EMC-UK.',
  }
  const roles = deriveRolesForTarget(target, drugs)
  assert.ok(roles.some((r) => r.role === 'substrate' && r.drugSlug === 'digoxina'))
})

test('inibidor que também é substrato deteta auto-interação', () => {
  const roles = [
    { targetId: 't1', role: 'substrate' },
    { targetId: 't1', role: 'inhibitor' },
    { targetId: 't2', role: 'substrate' },
  ]
  const auto = findAutoInteraction(roles)
  assert.ok(auto)
  assert.equal(auto.targetId, 't1')
  assert.ok(auto.roles.includes('substrate') && auto.roles.includes('inhibitor'))
})

test('sem auto-interação quando papéis em alvos distintos', () => {
  const roles = [
    { targetId: 't1', role: 'substrate' },
    { targetId: 't2', role: 'inhibitor' },
  ]
  assert.equal(findAutoInteraction(roles), null)
})

test('sem auto-interação com < 2 linhas', () => {
  assert.equal(findAutoInteraction([{ targetId: 't1', role: 'substrate' }]), null)
  assert.equal(findAutoInteraction([]), null)
})
