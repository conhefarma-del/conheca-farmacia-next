/**
 * Engine puro do Quiz (plano 2026-08-13-quiz, T2).
 *
 * Sem I/O: recebe pools de dados reais (ver lib/api/quiz.js) e constrói
 * sessões MCQ. Regras de segurança:
 *  - resposta correta é SEMPRE um valor real do dataset;
 *  - distratores são valores reais de outros registos (nunca inventados);
 *  - sem distrator repetido; opções embaralhadas;
 *  - o cliente nunca recebe o `correctIndex` (validado no servidor).
 *
 * Qualidade (ver «Qualidade dos distratores», abaixo): a escolha das
 * erradas deixou de ser um sorteio do pool — passou a preferir opções com
 * comprimento, nomes e registo parecidos com a correta, para a resposta
 * não se adivinhar pela forma da opção.
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

// ---- Qualidade dos distratores ------------------------------------------
// Uma pergunta de escolha múltipla só testa conhecimento se as erradas
// forem plausíveis. Sortear distratores do pool inteiro produzia três
// problemas visíveis:
//  · a correta era a única opção comprida (respostas da BD em parágrafo);
//  · apareciam opções contidas noutras («Anti-inflamatório» vs
//    «Anti-inflamatório não esteroide»), que se eliminam por leitura;
//  · nas interações, a correta era a única a nomear os dois fármacos do
//    enunciado — acertava-se sem saber nada.
// A escolha pontua agora cada candidato real por: comprimento (ou valor
// numérico, nas meias-vidas) próximo da correta, mesma «pegada» de nomes
// próprios, registo lexical parecido e pertença ao pool preferido (mesma
// classe terapêutica / mesmo grau de gravidade). Continua a usar apenas
// valores reais — nunca inventa distratores.

const STOPWORDS = new Set([
  'de', 'da', 'do', 'das', 'dos', 'a', 'o', 'as', 'os', 'e', 'em', 'no', 'na',
  'nos', 'nas', 'com', 'por', 'para', 'que', 'um', 'uma', 'ao', 'aos', 'se',
  'sua', 'seu', 'pode', 'ser', 'não', 'mais', 'está', 'são',
])

/** Palavras significativas (sem stopwords nem pontuação) — compara registo. */
export function keywordTokens(text) {
  return normalizeAnswer(text)
    .replace(/[^\p{L}\p{N}\s]/gu, ' ')
    .split(/\s+/)
    .filter((w) => w.length > 2 && !STOPWORDS.has(w))
}

// Sobreposição normalizada pelo lado mais curto — apanha frases quase
// iguais mesmo com comprimentos diferentes.
function overlapRatio(aTokens, bTokens) {
  if (!aTokens.length || !bTokens.length) return 0
  const b = new Set(bTokens)
  const shared = aTokens.filter((t) => b.has(t)).length
  return shared / Math.min(aTokens.length, bTokens.length)
}

function lengthRatio(a, b) {
  const la = a.length
  const lb = b.length
  return la === 0 || lb === 0 ? 0 : Math.min(la, lb) / Math.max(la, lb)
}

// Uma opção que contém a outra (ou vice-versa) revela a resposta por
// eliminação — nunca é um bom distrator.
function containsEither(a, b) {
  const na = normalizeAnswer(a)
  const nb = normalizeAnswer(b)
  return na.includes(nb) || nb.includes(na)
}

function mentionCount(text, needles) {
  if (!needles?.length) return 0
  const t = normalizeAnswer(text)
  return needles.reduce((acc, n) => (n && t.includes(normalizeAnswer(n)) ? acc + 1 : acc), 0)
}

// Meias-vidas e doses: «2 h», «1,5 h», «75 mL/kg». Serve para preferir
// valores numericamente próximos (2 h → 4 h) em vez de 40 h.
function numericValue(text) {
  const s = String(text || '').replace(',', '.')
  const m = s.match(/-?\d+(?:\.\d+)?/)
  if (!m) return null
  const n = Number(m[0])
  return Number.isFinite(n) ? n : null
}

