import { unstable_cache } from 'next/cache'
import { createAnonClient } from '@/lib/supabase/server-anon'

/**
 * Pools reais para o engine do Quiz (T3 do plano 2026-08-13-quiz).
 *
 * As perguntas são montadas em tempo real pelo engine (lib/quiz/engine.js)
 * a partir destes dados — não há tabela de perguntas. Só registos
 * publicados/não arquivados. Cache 1h + tags (flashcards, para invalidar
 * quando os cartões mudam).
 */
export const getQuizPools = unstable_cache(
  async () => {
    const supabase = await createAnonClient()

    const [
      decksRes,
      cardsRes,
      drugsRes,
      pharmRes,
      intRes,
      foodRes,
      diseaseRes,
      pqsRes,
      protocolsRes,
    ] = await Promise.all([
      supabase
        .from('flashcard_decks')
        .select('id, slug, name_pt, color')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('flashcards')
        .select('id, deck_id, card_type, front_pt, back_pt, source_note')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('drugs')
        .select('id, name_pt, class_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('drug_pharmacology')
        .select('drug_id, mechanism_pt, half_life_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('drug_interactions')
        .select('id, drug_a_id, drug_b_id, summary_pt, severity')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('drug_food_interactions')
        .select('id, drug_id, entity_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('drug_disease_interactions')
        .select('id, drug_id, condition_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('clinical_protocol_quizzes')
        .select('id, protocol_id, question_pt, option_a_pt, option_b_pt, option_c_pt, option_d_pt, correct_index, explanation_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
      supabase
        .from('clinical_protocols')
        .select('id, title_pt')
        .eq('status', 'published')
        .eq('is_archived', false),
    ])

    if (decksRes.error) throw decksRes.error
    if (cardsRes.error) throw cardsRes.error

    const drugNameById = new Map((drugsRes.data || []).map((d) => [d.id, d.name_pt]))
    const classByDrug = new Map((drugsRes.data || []).map((d) => [d.id, d.class_pt]))
    const mechByDrug = new Map((pharmRes.data || []).map((p) => [p.drug_id, p.mechanism_pt]))
    const halfByDrug = new Map((pharmRes.data || []).map((p) => [p.drug_id, p.half_life_pt]))
    const protoTitleById = new Map((protocolsRes.data || []).map((p) => [p.id, p.title_pt]))

    // Decks com cartões
    const deckById = new Map((decksRes.data || []).map((d) => [d.id, { id: d.id, slug: d.slug, name: d.name_pt, color: d.color, cards: [] }]))
    for (const c of cardsRes.data || []) {
      const deck = deckById.get(c.deck_id)
      if (!deck) continue
      deck.cards.push({
        id: c.id,
        cardType: c.card_type,
        front: c.front_pt,
        back: c.back_pt,
        sourceNote: c.source_note,
      })
    }
    const decks = [...deckById.values()]

    // Farmacologia: só fármacos com pelo menos um campo útil
    const pharm = (drugsRes.data || [])
      .map((d) => ({
        drugId: d.id,
        name: d.name_pt,
        class_pt: classByDrug.get(d.id) || '',
        mechanism_pt: mechByDrug.get(d.id) || '',
        half_life_pt: halfByDrug.get(d.id) || '',
      }))
      .filter((d) => d.class_pt || d.mechanism_pt || d.half_life_pt)

    const interactions = (intRes.data || []).map((i) => ({
      id: i.id,
      a: drugNameById.get(i.drug_a_id) || 'Fármaco A',
      b: drugNameById.get(i.drug_b_id) || 'Fármaco B',
      summaryPt: i.summary_pt,
      severity: i.severity,
    }))

    const food = (foodRes.data || []).map((f) => ({
      id: f.id,
      drugName: drugNameById.get(f.drug_id) || 'Fármaco',
      entityPt: f.entity_pt,
    }))

    const disease = (diseaseRes.data || []).map((d) => ({
      id: d.id,
      drugName: drugNameById.get(d.drug_id) || 'Fármaco',
      conditionPt: d.condition_pt,
    }))

    const protocols = (pqsRes.data || []).map((pq) => ({
      id: pq.id,
      question: pq.question_pt,
      options: [pq.option_a_pt, pq.option_b_pt, pq.option_c_pt, pq.option_d_pt],
      correctIndex: pq.correct_index,
      explanation: pq.explanation_pt || '',
      protocolTitle: protoTitleById.get(pq.protocol_id) || '',
    }))

    return {
      decks,
      pharm,
      interactions,
      food,
      disease,
      protocols,
      counts: {
        decks: decks.length,
        cards: (cardsRes.data || []).length,
        drugs: pharm.length,
        interactions: interactions.length,
        food: food.length,
        disease: disease.length,
        protocols: protocols.length,
      },
    }
  },
  ['api', 'quiz', 'pools'],
  { revalidate: 3600, tags: ['quiz', 'flashcards'] }
)

/**
 * Contagens reais e frescas dos pools que alimentam o Quiz (sem cache) —
 * para o admin ver se algum tipo de pergunta está a ficar escasso.
 * Usa os mesmos filtros do getQuizPools (published + não arquivado).
 */
export async function getQuizPoolCounts() {
  const supabase = await createAnonClient()
  const tables = [
    { table: 'flashcard_decks', label: 'decks' },
    { table: 'flashcards', label: 'cards' },
    { table: 'drugs', label: 'drugs' },
    { table: 'drug_pharmacology', label: 'pharm' },
    { table: 'drug_interactions', label: 'interactions' },
    { table: 'drug_food_interactions', label: 'food' },
    { table: 'drug_disease_interactions', label: 'disease' },
    { table: 'clinical_protocol_quizzes', label: 'protocols' },
  ]

  const out = {}
  for (const t of tables) {
    const { count, error } = await supabase
      .from(t.table)
      .select('*', { count: 'exact', head: true })
      .eq('status', 'published')
      .eq('is_archived', false)
    out[t.label] = error ? null : (count ?? 0)
  }
  return out
}
