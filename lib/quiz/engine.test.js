import assert from 'node:assert/strict'
import {
  shuffle,
  sameAnswer,
  cleanOptionText,
  pickDistractors,
  selectDistractors,
  scoreDistractor,
  buildFlashcardQuestion,
  buildPharmacologyQuestion,
  buildInteractionQuestion,
  buildFoodQuestion,
  buildDiseaseQuestion,
  buildProtocolQuestion,
  buildSession,
  buildLevelSession,
  LEVELS,
  score,
} from './engine.js'

let passed = 0
function ok(name, fn) {
  fn()
  passed++
  console.log('OK', name)
}

// RNG determinístico para testes
function seeded(seed = 1) {
  let s = seed
  return () => {
    s = (s * 1103515245 + 12345) % 2147483648
    return s / 2147483648
  }
}

// ---- shuffle ---------------------------------------------------------
ok('shuffle mantém os elementos', () => {
  const arr = [1, 2, 3, 4, 5]
  const out = shuffle(arr, seeded())
  assert.equal(out.length, arr.length)
  assert.deepEqual([...out].sort(), [...arr].sort())
  assert.notDeepEqual(out, arr) // quase certamente diferente com 5+ elementos
})

// ---- sameAnswer ------------------------------------------------------
ok('sameAnswer tolera espaços e caixa', () => {
  assert.ok(sameAnswer(' Crítico ', 'crítico'))
  assert.ok(!sameAnswer('Crítico', 'Moderado'))
  assert.ok(!sameAnswer('', 'x'))
})

// ---- pickDistractors -------------------------------------------------
ok('distratores únicos, excluem o correto, respeitam n', () => {
  const pool = ['A', 'B', 'C', 'D', 'E', 'A', 'b']
  const d = pickDistractors(pool, 'A', 3, seeded())
  assert.equal(d.length, 3)
  assert.ok(!d.some((x) => sameAnswer(x, 'A')))
  assert.equal(new Set(d.map((x) => x.toLowerCase())).size, 3)
})
ok('pool sem alternativas devolve menos que n', () => {
  const d = pickDistractors(['A', 'A'], 'A', 3, seeded())
  assert.equal(d.length, 0)
})

// ---- buildFlashcardQuestion -----------------------------------------
const cards = [1, 2, 3, 4, 5, 6].map((i) => ({
  id: `c${i}`,
  front: `Pergunta ${i}`,
  back: `Resposta ${i}`,
  sourceNote: 'Fonte X',
}))
ok('flashcard: 4 opções, correta presente, correctIndex válido', () => {
  const q = buildFlashcardQuestion(cards[0], cards, seeded())
  assert.equal(q.key, 'flashcard:c1')
  assert.equal(q.question, 'Pergunta 1')
  assert.equal(q.options.length, 4)
  assert.ok(sameAnswer(q.options[q.correctIndex], 'Resposta 1'))
  assert.equal(q.source, 'Fonte X')
})
ok('flashcard: distratores saem do mesmo tipo de cartão', () => {
  const deck = [
    { id: 'k1', cardType: 'classe', front: 'Q1', back: 'AINE' },
    { id: 'k2', cardType: 'classe', front: 'Q2', back: 'IBP' },
    { id: 'k3', cardType: 'classe', front: 'Q3', back: 'Biguanida' },
    { id: 'k4', cardType: 'classe', front: 'Q4', back: 'Diurético tiazídico' },
    { id: 'k5', cardType: 'perfil', front: 'Q5', back: 'Usado para tratar a dor e a febre em adultos e crianças, com revisão da dose renal.' },
  ]
  const q = buildFlashcardQuestion(deck[0], deck, seeded())
  assert.equal(q.options.length, 4)
  // Nenhuma opção vem do cartão de outro tipo (texto longo de perfil).
  assert.ok(q.options.every((o) => o.length <= 40))
})
ok('flashcard: tipo com poucos cartões usa o deck completo (nunca <4 opções)', () => {
  const deck = [
    { id: 'k1', cardType: 'raro', front: 'Q1', back: 'Resposta única' },
    { id: 'k2', cardType: 'classe', front: 'Q2', back: 'AINE' },
    { id: 'k3', cardType: 'classe', front: 'Q3', back: 'IBP' },
    { id: 'k4', cardType: 'classe', front: 'Q4', back: 'Biguanida' },
  ]
  const q = buildFlashcardQuestion(deck[0], deck, seeded())
  assert.equal(q.options.length, 4)
})

