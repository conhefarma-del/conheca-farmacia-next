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

  return (
    <>
      <div
        className="utility-bar-wrapper"
        style={{
          position: 'sticky',
          top: 0,
          zIndex: 60,
          transform: utilityBarVisible ? 'translateY(0)' : 'translateY(-100%)',
          transition: 'transform 0.4s cubic-bezier(0.22, 1, 0.36, 1)',
        }}
      >
        <UtilityBar lang={lang} t={t} />
      </div>
      <Header lang={lang} t={t} onToggleDrawer={() => setDrawerOpen(!drawerOpen)} />
      <MobileDrawer
        lang={lang}
        t={t}
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
      />
      <main>{children}</main>
      <Footer lang={lang} t={t} />
    </>
  )
}
