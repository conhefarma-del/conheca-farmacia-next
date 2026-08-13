/**
 * Engine puro do Quiz (plano 2026-08-13-quiz, T2).
 *
 * Sem I/O: recebe pools de dados reais (ver lib/api/quiz.js) e constrói
 * sessões MCQ. Regras de segurança:
 *  - resposta correta é SEMPRE um valor real do dataset;
 *  - distratores são valores reais de outros registos (nunca inventados);
 *  - sem distrator repetido; opções embaralhadas;
 *  - o cliente nunca recebe o `correctIndex` (validado no servidor).
 */

// Embaralha uma cópia do array (Fisher–Yates).
export function shuffle(arr, rng = Math.random) {
  const a = [...arr]
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1))
    ;[a[i], a[j]] = [a[j], a[i]]
  }
  return a
}

// Normalização para comparar respostas (case + espaços).
export function normalizeAnswer(value) {
  return String(value || '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim()
}

// Compara a resposta escolhida com a correta (tolerante a espaços/caixa).
export function sameAnswer(a, b) {
  return normalizeAnswer(a) === normalizeAnswer(b) && normalizeAnswer(a) !== ''
}

/**
 * Escolhe n distratores reais de um pool, excluindo valores iguais ao
 * correto (normalizado) e duplicados entre si.
 */
export function pickDistractors(pool, correct, n = 3, rng = Math.random) {
  const target = normalizeAnswer(correct)
  const unique = []
  const seen = new Set([target])
  for (const v of pool) {
    if (v == null) continue
    const k = normalizeAnswer(v)
    if (!k || k === target || seen.has(k)) continue
    seen.add(k)
    unique.push(v)
  }
  return shuffle(unique, rng).slice(0, n)
}

/**
 * Monta a pergunta MCQ (interna — inclui correctIndex).
 * options.pool são os valores reais candidatos a distratores.
 */
function makeQuestion({ key, type, question, correct, pool, explanation, source, rng }) {
  const distractors = pickDistractors(pool, correct, 3, rng)
  const options = shuffle([correct, ...distractors], rng)
  return {
    key,
    type,
    question,
    options,
    correctIndex: options.findIndex((o) => sameAnswer(o, correct)),
    explanation: explanation || '',
    source: source || '',
  }
}

// ---- Construtores por fonte -------------------------------------------------

// A partir de um cartão de flashcards (front → resposta = back).
export function buildFlashcardQuestion(card, deckCards, rng) {
  return makeQuestion({
    key: `flashcard:${card.id}`,
    type: 'flashcard',
    question: card.front,
    correct: card.back,
    pool: deckCards.map((c) => c.back),
    explanation: card.sourceNote || '',
    source: card.sourceNote || 'Flashcards',
    rng,
  })
}

// Farmacologia: classe / mecanismo / meia-vida.
export function buildPharmacologyQuestion(drug, pool, field, rng) {
  const config = {
    classe: { key: 'class_pt', label: 'Classificação interna (drugs.class_pt)' },
    mecanismo: { key: 'mechanism_pt', label: 'Farmacologia interna' },
    meia_vida: { key: 'half_life_pt', label: 'Farmacologia interna' },
  }[field]
  if (!config) return null
  const correct = drug[config.key]
  if (!correct || !normalizeAnswer(correct)) return null
  return makeQuestion({
    key: `pharmacology:${drug.drugId}:${field}`,
    type: 'pharmacology',
    question: field === 'mecanismo'
      ? `Como atua o ${drug.name} no organismo?`
      : field === 'classe'
        ? `A que grupo de medicamentos pertence o ${drug.name}?`
        : `Qual a meia-vida (tempo até metade do fármaco sair do organismo) do ${drug.name}?`,
    correct,
    pool: pool.map((d) => d[config.key]).filter(Boolean),
    explanation: '',
    source: config.label,
    rng,
  })
}

// Rótulo PT do grau de interação (apresentação — o valor real fica na BD)
const SEVERITY_LABELS = { critical: 'Crítico', moderate: 'Moderado', minor: 'Menor' }
export const severityLabel = (severity) => SEVERITY_LABELS[severity] || severity || ''

// Interações fármaco-fármaco (resposta = resumo real do par).
export function buildInteractionQuestion(int, pool, rng) {
  if (!int || !normalizeAnswer(int.summaryPt)) return null
  return makeQuestion({
    key: `interaction:${int.id}`,
    type: 'interaction',
    question: `Que interação existe entre ${int.a} e ${int.b}?`,
    correct: int.summaryPt,
    pool: pool.map((i) => i.summaryPt).filter(Boolean),
    explanation: int.severity ? `Grau da interação: ${severityLabel(int.severity)}` : '',
    source: 'Banco de interações',
    rng,
  })
}

// Interações alimento/bebida (resposta = entidade real).
export function buildFoodQuestion(food, pool, rng) {
  if (!food || !normalizeAnswer(food.entityPt)) return null
  return makeQuestion({
    key: `food:${food.id}`,
    type: 'interaction',
    question: `Com que alimento/bebida interage o ${food.drugName}?`,
    correct: food.entityPt,
    pool: pool.map((f) => f.entityPt).filter(Boolean),
    explanation: '',
    source: 'Banco de interações (alimentos)',
    rng,
  })
}

// Interações doença/condição (resposta = condição real).
export function buildDiseaseQuestion(disease, pool, rng) {
  if (!disease || !normalizeAnswer(disease.conditionPt)) return null
  return makeQuestion({
    key: `disease:${disease.id}`,
    type: 'interaction',
    question: `Com que condição/doença interage o ${disease.drugName}?`,
    correct: disease.conditionPt,
    pool: pool.map((d) => d.conditionPt).filter(Boolean),
    explanation: '',
    source: 'Banco de interações (doenças)',
    rng,
  })
}

// Protocolos — perguntas já curadas (clinical_protocol_quizzes, 4 opções).
export function buildProtocolQuestion(pq, rng) {
  if (!pq || !pq.options || pq.options.length < 2) return null
  const correct = pq.options[pq.correctIndex]
  if (!correct || !normalizeAnswer(correct)) return null
  return makeQuestion({
    key: `protocol:${pq.id}`,
    type: 'protocol',
    question: pq.question,
    correct,
    pool: pq.options.filter((o) => o != null && String(o).trim() !== ''),
    explanation: pq.explanation || '',
    source: pq.protocolTitle ? `Protocolo: ${pq.protocolTitle}` : 'Protocolos clínicos',
    rng,
  })
}

// ---- Níveis de dificuldade ----------------------------------------------
// Cada nível tem um número de perguntas e uma quota por categoria (as
// categorias mais "difíceis" entram apenas nos níveis superiores):
//   fácil   → memória básica (flashcards + classe terapêutica)
//   médio   → soma mecanismo de ação e interações alimento/doença
//   difícil → soma meia-vida, interações fármaco-fármaco e protocolos
// As quotas somam sempre `count`. Se um pool real estiver abaixo da quota,
// o buildLevelSession faz backfill com as restantes perguntas do nível — o
// count prometido é sempre devolvido quando o pool total o permite.
export const LEVELS = {
  facil: {
    count: 8,
    quotas: { flashcard: 4, classe: 4 },
  },
  medio: {
    count: 12,
    quotas: { flashcard: 4, classe: 3, mecanismo: 3, food: 1, disease: 1 },
  },
  dificil: {
    // interações fármaco-fármaco e protocolos são as categorias "assinatura"
    // do difícil — quotas ≥ 1 garantem presença sempre que o pool tiver dados
    count: 16,
    quotas: { flashcard: 3, classe: 3, mecanismo: 3, meia_vida: 2, interaction: 3, food: 1, protocol: 1 },
  },
}

/**
 * Constrói a sessão por nível: monta todas as perguntas reais de cada
 * categoria e tira uma amostra embaralhada da quota do nível.
 *
 * Robustez: se alguma categoria estiver abaixo da quota (pool pequeno ou
 * vazio), o défice é preenchido (backfill) com as restantes perguntas das
 * outras categorias do nível — nunca devolve menos do que `count` quando o
 * pool total o permite, e as categorias "assinatura" (interaction/protocol
 * no difícil) nunca são canibalizadas pelo backfill.
 */
export function buildLevelSession({ level = 'facil', pools, rng = Math.random }) {
  const cfg = LEVELS[level] || LEVELS.facil
  const byCategory = {
    flashcard: [],
    classe: [],
    mecanismo: [],
    meia_vida: [],
    interaction: [],
    food: [],
    disease: [],
    protocol: [],
  }

  for (const deck of pools.decks) {
    for (const card of deck.cards) {
      const q = buildFlashcardQuestion(card, deck.cards, rng)
      if (q) byCategory.flashcard.push(q)
    }
  }
  for (const drug of pools.pharm) {
    for (const field of ['classe', 'mecanismo', 'meia_vida']) {
      const q = buildPharmacologyQuestion(drug, pools.pharm, field, rng)
      if (q) byCategory[field].push(q)
    }
  }
  for (const i of pools.interactions) {
    const q = buildInteractionQuestion(i, pools.interactions, rng)
    if (q) byCategory.interaction.push(q)
  }
  for (const f of pools.food) {
    const q = buildFoodQuestion(f, pools.food, rng)
    if (q) byCategory.food.push(q)
  }
  for (const d of pools.disease) {
    const q = buildDiseaseQuestion(d, pools.disease, rng)
    if (q) byCategory.disease.push(q)
  }
  for (const pq of pools.protocols) {
    const q = buildProtocolQuestion(pq, rng)
    if (q) byCategory.protocol.push(q)
  }

  const picked = []
  const leftover = []
  for (const cat of Object.keys(cfg.quotas)) {
    const avail = byCategory[cat] || []
    const quota = cfg.quotas[cat]
    const take = Math.min(quota, avail.length)
    picked.push(...shuffle(avail, rng).slice(0, take))
    // restantes desta categoria ficam disponíveis para o backfill
    leftover.push(...avail.slice(take))
  }

  // Backfill: garante o count prometido mesmo com pools abaixo da quota
  const need = Math.max(0, cfg.count - picked.length)
  if (need > 0) {
    picked.push(...shuffle(leftover, rng).slice(0, need))
  }

  return shuffle(picked, rng)
}

/**
 * Constrói a sessão de quiz a partir dos pools.
 * @returns Array de perguntas { key, type, question, options, correctIndex,
 *   explanation, source } — o action remove correctIndex antes de enviar.
 */
export function buildSession({ mode = 'rapido', level = 'facil', deckSlug = '', source = 'mixed', count = 10, pools, rng = Math.random }) {
  const all = []
  const safeCount = Math.max(5, Math.min(30, Number(count) || 10))

  if (mode === 'nivel') {
    return buildLevelSession({ level, pools, rng })
  }

  if (mode === 'deck') {
    const deck = pools.decks.find((d) => d.slug === deckSlug)
    if (deck) {
      for (const card of deck.cards) {
        const q = buildFlashcardQuestion(card, deck.cards, rng)
        if (q) all.push(q)
      }
    }
  } else if (mode === 'tipo') {
    if (source === 'pharmacology') {
      for (const drug of pools.pharm) {
        for (const field of ['classe', 'mecanismo', 'meia_vida']) {
          const q = buildPharmacologyQuestion(drug, pools.pharm, field, rng)
          if (q) all.push(q)
        }
      }
    } else if (source === 'interaction') {
      for (const int of pools.interactions) {
        const q = buildInteractionQuestion(int, pools.interactions, rng)
        if (q) all.push(q)
      }
      for (const f of pools.food) {
        const q = buildFoodQuestion(f, pools.food, rng)
        if (q) all.push(q)
      }
      for (const d of pools.disease) {
        const q = buildDiseaseQuestion(d, pools.disease, rng)
        if (q) all.push(q)
      }
    } else if (source === 'protocol') {
      for (const pq of pools.protocols) {
        const q = buildProtocolQuestion(pq, rng)
        if (q) all.push(q)
      }
    } else {
      // flashcard — todos os decks
      for (const deck of pools.decks) {
        for (const card of deck.cards) {
          const q = buildFlashcardQuestion(card, deck.cards, rng)
          if (q) all.push(q)
        }
      }
    }
  } else {
    // rapido — mistura de todas as fontes
    for (const deck of pools.decks) {
      for (const card of deck.cards) {
        const q = buildFlashcardQuestion(card, deck.cards, rng)
        if (q) all.push(q)
      }
    }
    for (const drug of pools.pharm) {
      for (const field of ['classe', 'mecanismo', 'meia_vida']) {
        const q = buildPharmacologyQuestion(drug, pools.pharm, field, rng)
        if (q) all.push(q)
      }
    }
    for (const int of pools.interactions) {
      const q = buildInteractionQuestion(int, pools.interactions, rng)
      if (q) all.push(q)
    }
    for (const f of pools.food) {
      const q = buildFoodQuestion(f, pools.food, rng)
      if (q) all.push(q)
    }
    for (const d of pools.disease) {
      const q = buildDiseaseQuestion(d, pools.disease, rng)
      if (q) all.push(q)
    }
    for (const pq of pools.protocols) {
      const q = buildProtocolQuestion(pq, rng)
      if (q) all.push(q)
    }
  }

  return shuffle(all, rng).slice(0, safeCount)
}

/** Pontuação: answers = array de booleanos. */
export function score(answers) {
  const total = answers.length
  const correct = answers.filter(Boolean).length
  return {
    correct,
    total,
    pct: total > 0 ? Math.round((correct / total) * 100) : 0,
  }
}
