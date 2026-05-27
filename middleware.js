import { NextResponse } from 'next/server'
import { createServerClient } from '@supabase/ssr'

const SUPPORTED_LANGS = ['pt', 'en']
const DEFAULT_LANG = 'pt'

const PUBLIC_SECTIONS = [
  'artigos', 'eventos', 'lives', 'inscricao',
  'pesquisa', 'sobre', 'unsubscribe',
]

const ADMIN_SECTIONS = [
  'admin/dashboard', 'admin/artigos', 'admin/eventos',
  'admin/lives', 'admin/definicoes', 'admin/newsletter',
]

export async function middleware(request) {
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

  // Create Supabase client for session management
  const requestHeaders = new Headers(request.headers)
  requestHeaders.set('x-lang', lang)
  let supabaseResponse = NextResponse.next({ request: { headers: requestHeaders } })

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

  // Refresh session (necessary for Server Components)
  await supabase.auth.getUser()

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
  if (ADMIN_SECTIONS.some((s) => section.startsWith(s))) {
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
