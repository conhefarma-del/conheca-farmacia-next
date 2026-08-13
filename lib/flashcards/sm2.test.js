import { sm2Next, formatInterval } from './sm2.js'

function daysUntil(dueAt) {
  return Math.round((dueAt - Date.now()) / (24 * 60 * 60 * 1000))
}

let failures = 0
function check(label, actual, expected) {
  const ok = JSON.stringify(actual) === JSON.stringify(expected)
  if (!ok) {
    failures += 1
    console.error(`✗ ${label}\n  esperado: ${JSON.stringify(expected)}\n  obtido:   ${JSON.stringify(actual)}`)
  } else {
    console.log(`✓ ${label}`)
  }
}

// ---- Sequência "Boa, Boa, Boa" → 1, 6, ~15 dias (ease 2.5 → 6×2.5=15) ----
let s = sm2Next(2, {})
check('primeira Boa → 1 dia', { i: s.intervalDays, r: s.repetitions }, { i: 1, r: 1 })
s = sm2Next(2, s)
check('segunda Boa → 6 dias', { i: s.intervalDays, r: s.repetitions }, { i: 6, r: 2 })
s = sm2Next(2, s)
check('terceira Boa → 15 dias', { i: s.intervalDays, r: s.repetitions }, { i: 15, r: 3 })

// ---- Outra vez → reset + lapse + ease −0.15 ----
s = sm2Next(0, { ease: 2.5, intervalDays: 15, repetitions: 3, lapses: 0 })
check('Outra vez reseta', { i: s.intervalDays, r: s.repetitions, l: s.lapses }, { i: 0, r: 0, l: 1 })
check('Outra vez baixa ease', Math.round(s.ease * 100) / 100, 2.35)

// ---- Difícil não reseta totalmente ----
s = sm2Next(1, { ease: 2.5, intervalDays: 15, repetitions: 3, lapses: 0 })
check('Difícil → ×1.2 (18 dias)', s.intervalDays, 18)

// ---- Fácil → ×ease×1.3 ----
s = sm2Next(3, { ease: 2.5, intervalDays: 6, repetitions: 2, lapses: 0 })
check('Fácil → 6×2.5×1.3 ≈ 20 dias', s.intervalDays, 20)

// ---- Ease mínimo 1.3 ----
s = sm2Next(0, { ease: 1.3, intervalDays: 0, repetitions: 0, lapses: 5 })
check('ease não desce abaixo de 1.3', s.ease, 1.3)

// ---- Intervalo máximo 365 ----
s = sm2Next(2, { ease: 5.0, intervalDays: 364, repetitions: 10, lapses: 0 })
check('intervalo não passa de 365', s.intervalDays, 365)

// ---- Grade inválida → estado preservado ----
s = sm2Next(9, { ease: 2.5, intervalDays: 6, repetitions: 2, lapses: 0 })
check('grade inválida preserva estado', { i: s.intervalDays, e: s.ease }, { i: 6, e: 2.5 })

// ---- dueAt futuro para grade boa ----
s = sm2Next(2, {})
check('dueAt ~1 dia à frente', daysUntil(s.dueAt), 1)

// ---- formatInterval ----
check('format 0', formatInterval(0), '<1 min')
check('format 1', formatInterval(1), '1 dia')
check('format 8', formatInterval(8), '1 semana')
check('format 30', formatInterval(30), '1 mês')
check('format 400', formatInterval(400), '1 ano')

if (failures > 0) {
  console.error(`\n${failures} teste(s) falharam`)
  process.exit(1)
}
console.log('\nTodos os testes SM-2 passaram ✓')
