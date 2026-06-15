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
  const HEADER_OFFSET = utilityBarVisible ? 60 : 0
  const MAIN_PADDING_TOP = utilityBarVisible ? 140 : 80

  return (
    <>
      <div
        className="utility-bar-wrapper"
        style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          zIndex: 60,
          transform: utilityBarVisible ? 'translateY(0)' : 'translateY(-100%)',
          transition: 'transform 0.4s cubic-bezier(0.22, 1, 0.36, 1)',
        }}
      >
        <UtilityBar lang={lang} t={t} />
      </div>
      <div
        className="header-wrapper"
        style={{
          position: 'fixed',
          top: HEADER_OFFSET,
          left: 0,
          right: 0,
          zIndex: 50,
          transition: 'top 0.4s cubic-bezier(0.22, 1, 0.36, 1)',
        }}
      >
        <Header lang={lang} t={t} onToggleDrawer={() => setDrawerOpen(!drawerOpen)} />
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