function scoreCandidate(value, correct, ctx) {
  if (containsEither(value, correct)) return -1
  const valueTokens = keywordTokens(value)
  const overlap = overlapRatio(valueTokens, ctx.correctTokens)
  if (overlap >= 0.75) return -1 // praticamente a mesma frase

  const gap = Math.abs(mentionCount(value, ctx.avoidTokens) - ctx.correctMentions)
  // Quando o enunciado nomeia fármacos, uma opção que não os nomeia (ou
  // nomeia só um) entrega a resposta: fora, a não ser que falte pool.
  if (ctx.parity && gap >= 1) return -1

  const correctNum = numericValue(correct)
  const valueNum = numericValue(value)
  const bothShort = String(correct).length <= 24 && String(value).length <= 24
  const closeness =
    bothShort && correctNum != null && valueNum != null
      ? 1 / (1 + Math.abs(valueNum - correctNum) / Math.max(1e-9, Math.abs(correctNum)))
      : lengthRatio(String(value), String(correct))

  const mention = 1 / (1 + gap)
  const register = overlap >= 0.12 ? 1 : 0
  const preferred = ctx.preferredSet.has(normalizeAnswer(value)) ? 1 : 0

  return 3 * closeness + 2 * mention + 0.75 * register + 1.5 * preferred
}

/** Pontua um candidato a distrator (-1 = descartado). Usado nos testes. */
export function scoreDistractor(value, correct, { avoidTokens = [], preferredPool = [] } = {}) {
  if (value == null || !normalizeAnswer(value)) return -1
  if (normalizeAnswer(value) === normalizeAnswer(correct)) return -1
  return scoreCandidate(value, correct, {
    correctTokens: keywordTokens(correct),
    correctMentions: mentionCount(correct, avoidTokens),
    avoidTokens,
    parity: avoidTokens.length > 0,
    preferredSet: new Set(preferredPool.map(normalizeAnswer)),
  })
}

/**
 * Escolhe n distratores reais e ranqueados por plausibilidade.
 * `ranked: false` mantém o sorteio puro — só para os protocolos, cujas
 * opções são curadas e têm de entrar todas.
 */
export function selectDistractors(
  pool,
  correct,
  { n = 3, rng = Math.random, avoidTokens = [], preferredPool = [], ranked = true, requireAllTokens = false } = {},
) {
  const target = normalizeAnswer(correct)
  const seen = new Set([target])
  const candidates = []
  for (const v of ranked ? [...(preferredPool || []), ...(pool || [])] : pool || []) {
    if (v == null) continue
    const k = normalizeAnswer(v)
    if (!k || k === target || seen.has(k)) continue
    seen.add(k)
    candidates.push(v)
  }
  if (!ranked) return shuffle(candidates, rng).slice(0, n)

  const ctx = {
    correctTokens: keywordTokens(correct),
    correctMentions: mentionCount(correct, avoidTokens),
    avoidTokens,
    // Só as interações exigem que a opção nomeie o par do enunciado: nos
    // textos clínicos da farmacologia cada opção nomeia o seu próprio
    // medicamento, e exigir o nome do enunciado esvaziava o pool.
    parity: requireAllTokens && avoidTokens.length > 0,
    preferredSet: new Set((preferredPool || []).map(normalizeAnswer)),
  }

  const rank = (withParity) => {
    const list = []
    for (const v of candidates) {
      const s = scoreCandidate(v, correct, withParity === ctx.parity ? ctx : { ...ctx, parity: withParity })
      if (Number.isFinite(s) && s >= 0) list.push({ v, s })
    }
    return list.sort((a, b) => b.s - a.s)
  }

  // Se ninguém cumprir a regra dos nomes, ordena sem ela (em vez de sortear
  // opções ao acaso, que é o que tornava as respostas evidentes).
  let scored = rank(true)
  if (scored.length === 0 && ctx.parity) scored = rank(false)
  if (scored.length === 0) return shuffle(candidates, rng).slice(0, n)
  // Só entra quem fica perto do melhor candidato: as opções manifestamente
  // piores (muito curtas/longas ou de outro registo) saem, sem deixar de
  // haver variedade entre sessões.
  const best = scored[0].s
  const eligible = scored.filter((x) => x.s >= best * 0.6).map((x) => x.v)
  const rest = scored.filter((x) => x.s < best * 0.6).map((x) => x.v)

  const chosen = shuffle(eligible, rng).slice(0, n)
  if (chosen.length < n) {
    // Pool curto ou homogéneo: completa com os restantes valores reais.
    for (const v of shuffle(rest, rng)) {
      if (chosen.length >= n) break
      if (chosen.some((c) => sameAnswer(c, v))) continue
      chosen.push(v)
    }
  }
  return chosen
}