// ---- buildPharmacologyQuestion --------------------------------------
const drugs = [
  { drugId: 'd1', name: 'Ibuprofeno', class_pt: 'AINE', mechanism_pt: 'Inibe a COX-1/COX-2.', half_life_pt: '2 h' },
  { drugId: 'd2', name: 'Paracetamol', class_pt: 'Analgésico', mechanism_pt: 'Inibe a síntese central de prostaglandinas.', half_life_pt: '4 h' },
  { drugId: 'd3', name: 'Amoxicilina', class_pt: 'Penicilina', mechanism_pt: 'Inibe a síntese da parede bacteriana.', half_life_pt: '1 h' },
  { drugId: 'd4', name: 'Metformina', class_pt: 'Biguanida', mechanism_pt: 'Reduz a produção hepática de glucose.', half_life_pt: '6 h' },
  { drugId: 'd5', name: 'Omeprazol', class_pt: 'IBP', mechanism_pt: 'Inibe a bomba de protões gástrica.', half_life_pt: '1,5 h' },
  { drugId: 'd6', name: 'Amlodipina', class_pt: 'Bloqueador dos canais de cálcio', mechanism_pt: 'Bloqueia a entrada de cálcio no músculo liso vascular.', half_life_pt: '40 h' },
  { drugId: 'd7', name: 'Salbutamol', class_pt: 'β2-agonista', mechanism_pt: 'Relaxa a musculatura brônquica.', half_life_pt: '5 h' },
  { drugId: 'd8', name: 'Losartan', class_pt: 'ARA II', mechanism_pt: 'Bloqueia o recetor AT1 da angiotensina II.', half_life_pt: '9 h' },
]
ok('pharmacology classe', () => {
  const q = buildPharmacologyQuestion(drugs[0], drugs, 'classe', seeded())
  assert.equal(q.question, 'A que grupo pertence o medicamento Ibuprofeno?')
  assert.ok(sameAnswer(q.options[q.correctIndex], 'AINE'))
})
ok('pharmacology mecanismo (título simplificado)', () => {
  const q = buildPharmacologyQuestion(drugs[0], drugs, 'mecanismo', seeded())
  assert.equal(q.question, 'Como atua o medicamento Ibuprofeno no organismo?')
  assert.ok(sameAnswer(q.options[q.correctIndex], 'Inibe a COX-1/COX-2.'))
})
ok('pharmacology meia-vida com gloss', () => {
  const q = buildPharmacologyQuestion(drugs[0], drugs, 'meia_vida', seeded())
  assert.match(q.question, /meia-vida/)
  assert.ok(sameAnswer(q.options[q.correctIndex], '2 h'))
})
ok('pharmacology sem valor devolve null', () => {
  const q = buildPharmacologyQuestion({ drugId: 'x', name: 'X', class_pt: '', mechanism_pt: '', half_life_pt: '' }, drugs, 'classe', seeded())
  assert.equal(q, null)
})
ok('pharmacology: opções que nomeiam outro fármaco continuam elegíveis', () => {
  // Nos textos clínicos da BD cada opção cita o seu próprio medicamento:
  // exigir o nome do enunciado esvaziava o pool e caía em sorteio puro.
  const mech = (name, text) => ({ drugId: name, name, class_pt: 'Anticoagulante', mechanism_pt: text, half_life_pt: '2 h' })
  const pool = [
    mech('Dabigatrano', 'O dabigatrano liga-se ao sítio ativo da trombina livre e ligada ao coágulo, impedindo a formação de fibrina.'),
    mech('Varfarina', 'A varfarina inibe a vitamina K epóxido redutase, reduzindo a síntese dos fatores II, VII, IX e X da coagulação.'),
    mech('Heparina', 'A heparina ativa a antitrombina III, inibindo a trombina e o fator Xa, com efeito anticoagulante imediato.'),
    mech('AAS', 'O ácido acetilsalicílico inibe de forma irreversível a COX-1 das plaquetas, reduzindo a agregação.'),
  ]
  const q = buildPharmacologyQuestion(pool[0], pool, 'mecanismo', seeded())
  assert.equal(q.options.length, 4)
  // Nenhuma opção curta/genérica entrou: todas são frases de mecanismo.
  assert.ok(q.options.every((o) => o.length >= 40))
})

