'use client'

import { useState, useEffect, useRef, useContext } from 'react'
import dynamic from 'next/dynamic'
import { LangContext } from '@/lib/contexts'
import Footer from '@/components/layout/Footer'

// O chrome animado (utility bar + header + drawer) é isolado em AnimatedChrome e
// carregado com next/dynamic: o framer-motion sai do bundle principal do layout e
// passa a ser um chunk separado, cacheado entre páginas. Todas as páginas públicas
// beneficiam de um bundle inicial mais leve.
const AnimatedChrome = dynamic(
  () => import('@/components/layout/AnimatedChrome'),
  {
    // SSR ligado: o header/utility bar ficam no HTML inicial (sem flash nem perda
    // de SEO). O fallback vazio só aparece em navegações suaves antes do chunk.
    ssr: true,
    loading: () => null,
  }
)

export default function PublicLayout({ children }) {
  const { lang, translations, t } = useContext(LangContext)
  const [drawerOpen, setDrawerOpen] = useState(false)
  const [utilityBarVisible, setUtilityBarVisible] = useState(true)
  const lastScrollY = useRef(0)
  const ticking = useRef(false)

  useEffect(() => {
    const handleScroll = () => {
      if (ticking.current) return
      ticking.current = true

      requestAnimationFrame(() => {
        const currentY = window.scrollY
        const scrollDelta = currentY - lastScrollY.current

        // Show utility bar on scroll up, hide on scroll down
        // Only toggle after a small threshold to avoid jitter
        if (scrollDelta < -10) {
          setUtilityBarVisible(true)
        } else if (scrollDelta > 10) {
          setUtilityBarVisible(false)
        }

        lastScrollY.current = currentY
        ticking.current = false
      })
    }

    window.addEventListener('scroll', handleScroll, { passive: true })
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  // Mirror utilityBarVisible to <body> class so the mobile drawer can adjust
  // its top offset (utility bar hidden → drawer sits below the header only).
  useEffect(() => {
    if (utilityBarVisible) {
      document.body.classList.remove('utility-hidden')
    } else {
      document.body.classList.add('utility-hidden')
    }
    return () => document.body.classList.remove('utility-hidden')
  }, [utilityBarVisible])

  // utility=60 + header=80 (h-20)
  const UTILITY_HEIGHT = 60
  const HEADER_HEIGHT = 80
  const MAIN_PADDING_TOP = utilityBarVisible ? UTILITY_HEIGHT + HEADER_HEIGHT : HEADER_HEIGHT

  return (
    <>
      <AnimatedChrome
        lang={lang}
        t={t}
        utilityBarVisible={utilityBarVisible}
        drawerOpen={drawerOpen}
        onToggleDrawer={() => setDrawerOpen((open) => !open)}
        onCloseDrawer={() => setDrawerOpen(false)}
      />
      <main style={{ paddingTop: MAIN_PADDING_TOP, overflowX: 'hidden' }}>{children}</main>
      <Footer lang={lang} t={t} />
    </>
  )
}
