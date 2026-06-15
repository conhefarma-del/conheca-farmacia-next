import { Suspense } from 'react'
import { headers } from 'next/headers'
import { Inter, Fraunces } from 'next/font/google'
import { Analytics } from '@vercel/analytics/next'
import { SpeedInsights } from '@vercel/speed-insights/next'
import ThemeProvider from '@/components/providers/ThemeProvider'
import PageViewTracker from '@/components/content/PageViewTracker'
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

export default async function RootLayout({ children }) {
  const headersList = await headers()
  const lang = headersList.get('x-lang') || 'pt'

  return (
    <html lang={lang} suppressHydrationWarning className={`${inter.variable} ${fraunces.variable}`}>
      <head>
        {/* Anti-FOUC: set dark class before hydration */}
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var t=localStorage.getItem('theme');var d=t==='dark'||(!t&&matchMedia('(prefers-color-scheme:dark)').matches);if(d)document.documentElement.classList.add('dark')}catch(e){}})()`,
          }}
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
