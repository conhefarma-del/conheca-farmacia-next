import { NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'

const SUPPORTED_LANGS = ['pt', 'en']
const DEFAULT_LANG = 'pt'

const PUBLIC_SECTIONS = [
  'artigos', 'eventos', 'lives', 'inscricao',
  'pesquisa', 'sobre', 'unsubscribe',
]


export async function proxy(request) {
  const { pathname } = request.nextUrl

  // Root "/" → redirect to default language
  if (pathname === '/') {
    return NextResponse.redirect(new URL(`/${DEFAULT_LANG}`, request.url))
  }

  // Extract lang from first path segment
  const lang = pathname.split('/')[1]

  // If not a supported language, pass through (let Next.js handle 404)
  if (!SUPPORTED_LANGS.includes(lang)) {
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
  requestHeaders.set('x-lang', lang)
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
            supabaseResponse.cookies.set(name, value, options)
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
      const { data: adminUser } = await supabase
        .from('admin_users')
        .select('user_id')
        .eq('user_id', user.id)
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

    // SEC-ATH-02: Never trust session alone — verify admin_users
    const { data: adminUser, error } = await supabase
      .from('admin_users')
      .select('user_id')
      .eq('user_id', user.id)
      .single()

    if (error || !adminUser) {
      await supabase.auth.signOut()
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
