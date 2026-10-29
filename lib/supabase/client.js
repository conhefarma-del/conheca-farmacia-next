'use client'

import { createBrowserClient } from '@supabase/ssr'
import { cookieDomainFor } from '@/lib/cookie-domain'

/**
 * Sessão partilhada entre hosts.
 *
 * Com `Domain=.conhecafarmacia.com` a mesma cookie de sessão é enviada a
 * `www`, `conta` e `localizador` — é isto que faz «uma conta nos dois sites».
 * O domínio só é aplicado quando o host pertence mesmo a ele
 * (`lib/cookie-domain.js`): em `localhost` e nas previews `*.vercel.app` o
 * browser recusa `Domain=.conhecafarmacia.com` em silêncio e a sessão
 * desaparecia.
 */
export function createClient() {
  const dominio = cookieDomainFor(
    typeof window === 'undefined' ? null : window.location.hostname,
  )

  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    dominio ? { cookieOptions: { domain: dominio } } : undefined
  )
}
