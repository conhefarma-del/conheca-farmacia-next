'use client'

import { apiSubmitInscription } from '@/lib/actions/inscription'

const WHITELISTS = {
  genero: ['masculino', 'feminino', ''],
  faixa_etaria: ['18-24', '25-34', '35-44', '45-54', '55+', ''],
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
 */
export async function submitInscription(formData, eventoId, eventoSlug) {
  if (!eventoId) {
    throw new Error('eventoId é obrigatório')
  }
  return apiSubmitInscription(formData, eventoId, eventoSlug)
}