// ---- cleanOptionText -------------------------------------------------
// Os cartões de interação da BD trazem «Grau: Moderado» / «Grau: Crítico»
// colado ao fim da resposta (124 de 697 backs). Numa opção isso não é
// conteúdo e denuncia o padrão da pergunta.
ok('cleanOptionText: remove o sufixo de grau colado ao fim', () => {
  assert.equal(
    cleanOptionText('Ciprofloxacina + cálcio: quelação que reduz a absorção.\n\nGrau: Moderado'),
    'Ciprofloxacina + cálcio: quelação que reduz a absorção.',
  )
  assert.equal(cleanOptionText('Aumenta o risco de hemorragia.\n\nGrau: Crítico'), 'Aumenta o risco de hemorragia.')
  assert.equal(cleanOptionText('Reduz a absorção — Grau: Moderado.'), 'Reduz a absorção')
  assert.equal(cleanOptionText('Prolonga o QT (Severidade: menor).'), 'Prolonga o QT')
  // Variante com «Grau da interação:» também sai.
  assert.equal(
    cleanOptionText('Aumenta o risco de sangramento.\n\nGrau da interação: Crítico'),
    'Aumenta o risco de sangramento.',
  )
})
ok('cleanOptionText: não toca em texto sem sufixo', () => {
  // «em menor grau» é conteúdo, não etiqueta — fica como está.
  assert.equal(
    cleanOptionText('Aumenta a ototoxicidade e, em menor grau, a nefrotoxicidade.'),
    'Aumenta a ototoxicidade e, em menor grau, a nefrotoxicidade.',
  )
  assert.equal(cleanOptionText('AINE'), 'AINE')
  assert.equal(cleanOptionText(''), '')
  assert.equal(cleanOptionText(null), null)
  // Só o sufixo: nunca devolve texto vazio.
  assert.equal(cleanOptionText('Grau: Moderado'), 'Grau: Moderado')
})
ok('flashcard: opções saem sem o sufixo de grau', () => {
  const deck = [
    { id: 'g1', cardType: 'interacao', front: 'Q1', back: 'Ciprofloxacina + cálcio: quelação que reduz a absorção.\n\nGrau: Moderado' },
    { id: 'g2', cardType: 'interacao', front: 'Q2', back: 'A metoclopramida reduz a absorção da digoxina.\n\nGrau: Moderado' },
    { id: 'g3', cardType: 'interacao', front: 'Q3', back: 'Varfarina + ibuprofeno: risco de hemorragia digestiva.\n\nGrau: Crítico' },
    { id: 'g4', cardType: 'interacao', front: 'Q4', back: 'Tizanidina + ciprofloxacina: aumento da tizanidina por inibição do CYP1A2.\n\nGrau: Crítico' },
  ]
  const q = buildFlashcardQuestion(deck[0], deck, seeded())
  assert.equal(q.options.length, 4)
  assert.ok(q.options.every((o) => !/grau\s*:/i.test(o)), 'nenhuma opção mantém o sufixo')
  assert.equal(
    q.options[q.correctIndex],
    'Ciprofloxacina + cálcio: quelação que reduz a absorção.',
  )
})

