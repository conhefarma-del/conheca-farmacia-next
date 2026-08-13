/**
 * Simplificação de linguagem — partilhada entre Flashcards e Quiz.
 *
 * Princípio (plano 2026-08-13-quiz): as perguntas usam linguagem mais
 * simples sempre que possível, SEM abdicar dos termos clínicos essenciais
 * nem alterar o significado dos factos. A simplificação aplica-se apenas à
 * apresentação (pergunta/opções); o conteúdo clínico (respostas) e as
 * fontes ficam intactos.
 *
 * Usado por:
 *  - Flashcards: fronts regenerados (migração 158 + geração assistida) e
 *    verso com sinónimos conservadores só no render.
 *  - Quiz: templates das perguntas MCQ (T2 do plano).
 */

// Templates de pergunta simplificados por tipo de cartão/pergunta.
// {drug}, {a} e {b} são substituídos pelos nomes reais dos fármacos.
export const FRONT_TEMPLATES = {
  mecanismo: {
    pt: 'Como atua o {drug} no organismo?',
    en: 'How does {drug} work in the body?',
  },
  classe: {
    pt: 'A que grupo de medicamentos pertence o {drug}?',
    en: 'Which group of medicines does {drug} belong to?',
  },
  perfil: {
    pt: 'Para que serve o {drug}? (visão geral e indicação)',
    en: 'What is {drug} for? (overview and indication)',
  },
  interacao: {
    pt: 'Que interação existe entre {a} e {b}?',
    en: 'What interaction exists between {a} and {b}?',
  },
}

/**
 * Constrói o front simplificado a partir do tipo e dos nomes reais.
 * @param {'mecanismo'|'classe'|'perfil'|'interacao'} cardType
 * @param {{drug?: string, a?: string, b?: string}} names
 * @param {'pt'|'en'} lang
 */
export function buildFront(cardType, names = {}, lang = 'pt') {
  const tpl = FRONT_TEMPLATES[cardType]?.[lang] || FRONT_TEMPLATES[cardType]?.pt
  if (!tpl) return ''
  return tpl
    .replace(/\{drug\}/g, names.drug || '')
    .replace(/\{a\}/g, names.a || '')
    .replace(/\{b\}/g, names.b || '')
    .replace(/\s{2,}/g, ' ')
    .trim()
}

// Mapas de sinónimos conservadores — apenas equivalências seguras e bem
// conhecidas. Guardas:
//  - não substitui dentro de palavras (pró-fármaco, prodrug)
//  - não substitui compostos clínicos com hífen (fármaco-fármaco, drug-drug)
//  - preserva maiúsculas/minúsculas do original via flags gi
const SYNONYMS = {
  pt: [
    { re: /(?<!-)(?<![\p{L}\p{N}])fármacos(?![-\p{L}\p{N}])/giu, to: 'medicamentos' },
    { re: /(?<!-)(?<![\p{L}\p{N}])fármaco(?![-\p{L}\p{N}])/giu, to: 'medicamento' },
  ],
  en: [
    { re: /(?<!-)(?<![\p{L}\p{N}])drugs(?![-\p{L}\p{N}])/giu, to: 'medicines' },
    { re: /(?<!-)(?<![\p{L}\p{N}])drug(?![-\p{L}\p{N}])/giu, to: 'medicine' },
  ],
}

/**
 * Aplica os sinónimos conservadores ao texto (só apresentação).
 * Nunca altera fontes nem nomes próprios; termos sem sinónimo seguro
 * ficam como estão.
 */
export function simplifyText(text, lang = 'pt') {
  if (!text) return text
  let out = String(text)
  for (const { re, to } of SYNONYMS[lang] || []) {
    out = out.replace(re, to)
  }
  return out
}
