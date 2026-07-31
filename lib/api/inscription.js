'use client'

import { apiSubmitInscription, apiCheckDuplicate } from '@/lib/actions/inscription'

const WHITELISTS = {
  genero: ['masculino', 'feminino', ''],
  faixa_etaria: ['menor-18', '18-24', '25-34', '35-44', '45-54', '55+', ''],
  profissao: [
    'enfermeiro', 'medico', 'farmaceutico', 'estudante-saude',
    'tecnico-medio-saude', 'tecnico-radiologia', 'tecnico-analises-clinicas',
    'medico-dentista', 'biologo-analista', 'psicologo', 'nutricionista',
    'fisioterapeuta', 'outro',
  ],
  nivel_escolaridade: ['tecnico-profissional', 'licenciatura', 'pos-graduacao-mestrado', 'doutoramento', ''],
  origem_evento: ['instagram', 'whatsapp', 'facebook', 'tiktok', 'linkedin', 'amigo-indicacao', 'outro', ''],
}

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const PHONE_REGEX = /^\+?[\d\s()-]{7,15}$/

/**
 * Validate a single field. Returns error message or null.
 */
export function validateField(name, value, required = false) {
  // Menor de idade exige consentimento do responsável legal (Política 2.1)
  if (name === 'menor_consentimento') {
    const checked = value === true || value === 'true'
    if (required && !checked) return 'O consentimento do responsável legal é obrigatório para participantes menores de idade.'
    return null
  }

  const v = (value || '').trim()

  if (required && !v) return 'Este campo é obrigatório'

  if (name === 'nome') {
    if (!v) return null
    if (/<|>|javascript:/i.test(v)) return 'Caracteres inválidos no nome'
    if (v.length > 100) return 'Nome demasiado longo'
  }

  if (name === 'email') {
    if (!v) return null
    if (!EMAIL_REGEX.test(v)) return 'Email inválido'
  }

  if (name === 'telefone') {
    if (!v) return null
    if (!PHONE_REGEX.test(v.replace(/\s/g, ''))) return 'Telefone inválido'
  }

  if (name === 'genero' && v && !WHITELISTS.genero.includes(v)) return 'Opção inválida'
  if (name === 'faixa_etaria' && v && !WHITELISTS.faixa_etaria.includes(v)) return 'Opção inválida'
  if (name === 'profissao' && v && !WHITELISTS.profissao.includes(v)) return 'Opção inválida'
  if (name === 'nivel_escolaridade' && v && !WHITELISTS.nivel_escolaridade.includes(v)) return 'Opção inválida'
  if (name === 'origem_evento' && v && !WHITELISTS.origem_evento.includes(v)) return 'Opção inválida'

  return null
}

/**
 * Thin client-side wrapper. The browser never touches `inscricoes` directly
 * (which would be blocked by RLS for `anon` and was failing in prod with
 * `error: {}`). All work — Edge Function validation, INSERT, email — runs
 * server-side via the Server Action in `lib/actions/inscription.js`.
 *
 * `eventoId` is the UUID (stable across translations) — caller resolves
 * it server-side. `eventoSlug` is the PT canonical slug (used as the
 * stable API contract for the Edge Function and confirmation email).
 *
 * Contract (2026-06-22 return-based):
 *   - Success: { success: true, inscriptionId, emailSent }
 *   - Business error: { success: false, code, detail }
 *   - Truly unexpected: throws (rare — e.g. Server Action infra failure)
 * The Client (`InscricaoPageClient.jsx`) maps `code` to i18n.
 */
export async function submitInscription(formData, eventoId, eventoSlug, lang = 'pt') {
  if (!eventoId) {
    return { success: false, code: 'invalid_event_id', detail: 'eventoId é obrigatório' }
  }
  return apiSubmitInscription(formData, eventoId, eventoSlug, lang)
}

/**
 * Pré-validação de email duplicado. Devolve `{ isDuplicate: boolean }`.
 * Nunca throw — falha silenciosa devolve `false` (deixa o submit validar).
 * Workaround para body de Server Action que chega vazio ao client em
 * produção (Next.js 16 strip da mensagem em alguns deployments).
 */
export async function checkDuplicate(eventoId, email) {
  return apiCheckDuplicate(eventoId, email)
}