// ---- buildInteractionQuestion / food / disease ----------------------
const interactions = [
  { id: 'i1', a: 'Varfarina', b: 'Ibuprofeno', summaryPt: 'Aumenta o risco de hemorragia.', severity: 'critical' },
  { id: 'i2', a: 'C', b: 'D', summaryPt: 'Reduz a absorção.', severity: 'moderate' },
  { id: 'i3', a: 'E', b: 'F', summaryPt: 'Aumenta a toxicidade.', severity: 'critical' },
  { id: 'i4', a: 'G', b: 'H', summaryPt: 'Prolonga o intervalo QT.', severity: 'critical' },
  { id: 'i5', a: 'I', b: 'J', summaryPt: 'Diminui a eficácia do antibiótico.', severity: 'moderate' },
]
ok('interaction fármaco-fármaco', () => {
  const q = buildInteractionQuestion(interactions[0], interactions, seeded())
  assert.equal(q.question, 'Que interação existe entre Varfarina e Ibuprofeno?')
  assert.ok(sameAnswer(q.options[q.correctIndex], 'Aumenta o risco de hemorragia.'))
  assert.match(q.explanation, /Grau da interação: Crítico/)
})
const foods = [
  { id: 'f1', drugName: 'Varfarina', entityPt: 'Couve' },
  { id: 'f2', drugName: 'X', entityPt: 'Toranja' },
  { id: 'f3', drugName: 'Y', entityPt: 'Leite' },
  { id: 'f4', drugName: 'Z', entityPt: 'Álcool' },
  { id: 'f5', drugName: 'W', entityPt: 'Café' },
]
ok('interaction alimento', () => {
  const q = buildFoodQuestion(foods[0], foods, seeded())
  assert.equal(q.question, 'Que alimento ou bebida interage com o medicamento Varfarina?')
  assert.ok(sameAnswer(q.options[q.correctIndex], 'Couve'))
})
const diseases = [
  { id: 'dd1', drugName: 'Metformina', conditionPt: 'Insuficiência renal' },
  { id: 'dd2', drugName: 'X', conditionPt: 'Asma' },
  { id: 'dd3', drugName: 'Y', conditionPt: 'Gravidez' },
  { id: 'dd4', drugName: 'Z', conditionPt: 'Doença hepática' },
  { id: 'dd5', drugName: 'W', conditionPt: 'Insuficiência cardíaca' },
]
ok('interaction doença', () => {
  const q = buildDiseaseQuestion(diseases[0], diseases, seeded())
  assert.equal(q.question, 'Que condição ou doença exige cuidado com o medicamento Metformina?')
  assert.ok(sameAnswer(q.options[q.correctIndex], 'Insuficiência renal'))
})

// ---- Qualidade dos distratores ---------------------------------------
ok('distrator: opção contida na correta é descartada', () => {
  assert.equal(scoreDistractor('Anti-inflamatório', 'Anti-inflamatório não esteroide'), -1)
  assert.equal(scoreDistractor('Anti-inflamatório não esteroide', 'Anti-inflamatório'), -1)
  assert.equal(scoreDistractor('Anti-inflamatório não esteroide', 'Anti-inflamatório não esteroide'), -1)
})

ok('distrator: comprimento parecido vale mais do que um muito curto', () => {
  const correct = 'Aumenta o risco de hemorragia grave, sobretudo em doentes anticoagulados.'
  const parecido = 'Aumenta o risco de hipercalemia grave, sobretudo em doentes renais.'
  const curto = 'Reduz a absorção.'
  assert.ok(scoreDistractor(parecido, correct) > scoreDistractor(curto, correct))
})

ok('distrator: mesma pegada de nomes vale mais (interações)', () => {
  const correct = 'A associação de Varfarina e Ibuprofeno aumenta o risco de hemorragia.'
  const comNomes = 'A associação de Varfarina e Ibuprofeno reduz a absorção gástrica.'
  const semNomes = 'A associação reduz a absorção gástrica de outros fármacos.'
  const avoidTokens = ['Varfarina', 'Ibuprofeno']
  assert.ok(
    scoreDistractor(comNomes, correct, { avoidTokens }) >
      scoreDistractor(semNomes, correct, { avoidTokens }),
  )
  // Sem nomear o par, a opção entrega a resposta: sai quando há alternativas.
  assert.equal(scoreDistractor(semNomes, correct, { avoidTokens }), -1)
})

ok('distrator: meia-vida vizinha vale mais do que uma muito distante', () => {
  assert.ok(scoreDistractor('4 h', '2 h') > scoreDistractor('40 h', '2 h'))
})

ok('selectDistractors: opções plausíveis e sem atalhos de leitura', () => {
  const correct = 'A associação de Varfarina e Ibuprofeno aumenta o risco de hemorragia grave.'
  const pool = [
    'Risco.', 'Nada.', 'Sem efeito.', 'Interação leve.',
    'A Varfarina e o Ibuprofeno aumentam o risco de hemorragia digestiva alta.',
    'A Varfarina e o Ibuprofeno reduzem a absorção de outros medicamentos.',
    'A associação aumenta o risco de hipercalemia grave em doentes renais.',
    'A Varfarina e o Ibuprofeno podem prolongar o intervalo QT no coração.',
  ]
  const d = selectDistractors(pool, correct, {
    n: 3,
    rng: seeded(),
    avoidTokens: ['Varfarina', 'Ibuprofeno'],
  })
  assert.equal(d.length, 3)
  assert.ok(!d.some((x) => sameAnswer(x, correct)))
  assert.ok(d.every((x) => x.length >= correct.length * 0.6))
})

