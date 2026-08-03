'use client'

import { useState, useEffect, useRef } from 'react'
import { LangContext } from '@/lib/contexts'
import { useContext } from 'react'
import UtilityBar from '@/components/layout/UtilityBar'
import Header from '@/components/layout/Header'
import MobileDrawer from '@/components/layout/MobileDrawer'
import Footer from '@/components/layout/Footer'

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
      {/* Chrome superior: utility bar + header movem-se como UMA única unidade
          fixa. O scroll esconde/revela a utility bar deslocando o bloco inteiro
          -60px — a utility sai e o header aterra no topo num único movimento.
          O drawer (mobile) empurra apenas o conteúdo interno (.site-header-inner),
          mantendo utility + header sempre alinhados entre si e com o main. */}
      <div className="site-header">
        <div className="site-header-inner">
          <UtilityBar lang={lang} t={t} />
          <Header lang={lang} t={t} onToggleDrawer={() => setDrawerOpen(!drawerOpen)} />
        </div>
      </div>
      <MobileDrawer
        lang={lang}
        t={t}
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
      />
      <main style={{ paddingTop: MAIN_PADDING_TOP }}>{children}</main>
      <Footer lang={lang} t={t} />
    </>
  )
}
