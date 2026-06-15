'use client'

import { createClient } from '../supabase/client'

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
 * Submit inscription via Edge Function + Supabase insert.
 */
export async function submitInscription(formData, eventoSlug) {
  const supabase = createClient()

  // 1. Call Edge Function for server-side validation
  const fnUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/validate-inscription`
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  const response = await fetch(fnUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${anonKey}`,
    },
    body: JSON.stringify({
      nome: formData.nome.trim(),
      email: formData.email.toLowerCase().trim(),
      telefone: formData.telefone.trim(),
      profissao: formData.profissao,
      genero: formData.genero,
      faixa_etaria: formData.faixa_etaria,
      nivel_escolaridade: formData.nivel_escolaridade,
      origem_evento: formData.origem_evento || null,
      evento_slug: eventoSlug || null,
    }),
  })

  const validation = await response.json()

  if (!response.ok) {
    // HIGH-06: do not leak the raw server/edge function error message to the
    // client. Log it for diagnostics but surface a generic message to the UI.
    if (validation.error) console.error('[inscription] validate-inscription error:', validation.error)
    throw new Error('Não foi possível validar a inscrição. Tenta novamente.')
  }

  if (validation.isDuplicate) {
    throw new Error('duplicate')
  }

  // 2. Insert into inscricoes
  const { data, error } = await supabase.from('inscricoes').insert({
    nome: formData.nome.trim(),
    email: formData.email.toLowerCase().trim(),
    telefone: formData.telefone.trim(),
    profissao: formData.profissao,
    genero: formData.genero,
    faixa_etaria: formData.faixa_etaria,
    nivel_escolaridade: formData.nivel_escolaridade,
    origem_evento: formData.origem_evento || null,
    evento_slug: eventoSlug || null,
  }).select('id').single()

  if (error) {
    // HIGH-06: keep Postgres / Supabase error.message on the server; the
    // user gets a stable, non-leaky message. Unique-constraint violations
    // still come back as `duplicate` via the Edge Function path, so the
    // generic message is acceptable for the rare client-side insert.
    console.error('[inscription] insert error:', error)
    throw new Error('Não foi possível submeter a inscrição. Tenta novamente.')
  }

  // 3. Send confirmation email (await with timeout)
  let emailSent = false
  if (eventoSlug) {
    const emailFnUrl = `${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/send-inscription-email`
    try {
      const controller = new AbortController()
      const timeout = setTimeout(() => controller.abort(), 5000)
      const emailRes = await fetch(emailFnUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${anonKey}`,
        },
        body: JSON.stringify({
          email: formData.email.toLowerCase().trim(),
          nome: formData.nome.trim(),
          evento_slug: eventoSlug,
        }),
        signal: controller.signal,
      })
      clearTimeout(timeout)
      emailSent = emailRes.ok
    } catch {
      emailSent = false
    }
  }

  return { success: true, emailSent, inscriptionId: data?.id }
}