// ---- buildProtocolQuestion ------------------------------------------
const pq = {
  id: 'p1',
  question: 'Qual a dose de carga da artemisinina?',
  options: ['4 mg/kg', '8 mg/kg', '12 mg/kg', '16 mg/kg'],
  correctIndex: 1,
  explanation: 'Segundo o protocolo nacional.',
  protocolTitle: 'Malária',
}
ok('protocol reutiliza perguntas curadas', () => {
  const q = buildProtocolQuestion(pq, seeded())
  assert.equal(q.key, 'protocol:p1')
  assert.ok(sameAnswer(q.options[q.correctIndex], '8 mg/kg'))
  assert.equal(q.source, 'Protocolo: Malária')
  assert.equal(q.explanation, 'Segundo o protocolo nacional.')
})

// ---- buildSession ----------------------------------------------------
const pools = {
  decks: [{ slug: 'deck-a', cards }],
  pharm: drugs,
  interactions,
  food: foods,
  disease: diseases,
  protocols: [pq],
}
ok('sessão modo deck: só cartões do deck', () => {
  const s = buildSession({ mode: 'deck', deckSlug: 'deck-a', count: 5, pools, rng: seeded() })
  assert.equal(s.length, 5)
  assert.ok(s.every((q) => q.type === 'flashcard' && q.key.startsWith('flashcard:')))
})
ok('sessão modo tipo pharmacology', () => {
  const s = buildSession({ mode: 'tipo', source: 'pharmacology', count: 20, pools, rng: seeded() })
  assert.ok(s.length <= 24) // 8 fármacos × 3 campos
  assert.ok(s.every((q) => q.type === 'pharmacology'))
})
ok('sessão modo tipo interaction inclui as 3 dimensões', () => {
  const s = buildSession({ mode: 'tipo', source: 'interaction', count: 30, pools, rng: seeded() })
  assert.ok(s.length > 0)
  assert.ok(s.some((q) => q.key.startsWith('interaction:')))
  assert.ok(s.some((q) => q.key.startsWith('food:')))
  assert.ok(s.some((q) => q.key.startsWith('disease:')))
})
ok('sessão modo rapido mistura fontes', () => {
  // pool de teste = 6 cartões + 24 farmacologia + 5 interações + 5 alimentos + 5 doenças + 1 protocolo = 46
  // Só há 1 protocolo, por isso uma amostra de 30 de 46 pode não o apanhar:
  // a presença de cada tipo é verificada ao longo de várias sessões, não numa só.
  const seen = new Set()
  for (let seed = 1; seed <= 10; seed++) {
    const s = buildSession({ mode: 'rapido', count: 30, pools, rng: seeded(seed) })
    assert.equal(s.length, 30)
    for (const q of s) seen.add(q.type)
  }
  assert.ok(seen.has('flashcard'))
  assert.ok(seen.has('pharmacology'))
  assert.ok(seen.has('interaction'))
  assert.ok(seen.has('protocol'))
})
ok('sessão respeita count mínimo e máximo', () => {
  assert.equal(buildSession({ mode: 'rapido', count: 2, pools, rng: seeded() }).length, 5)
  assert.equal(buildSession({ mode: 'rapido', count: 999, pools, rng: seeded() }).length, 30) // cap máximo de 30
})
ok('sessão: cada pergunta tem 4 opções e correta presente', () => {
  const s = buildSession({ mode: 'rapido', count: 30, pools, rng: seeded() })
  for (const q of s) {
    assert.equal(q.options.length, 4)
    assert.ok(q.correctIndex >= 0 && q.correctIndex < 4)
  }
})

