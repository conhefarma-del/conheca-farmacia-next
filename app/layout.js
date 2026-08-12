import { Suspense } from 'react'
import { Inter, Fraunces } from 'next/font/google'
import { Analytics } from '@vercel/analytics/next'
import { SpeedInsights } from '@vercel/speed-insights/next'
import ThemeProvider from '@/components/providers/ThemeProvider'
import PageViewTracker from '@/components/content/PageViewTracker'
import { ANTI_FOUC_SCRIPT } from '@/lib/csp'
import '@/styles/globals.css'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  adjustFontFallback: true,
  variable: '--font-inter',
})

const fraunces = Fraunces({
  subsets: ['latin'],
  display: 'swap',
  adjustFontFallback: true,
  variable: '--font-fraunces',
})

export const metadata = {
  metadataBase: new URL('https://conhecafarmacia.com'),
  title: {
    default: 'Conheça Farmácia — Artigos, eventos e lives sobre saúde',
    template: '%s | Conheça Farmácia',
  },
  description:
    'Artigos, eventos e lives sobre saúde, farmácia e bem-estar em Angola. Conteúdo validado por profissionais de saúde, com inscrição online e newsletter gratuita.',
  openGraph: {
    title: 'Conheça Farmácia — Artigos, eventos e lives sobre saúde',
    description:
      'Artigos, eventos e lives sobre saúde, farmácia e bem-estar em Angola. Conteúdo validado por profissionais de saúde, com inscrição online e newsletter gratuita.',
    url: 'https://conhecafarmacia.com',
    siteName: 'Conheça Farmácia',
    locale: 'pt_PT',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Conheça Farmácia — Artigos, eventos e lives sobre saúde',
    description:
      'Artigos, eventos e lives sobre saúde, farmácia e bem-estar em Angola. Conteúdo validado por profissionais de saúde, com inscrição online e newsletter gratuita.',
  },
  icons: {
    icon: '/icon.png',
    apple: '/apple-icon.png',
  },
}

// Layout estático (sem headers()/cookies()) — permite ISR em todas as páginas
// públicas. O <html lang> é corrigido pré-pintura pelo ANTI_FOUC_SCRIPT
// (lib/csp.js) a partir do pathname (/pt vs /en); o CSP usa o SHA-256 desse
// mesmo script (proxy.js) — ver lib/csp.js.
export default function RootLayout({ children }) {
  return (
    <html lang="pt" suppressHydrationWarning className={`${inter.variable} ${fraunces.variable}`}>
      <head>
        {/* Anti-FOUC (dark mode) + fix de <html lang>. Permitido pela CSP
            do proxy via 'sha256-…' — o hash é do conteúdo EXATO deste
            script (lib/csp.js). suppressHydrationWarning evita mismatch
            em dev (Turbopack) onde o proxy não corre. */}
        <script
          suppressHydrationWarning
          dangerouslySetInnerHTML={{ __html: ANTI_FOUC_SCRIPT }}
        />
      </head>
      <body className={inter.className}>
        <ThemeProvider>
          <Suspense fallback={null}>
            <PageViewTracker />
          </Suspense>
          {children}
          <Analytics />
          <SpeedInsights />
        </ThemeProvider>
      </body>
    </html>
  )
}
