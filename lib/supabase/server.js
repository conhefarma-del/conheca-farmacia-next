import { createServerClient } from '@supabase/ssr'
import { cookies, headers } from 'next/headers'
import { cookieDomainFor } from '@/lib/cookie-domain'

/**
 * Mesmo domínio de cookie que `lib/supabase/client.js`. Sem o `domain` aqui,
 * uma sessão gravada por uma Server Action ficava *host-only* e o outro
 * subdomínio não a via — o bug clássico de «entrei em conta.* e o site não
 * sabe quem sou». O domínio só entra quando o host pertence a ele
 * (`lib/cookie-domain.js`), para `localhost` e previews continuarem a
 * funcionar.
 */
async function buildClient(schema) {
  const cookieStore = await cookies()
  const h = await headers()
  const COOKIE_DOMAIN = cookieDomainFor(h.get('host'))

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    {
      // Um projecto, dois schemas: `public` é o site (por omissão) e
      // `localizador` é o catálogo do Localizador, onde vivem os guardados da
      // conta (`localizador.favorites`). Só quem pede o schema é que o define.
      ...(schema ? { db: { schema } } : {}),
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, COOKIE_DOMAIN ? { ...options, domain: COOKIE_DOMAIN } : options)
            )
          } catch {
            // Server Component — cannot modify cookies
          }
        },
      },
    }
  )
}

export async function createClient() {
  return buildClient(null)
}

/**
 * Cliente com a mesma sessão, mas a ler `localizador`. Usado pelo hub da conta
 * para os medicamentos e farmácias guardados; a policy `user_id = auth.uid()`
 * continua a ser a autoridade — este cliente não tem service role.
 */
export async function createLocalizadorClient() {
  return buildClient('localizador')
}