// ---- buildLevelSession -------------------------------------------------
ok('nível fácil: 8 perguntas só de flashcards + classe', () => {
  const s = buildLevelSession({ level: 'facil', pools, rng: seeded() })
  assert.equal(s.length, 8)
  assert.ok(s.every((q) => q.type === 'flashcard' || q.type === 'pharmacology'))
  const keys = s.map((q) => q.key)
  assert.ok(keys.some((k) => k.startsWith('flashcard:')))
  assert.ok(keys.some((k) => k.endsWith(':classe')))
  assert.ok(!keys.some((k) => k.endsWith(':meia_vida')))
})
ok('nível médio: 12 perguntas, soma mecanismo e alimento/doença', () => {
  const s = buildLevelSession({ level: 'medio', pools, rng: seeded() })
  assert.equal(s.length, 12)
  const keys = s.map((q) => q.key)
  assert.ok(keys.some((k) => k.endsWith(':mecanismo')))
  assert.ok(keys.some((k) => k.startsWith('food:')))
  assert.ok(keys.some((k) => k.startsWith('disease:')))
  assert.ok(!keys.some((k) => k.startsWith('interaction:')))
  assert.ok(!keys.some((k) => k.startsWith('protocol:')))
})
ok('nível difícil: 16 perguntas, soma fármaco-fármaco, meia-vida e protocolos', () => {
  const s = buildLevelSession({ level: 'dificil', pools, rng: seeded() })
  assert.equal(s.length, 16)
  const keys = s.map((q) => q.key)
  assert.ok(keys.some((k) => k.startsWith('interaction:')))
  assert.ok(keys.some((k) => k.endsWith(':meia_vida')))
  assert.ok(keys.some((k) => k.startsWith('protocol:')))
})
ok('dificil: interações com presença reforçada (quota 3)', () => {
  const s = buildLevelSession({ level: 'dificil', pools, rng: seeded() })
  const interactions = s.filter((q) => q.key.startsWith('interaction:'))
  assert.ok(interactions.length >= 3)
})
ok('backfill: pool de interações curto não reduz o total do difícil', () => {
  const smallPools = {
    ...pools,
    interactions: pools.interactions.slice(0, 1), // 1 em vez de 5
    protocols: pools.protocols.slice(0, 1),       // 1
  }
  const s = buildLevelSession({ level: 'dificil', pools: smallPools, rng: seeded() })
  assert.equal(s.length, 16)
  const keys = s.map((q) => q.key)
  assert.ok(keys.some((k) => k.startsWith('interaction:'))) // assinatura mantém-se
  assert.ok(keys.some((k) => k.startsWith('protocol:')))
})
ok('backfill: categorias vazias não reduzem o total nem quebram', () => {
  const emptyPools = {
    ...pools,
    interactions: [],
    food: [],
    disease: [],
    protocols: [],
  }
  const s = buildLevelSession({ level: 'dificil', pools: emptyPools, rng: seeded() })
  assert.equal(s.length, 16) // 11 das quotas + 5 de backfill (flashcards/farmacologia)
  const types = new Set(s.map((q) => q.type))
  assert.ok(!types.has('protocol'))
  assert.ok(types.has('flashcard'))
  assert.ok(types.has('pharmacology'))
})
ok('backfill: pool total menor que count devolve o disponível', () => {
  const tinyPools = {
    ...pools,
    decks: [{ slug: 'deck-a', cards: cards.slice(0, 2) }],
    pharm: drugs.slice(0, 1),
    interactions: [],
    food: [],
    disease: [],
    protocols: [],
  }
  const s = buildLevelSession({ level: 'dificil', pools: tinyPools, rng: seeded() })
  // disponível: 2 flashcards + 3 farmacologia = 5 → devolve 5, nunca mais
  assert.ok(s.length <= 5)
  assert.ok(s.length > 0)
})
ok('backfill: nível médio também mantém o count com pool curto', () => {
  const smallPools = { ...pools, food: pools.food.slice(0, 0), disease: pools.disease.slice(0, 0) }
  const s = buildLevelSession({ level: 'medio', pools: smallPools, rng: seeded() })
  assert.equal(s.length, 12) // 10 das quotas + 2 de backfill
})
ok('nível inválido cai para fácil', () => {
  const s = buildLevelSession({ level: 'impossivel', pools, rng: seeded() })
  assert.equal(s.length, 8)
})
ok('buildSession com mode nivel usa o nível', () => {
  const s = buildSession({ mode: 'nivel', level: 'medio', pools, rng: seeded() })
  assert.equal(s.length, 12)
})
ok('LEVELS: quotas somam o count', () => {
  for (const cfg of Object.values(LEVELS)) {
    const sum = Object.values(cfg.quotas).reduce((a, b) => a + b, 0)
    assert.equal(sum, cfg.count)
  }
})

// ---- score -----------------------------------------------------------
ok('score', () => {
  assert.deepEqual(score([true, false, true]), { correct: 2, total: 3, pct: 67 })
  assert.deepEqual(score([]), { correct: 0, total: 0, pct: 0 })
})

console.log(`\n${passed} testes passaram`)