/** Compatibilidade: n distratores reais sem ranking (sorteio). */
export function pickDistractors(pool, correct, n = 3, rng = Math.random) {
  return selectDistractors(pool, correct, { n, rng, ranked: false })
}

/**
 * Monta a pergunta MCQ (interna — inclui correctIndex).
 * options.pool são os valores reais candidatos a distratores.
 */
function makeQuestion({
  key, type, question, correct, pool,
  preferredPool = [], avoidTokens = [], strict = false, requireAllTokens = false,
  explanation, source, rng,
}) {
  const distractors = selectDistractors(pool, correct, {
    n: 3,
    rng,
    avoidTokens,
    preferredPool,
    requireAllTokens,
    ranked: !strict,
  })
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
  // Distratores do MESMO tipo de cartão. Um deck mistura cartões de
  // classe (resposta curta) com cartões de perfil (parágrafo de indicação);
  // ao sortear do deck inteiro, a correta era a única opção daquele tipo e
  // a resposta via-se pela forma. Se o tipo tiver poucos cartões, mantém-se
  // o deck completo para não ficar com menos de 4 opções.
  const sameType = card.cardType ? deckCards.filter((c) => c.cardType === card.cardType) : []
  const usableDeck = sameType.length >= 4 ? sameType : deckCards
  return makeQuestion({
    key: `flashcard:${card.id}`,
    type: 'flashcard',
    question: card.front,
    correct: card.back,
    pool: usableDeck.map((c) => c.back),
    explanation: card.sourceNote || '',
    source: card.sourceNote || 'Flashcards',
    rng,
  })
}

// Farmacologia: classe / mecanismo / meia-vida.
//
// Os enunciados usam «o medicamento X» em vez de «o X»: sem isto saíam
// frases como «Como atua o Metformina?», com o artigo do género errado.
export function buildPharmacologyQuestion(drug, pool, field, rng) {
  const config = {
    classe: { key: 'class_pt', label: 'Classificação interna (drugs.class_pt)' },
    mecanismo: { key: 'mechanism_pt', label: 'Farmacologia interna' },
    meia_vida: { key: 'half_life_pt', label: 'Farmacologia interna' },
  }[field]
  if (!config) return null
  const correct = drug[config.key]
  if (!correct || !normalizeAnswer(correct)) return null

  // Mecanismos de fármacos da MESMA classe são os distratores mais
  // plausíveis (mesmo alvo fisiológico, mecanismo diferente).
  const sameClass = (d) => {
    const a = d.class_pt || d.className || ''
    const b = drug.class_pt || drug.className || ''
    return Boolean(a && b) && normalizeAnswer(a) === normalizeAnswer(b)
  }
  const preferredPool =
    field === 'mecanismo'
      ? pool
          .filter((d) => d.drugId !== drug.drugId && sameClass(d))
          .map((d) => d.mechanism_pt)
          .filter(Boolean)
      : []

  return makeQuestion({
    key: `pharmacology:${drug.drugId}:${field}`,
    type: 'pharmacology',
    question: field === 'mecanismo'
      ? `Como atua o medicamento ${drug.name} no organismo?`
      : field === 'classe'
        ? `A que grupo pertence o medicamento ${drug.name}?`
        : `Qual é a meia-vida (tempo até metade sair do organismo) do medicamento ${drug.name}?`,
    correct,
    pool: pool.map((d) => d[config.key]).filter(Boolean),
    preferredPool,
    avoidTokens: [drug.name],
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
    // Resumos do mesmo grau têm o mesmo tom clínico — melhor distrator.
    preferredPool: pool
      .filter((i) => i.id !== int.id && i.severity && i.severity === int.severity)
      .map((i) => i.summaryPt)
      .filter(Boolean),
    // O resumo correto nomeia o par: uma opção que não o nomeie (ou que
    // nomeie só um) entrega a resposta sem se perceber o conteúdo.
    avoidTokens: [int.a, int.b],
    requireAllTokens: true,
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
    question: `Que alimento ou bebida interage com o medicamento ${food.drugName}?`,
    correct: food.entityPt,
    pool: pool.map((f) => f.entityPt).filter(Boolean),
    avoidTokens: [food.drugName],
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
    question: `Que condição ou doença exige cuidado com o medicamento ${disease.drugName}?`,
    correct: disease.conditionPt,
    pool: pool.map((d) => d.conditionPt).filter(Boolean),
    avoidTokens: [disease.drugName],
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
    // Opções curadas: entram todas, sem ranking nem filtros.
    strict: true,
    explanation: pq.explanation || '',
    source: pq.protocolTitle ? `Protocolo: ${pq.protocolTitle}` : 'Protocolos clínicos',
    rng,
  })
}

