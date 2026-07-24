import { Suspense } from 'react'
import { headers } from 'next/headers'
import { Analytics } from '@vercel/analytics/next'
import { SpeedInsights } from '@vercel/speed-insights/next'
import ThemeProvider from '@/components/providers/ThemeProvider'
import PageViewTracker from '@/components/content/PageViewTracker'
import '@/styles/globals.css'

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

export default async function RootLayout({ children }) {
  const headersList = await headers()
  const lang = headersList.get('x-lang') || 'pt'
  // CSP nonce set by proxy.js on every request. Applied to the anti-
  // FOUC inline script so vercel.json's strict script-src (no
  // 'unsafe-inline') lets it through. Falls back to undefined on
  // routes the proxy does not match (which is fine — those routes
  // do not have CSP headers either).
  const nonce = headersList.get('x-csp-nonce') || undefined

  return (
    <html lang={lang} suppressHydrationWarning>
      <head>
        {/* Anti-FOUC: set dark class before hydration. The CSP nonce
            lets this inline script run under our strict Content-Security-
            Policy (vercel.json uses 'nonce-${nonce}' instead of
            'unsafe-inline' in script-src). Without the nonce, the CSP
            would block this script. */}
        {/* O nonce é passado via spread condicional para evitar
            hydration mismatch em dev (Turbopack não corre o proxy,
            então o servidor serializa nonce="" enquanto o cliente 
            pode ter um nonce real do HMR). Em prod o proxy injecta
            x-csp-nonce consistentemente antes da SSR. */}
        <script
          {...(nonce ? { nonce } : {})}
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var t=localStorage.getItem('theme');var d=t==='dark'||(!t&&matchMedia('(prefers-color-scheme:dark)').matches);if(d)document.documentElement.classList.add('dark')}catch(e){}})()`,
          }}
        />
      </head>
      <body>
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
