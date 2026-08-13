import assert from 'node:assert/strict'
import { buildFront, simplifyText, FRONT_TEMPLATES } from './simplify.js'

let passed = 0
function ok(name, fn) {
  fn()
  passed++
  console.log('OK', name)
}

// ---- buildFront -------------------------------------------------------
ok('mecanismo PT', () => {
  assert.equal(buildFront('mecanismo', { drug: 'Ibuprofeno' }, 'pt'), 'Como atua o Ibuprofeno no organismo?')
})
ok('classe PT', () => {
  assert.equal(buildFront('classe', { drug: 'Ibuprofeno' }, 'pt'), 'A que grupo de medicamentos pertence o Ibuprofeno?')
})
ok('perfil PT', () => {
  assert.equal(
    buildFront('perfil', { drug: 'Ibuprofeno' }, 'pt'),
    'Para que serve o Ibuprofeno? (visão geral e indicação)'
  )
})
ok('interação PT', () => {
  assert.equal(
    buildFront('interacao', { a: 'Amoxicilina', b: 'Ácido Clavulânico' }, 'pt'),
    'Que interação existe entre Amoxicilina e Ácido Clavulânico?'
  )
})
ok('EN templates', () => {
  assert.equal(buildFront('mecanismo', { drug: 'Ibuprofen' }, 'en'), 'How does Ibuprofen work in the body?')
  assert.equal(
    buildFront('interacao', { a: 'A', b: 'B' }, 'en'),
    'What interaction exists between A and B?'
  )
})
ok('tipo desconhecido devolve vazio', () => {
  assert.equal(buildFront('manual', { drug: 'X' }), '')
})

// ---- simplifyText (PT) ------------------------------------------------
ok('fármaco → medicamento', () => {
  assert.equal(simplifyText('O fármaco é administrado por via oral.'), 'O medicamento é administrado por via oral.')
})
ok('fármacos plural → medicamentos', () => {
  assert.equal(simplifyText('Estes fármacos atuam no SNC.'), 'Estes medicamentos atuam no SNC.')
})
ok('pró-fármaco NÃO é alterado', () => {
  assert.equal(simplifyText('É um pró-fármaco ativo no fígado.'), 'É um pró-fármaco ativo no fígado.')
})
ok('fármaco-fármaco NÃO é alterado', () => {
  assert.equal(simplifyText('interação fármaco-fármaco grave'), 'interação fármaco-fármaco grave')
})
ok('dentro de palavra NÃO é alterado (farmacológico)', () => {
  assert.equal(simplifyText('perfil farmacológico do medicamento'), 'perfil farmacológico do medicamento')
})
ok('sem alteração quando não há termos mapeados', () => {
  const s = 'Inibe a síntese de prostaglandinas (COX).'
  assert.equal(simplifyText(s), s)
})
ok('null/undefined devolvem como estão', () => {
  assert.equal(simplifyText(null), null)
  assert.equal(simplifyText(undefined), undefined)
})

// ---- simplifyText (EN) ------------------------------------------------
ok('drug → medicine (EN)', () => {
  assert.equal(simplifyText('The drug is taken orally.', 'en'), 'The medicine is taken orally.')
})
ok('drug-drug NÃO é alterado (EN)', () => {
  assert.equal(simplifyText('drug-drug interaction', 'en'), 'drug-drug interaction')
})
ok('prodrug NÃO é alterado (EN)', () => {
  assert.equal(simplifyText('a prodrug of', 'en'), 'a prodrug of')
})

// ---- FRONT_TEMPLATES cobrem os 4 tipos em PT/EN ----------------------
ok('templates PT/EN completos', () => {
  for (const type of ['mecanismo', 'classe', 'perfil', 'interacao']) {
    assert.ok(FRONT_TEMPLATES[type].pt && FRONT_TEMPLATES[type].en, type)
  }
})

console.log(`\n${passed} testes passaram`)
