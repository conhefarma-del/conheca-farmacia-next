import { Suspense } from 'react'
import { headers } from 'next/headers'
import ThemeProvider from '@/components/providers/ThemeProvider'
import PageViewTracker from '@/components/content/PageViewTracker'
import '@/styles/globals.css'

export const metadata = {
  metadataBase: new URL('https://conhecafarmacia.vercel.app'),
  title: 'Conheça Farmácia',
  description: 'Portal de saúde e farmácia',
}

export default async function RootLayout({ children }) {
  const headersList = await headers()
  const lang = headersList.get('x-lang') || 'pt'

  return (
    <html lang={lang} suppressHydrationWarning>
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Fraunces:ital,opsz,wght@0,9..144,100..900;1,9..144,100..900&family=Inter:wght@100..900&display=swap"
          rel="stylesheet"
        />
        {/* Anti-FOUC: set dark class before hydration */}
        <script
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
        </ThemeProvider>
      </body>
    </html>
  )
}
