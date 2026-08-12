import { createServerClient } from '@supabase/ssr'

/**
 * Cliente Supabase server-side SEM cookies — para leituras públicas.
 *
 * Ao contrário de `createClient()` (lib/supabase/server.js), NÃO lê
 * `next/headers`, o que permite renderização estática / ISR (as páginas
 * deixam de ser obrigatoriamente dinâmicas só por consultarem a BD).
 *
 * A RLS anónima (anon key) filtra apenas conteúdo publicado — é o mesmo
 * comportamento de leitura que as páginas públicas já tinham, sem a sessão.
 *
 * NUNCA usar onde é preciso a sessão do utilizador: admin, feedback,
 * newsletter, auth, inscrições (escritas) — esses continuam em
 * `lib/supabase/server.js` (cookie-based).
 */
export function createAnonClient() {
  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    {
      cookies: {
        getAll: () => [],
        setAll: () => {},
      },
    }
  )
}
