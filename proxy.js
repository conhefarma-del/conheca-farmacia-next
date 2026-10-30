import { NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'
import { cookieDomainFor } from '@/lib/cookie-domain'
import { ADMIN_ROLES } from '@/lib/admin-roles'

const SUPPORTED_LANGS = ['pt', 'en']
const DEFAULT_LANG = 'pt'

const PUBLIC_SECTIONS = [
  'artigos', 'eventos', 'lives', 'inscricao',
  'pesquisa', 'sobre', 'unsubscribe',
]

/**
 * ÁREA DE CONTA — vive na raiz (sem `[lang]`) e no host `conta.*`.
 *
 * O mesmo código serve os dois hosts: em `conta.conhecafarmacia.com` responde
 * aqui; nos restantes hosts estas rotas são enviadas para lá com 308 (e as
 * páginas antigas `/{lang}/entrar`, `/{lang}/registo`, … idem). Em
 * desenvolvimento (`localhost`) não há subdomínio, por isso as rotas são
 * servidas localmente — é assim que se testa o hub sem DNS.
 */
const ACCOUNT_SECTIONS = new Set(['entrar', 'registar', 'recuperar', 'auth', 'perfil'])

const LEGACY_ACCOUNT_PATHS = {
  entrar: '/entrar',
  registo: '/registar',
  register: '/registar',
  'esqueci-palavra-passe': '/recuperar',
  'repor-palavra-passe': '/perfil/seguranca',
  'conta-criada': '/perfil',
}

const origin = (value, fallback) => String(value || '').trim().replace(/\/+$/, '') || fallback

const ACCOUNT_ORIGIN = origin(
  process.env.NEXT_PUBLIC_ACCOUNT_ORIGIN,
  'https://conta.conhecafarmacia.com',
)
const SITE_ORIGIN = origin(
  process.env.NEXT_PUBLIC_SITE_URL,
  'https://www.conhecafarmacia.com',
)


const sectionOf = (pathname) => pathname.split('/')[1] || ''

export async function proxy(request) {
  const { pathname, search } = request.nextUrl
  const hostname = (request.headers.get('host') || '').split(':')[0].toLowerCase()
  const onCfDomain =
    hostname === 'conhecafarmacia.com' || hostname.endsWith('.conhecafarmacia.com')
  const onAccountHost = onCfDomain && hostname.startsWith('conta.')
  // Domínio da cookie decidido contra o host: em `*.vercel.app` o domínio
  // pai não se aplica e o browser recusava a cookie de sessão.
  const COOKIE_DOMAIN = cookieDomainFor(hostname)

  // ---------------------------------------------------------------------
  // conta.* — só a área de conta existe neste host.
  // ---------------------------------------------------------------------
  if (onAccountHost) {
    if (pathname === '/') {
      return NextResponse.redirect(new URL('/perfil', request.url))
    }
    if (!ACCOUNT_SECTIONS.has(sectionOf(pathname))) {
      // O site de conteúdos nunca aparece debaixo do endereço da conta.
      return NextResponse.redirect(`${SITE_ORIGIN}${pathname}${search}`, 308)
    }
  }

  // ---------------------------------------------------------------------
  // www / apex — as páginas de conta mudaram-se para conta.*.
  // ---------------------------------------------------------------------
  if (onCfDomain && !onAccountHost) {
    if (pathname === '/') {
      return NextResponse.redirect(new URL(`/${DEFAULT_LANG}`, request.url))
    }

    const segments = pathname.split('/')
    const first = segments[1]
    const legacy = SUPPORTED_LANGS.includes(first) ? LEGACY_ACCOUNT_PATHS[segments[2]] : null

    // O PERFIL DE ESTUDANTE fica aqui — é para `/{lang}/perfil` que o hub
    // manda (quizzes, competições, turma). As definições também: são o
    // idioma e as notificações do site, não a segurança da conta (essa vive
    // em `conta.*/perfil/seguranca`). As duas páginas usam o mesmo
    // AccountShell, por isso já não há razão para desviar uma delas.

    if (legacy) {
      // `search` preservado: um link de confirmação em curso não perde o código.
      return NextResponse.redirect(`${ACCOUNT_ORIGIN}${legacy}${search}`, 308)
    }
    if (!SUPPORTED_LANGS.includes(first) && ACCOUNT_SECTIONS.has(first)) {
      return NextResponse.redirect(`${ACCOUNT_ORIGIN}${pathname}${search}`, 308)
    }
  }

  // Root "/" → redirect to default language (dev e previews)
  if (pathname === '/') {
    return NextResponse.redirect(new URL(`/${DEFAULT_LANG}`, request.url))
  }

  // Extract lang from first path segment
  const lang = sectionOf(pathname)
  const isLangRoute = SUPPORTED_LANGS.includes(lang)
  const isAccountRoute = !isLangRoute && ACCOUNT_SECTIONS.has(lang)

  // If not a language route nor an account route, pass through (let Next 404)
  if (!isLangRoute && !isAccountRoute) {
    return NextResponse.next()
  }

  // Generate a per-request CSP nonce. Forwarded to the app via header
  // so app/layout.js can mark the anti-FOUC script with it. The same
  // nonce is injected into the CSP header below so the browser trusts
  // only the inline scripts that carry this exact nonce value. This
  // replaces the previous 'unsafe-inline' allowance in script-src.
  const nonce = Buffer.from(crypto.randomUUID()).toString('base64')

  // Content-Security-Policy built with the per-request nonce. We keep
  // the same directives as the previous static vercel.json CSP so the
  // site's resource-loading behaviour is unchanged, but we tighten
  // script-src from 'unsafe-inline' to 'nonce-...'.
  const csp = [
    `default-src 'self'`,
    `script-src 'self' 'nonce-${nonce}' https://vercel.live https://www.youtube.com https://s.ytimg.com`,
    `style-src 'self' 'unsafe-inline' https://fonts.googleapis.com`,
    `img-src 'self' data: blob: https://*.supabase.co https://vercel.live https://i.ytimg.com https://img.youtube.com`,
    `media-src 'self' blob: https://*.supabase.co https://*.spotify.com https://*.scdn.co https://*.spotifycdn.com https://*.soundcloud.com https://*.sndcdn.com`,
    `font-src 'self' https://fonts.gstatic.com`,
    `connect-src 'self' https://*.supabase.co https://vercel.live https://www.youtube.com https://s.ytimg.com https://open.spotify.com https://*.spotifycdn.com https://*.soundcloud.com https://*.sndcdn.com https://music.youtube.com`,
    `frame-src https://www.google.com https://maps.google.com https://www.youtube.com https://www.youtube-nocookie.com https://open.spotify.com https://w.soundcloud.com https://player.soundcloud.com https://music.youtube.com https://vercel.live`,
    `frame-ancestors 'none'`,
    `object-src 'none'`,
    `base-uri 'self'`,
    `form-action 'self'`,
  ].join('; ')

  // Create Supabase client for session management
  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-lang', isLangRoute ? lang : DEFAULT_LANG)
  requestHeaders.set('x-csp-nonce', nonce)
  let supabaseResponse = NextResponse.next({
    request: { headers: requestHeaders },
    headers: {
      'Content-Security-Policy': csp,
      'x-csp-nonce': nonce,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value }) =>
            request.cookies.set(name, value)
          )
          supabaseResponse = NextResponse.next({ request: { headers: requestHeaders } })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(
              name,
              value,
              COOKIE_DOMAIN ? { ...options, domain: COOKIE_DOMAIN } : options,
            )
          )
        },
      },
    }
  )

  // HIGH-07: refresh session, but never crash the whole site if Supabase
  // auth is unreachable. A failing getUser() must not take down public
  // routes — only the admin protection below should depend on the result.
  try {
    await supabase.auth.getUser()
  } catch (proxyErr) {
    console.error('[proxy] getUser failed, continuing without session refresh', {
      lang,
      path: pathname,
      message: proxyErr?.message,
    })
  }

  // Área de conta: CSP aplicada + sessão renovada. Não há secções a proteger
  // aqui — cada página decide (o hub redirecciona para /entrar sem sessão).
  if (!isLangRoute) {
    return supabaseResponse
  }

  // Extract section after lang: /pt/admin/dashboard → admin/dashboard
  const section = pathname.split('/').slice(2).join('/')

  // Public routes: pass through
  if (section === '' || PUBLIC_SECTIONS.some((s) => section.startsWith(s))) {
    return supabaseResponse
  }

  // Admin login page: /{lang}/admin
  if (section === 'admin') {
    const { data: { user } } = await supabase.auth.getUser()
    if (user) {
      // Existir linha não é ser admin: `admin_users` também guarda as
      // contas `farmacia` do portal.
      const { data: adminUser } = await supabase
        .from('admin_users')
        .select('user_id, role')
        .eq('user_id', user.id)
        .in('role', ADMIN_ROLES)
        .single()
      if (adminUser) {
        return NextResponse.redirect(new URL(`/${lang}/admin/dashboard`, request.url))
      }
    }
    return supabaseResponse
  }

  // Protected admin routes: /{lang}/admin/*
  if (section.startsWith("admin/")) {
    const { data: { user } } = await supabase.auth.getUser()

    if (!user) {
      return NextResponse.redirect(new URL(`/${lang}/admin`, request.url))
    }

    // SEC-ATH-02: Never trust session alone — verify admin_users, e o
    // `role` (as contas de farmácia vivem na mesma tabela).
    const { data: adminUser, error } = await supabase
      .from('admin_users')
      .select('user_id, role')
      .eq('user_id', user.id)
      .in('role', ADMIN_ROLES)
      .single()

    if (error || !adminUser) {
      // Sem `signOut`: a sessão é da conta pessoal, partilhada com o site e
      // o Localizador. Sair aqui desligava a pessoa de todo o lado.
      return NextResponse.redirect(new URL(`/${lang}/admin`, request.url))
    }

    return supabaseResponse
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
