/**
 * SM-2 (Anki-style) — repetição espaçada para flashcards.
 *
 * Função pura, sem dependências. Estado de cada cartão:
 *   ease        (1.3–5.0)  fator de facilidade, default 2.5
 *   intervalDays           intervalo atual em dias (0 = novo/primeira vez)
 *   repetitions            repetições consecutivas com grade ≥ 2
 *   lapses                 vezes que o cartão voltou a zero
 *
 * Grades (dos 4 botões da UI):
 *   0 = Outra vez (again)   1 = Difícil (hard)   2 = Boa (good)   3 = Fácil (easy)
 *
 * Intervalos de referência:
 *   - again  → 0 dias (volta à sessão; intervalo < 1 min na prática)
 *   - 1ª good → 1 dia · 2ª good → 6 dias · 3ª+ → ×ease (arredondado)
 *   - hard    → ×1.2 · easy → ×ease × 1.3
 */
export const SM2_DEFAULTS = { ease: 2.5, intervalDays: 0, repetitions: 0, lapses: 0 }

export const SM2_MAX_INTERVAL_DAYS = 365
const MIN_EASE = 1.3
const MAX_EASE = 5.0
const EASE_STEP = 0.15

/** Arredonda intervalos como o Anki (para cima a múltiplos de 1 dia; ≥ 1). */
function roundInterval(days) {
  if (days <= 0) return 0
  const rounded = Math.max(1, Math.round(days))
  return Math.min(rounded, SM2_MAX_INTERVAL_DAYS)
}

/**
 * Calcula o próximo estado após uma resposta.
 * @param {0|1|2|3} grade
 * @param {Partial<{ease:number, intervalDays:number, repetitions:number, lapses:number}>} state
 * @returns {{ease:number, intervalDays:number, repetitions:number, lapses:number, dueAt:Date, isLapse:boolean}}
 */
export function sm2Next(grade, state = {}) {
  const s = {
    ease: typeof state.ease === 'number' ? state.ease : SM2_DEFAULTS.ease,
    intervalDays: state.intervalDays || 0,
    repetitions: state.repetitions || 0,
    lapses: state.lapses || 0,
  }

  // Grade inválida — devolve o estado inalterado (defensivo)
  if (![0, 1, 2, 3].includes(grade)) {
    return {
      ...s,
      ease: clampEase(s.ease),
      intervalDays: Math.min(s.intervalDays, SM2_MAX_INTERVAL_DAYS),
      dueAt: new Date(),
      isLapse: false,
    }
  }

  let ease = clampEase(s.ease)
  let { intervalDays, repetitions, lapses } = s
  let isLapse = false

  if (grade === 0) {
    // Outra vez — reset total (lapse se o cartão já tinha progresso)
    isLapse = s.repetitions > 0 || s.intervalDays > 0
    repetitions = 0
    intervalDays = 0
    lapses += 1
    ease = clampEase(ease - EASE_STEP)
  } else if (grade === 1) {
    // Difícil — sem reset total, mas intervalo curto
    repetitions = Math.max(1, repetitions + 1)
    intervalDays =
      repetitions === 1 ? 1 : roundInterval(intervalDays * 1.2)
    ease = clampEase(ease - EASE_STEP)
  } else if (grade === 2) {
    // Boa — progressão padrão
    repetitions += 1
    if (repetitions === 1) intervalDays = 1
    else if (repetitions === 2) intervalDays = 6
    else intervalDays = roundInterval(intervalDays * ease)
  } else {
    // Fácil
    repetitions += 1
    if (repetitions === 1) intervalDays = 4
    else intervalDays = roundInterval(intervalDays * ease * 1.3)
    ease = clampEase(ease + EASE_STEP)
  }

  const dueAt = new Date(Date.now() + intervalDays * 24 * 60 * 60 * 1000)
  return { ease, intervalDays, repetitions, lapses, dueAt, isLapse }
}

function clampEase(ease) {
  if (!Number.isFinite(ease)) return SM2_DEFAULTS.ease
  return Math.min(MAX_EASE, Math.max(MIN_EASE, ease))
}

/** Formata um intervalo em texto humano PT ("<1 min", "6 dias", "3 semanas"). */
export function formatInterval(days) {
  if (days <= 0) return '<1 min'
  if (days < 7) return `${days} ${days === 1 ? 'dia' : 'dias'}`
  if (days < 30) {
    const weeks = Math.round(days / 7)
    return `${weeks} ${weeks === 1 ? 'semana' : 'semanas'}`
  }
  if (days < 365) {
    const months = Math.round(days / 30)
    return `${months} ${months === 1 ? 'mês' : 'meses'}`
  }
  return '1 ano'
}