// Classes terapêuticas: "A que classe pertence o fármaco X?"
// O correct é o nome da classe (drug_classes.name_pt); distratores são
// nomes de outras classes reais do mesmo dataset.
export function buildDrugClassQuestion(drug, classesPool, rng) {
  if (!drug || !drug.className || !normalizeAnswer(drug.className)) return null
  return makeQuestion({
    key: `drug_class:${drug.drugId}`,
    type: 'drug_class',
    question: `A que classe terapêutica pertence o medicamento ${drug.name}?`,
    correct: drug.className,
    pool: classesPool.map((c) => c.name).filter(Boolean),
    avoidTokens: [drug.name],
    explanation: drug.classPrefix ? `Código ATC: ${drug.classPrefix}` : '',
    source: 'Classes terapêuticas',
    rng,
  })
}

// O `drugs.class_pt` e o `drug_classes.name_pt` respondem à mesma pergunta
// quando o texto coincide (ex.: «AINE»). Nesse caso só entra a versão de
// classe terapêutica, que traz o código ATC na explicação.
function classeRepetida(drug, pools) {
  return Boolean(
    pools?.drugClasses?.length &&
      drug.class_pt &&
      drug.className &&
      normalizeAnswer(drug.class_pt) === normalizeAnswer(drug.className),
  )
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
    quotas: { flashcard: 3, classe: 3, drug_class: 2 },
  },
  medio: {
    // Sem interações fármaco-fármaco: essas são a assinatura do difícil
    // (ver o comentário do nível), e a quota extra ia parar a «disease».
    count: 12,
    quotas: { flashcard: 3, classe: 2, drug_class: 2, mecanismo: 2, food: 1, disease: 2 },
  },
  dificil: {
    // interações fármaco-fármaco e protocolos são as categorias "assinatura"
    // do difícil — quotas ≥ 1 garantem presença sempre que o pool tiver dados
    count: 16,
    quotas: { flashcard: 2, classe: 2, drug_class: 2, mecanismo: 2, meia_vida: 2, interaction: 3, food: 1, protocol: 2 },
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
    drug_class: [],
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
      if (field === 'classe' && classeRepetida(drug, pools)) continue
      const q = buildPharmacologyQuestion(drug, pools.pharm, field, rng)
      if (q) byCategory[field].push(q)
    }
  }
  // Classes terapêuticas: "A que classe pertence o fármaco X?"
  if (pools.drugClasses) {
    for (const drug of pools.pharm) {
      const q = buildDrugClassQuestion(drug, pools.drugClasses, rng)
      if (q) byCategory.drug_class.push(q)
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
    } else if (source === 'drug_class') {
      if (pools.drugClasses) {
        for (const drug of pools.pharm) {
          const q = buildDrugClassQuestion(drug, pools.drugClasses, rng)
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
    // Classes terapêuticas
    if (pools.drugClasses) {
      for (const drug of pools.pharm) {
        const q = buildDrugClassQuestion(drug, pools.drugClasses, rng)
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
