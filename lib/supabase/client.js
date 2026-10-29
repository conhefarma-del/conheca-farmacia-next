'use client'

import { createBrowserClient } from '@supabase/ssr'

/**
 * Sessão partilhada entre hosts.
 *
 * Com `Domain=.conhecafarmacia.com` a mesma cookie de sessão é enviada a
 * `www`, `conta` e `localizador` — é isto que faz «uma conta nos dois sites».
 * Em desenvolvimento fica `undefined` de propósito: o browser recusa
 * `Domain=.conhecafarmacia.com` em `localhost` e a sessão desaparecia.
 */
const COOKIE_DOMAIN = process.env.NEXT_PUBLIC_COOKIE_DOMAIN || undefined

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    COOKIE_DOMAIN ? { cookieOptions: { domain: COOKIE_DOMAIN } } : undefined
  )
}
