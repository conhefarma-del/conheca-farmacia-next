'use client'

import { useState, useEffect, useRef } from 'react'
import { motion, MotionConfig } from 'framer-motion'
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

  // Spring partilhado: utility bar e header usam a MESMA física de mola, por isso
  // deslizam em sincronia num único movimento suave quando a utility some no scroll.
  const slideSpring = { type: 'spring', stiffness: 380, damping: 38, mass: 0.9 }

  return (
    <MotionConfig reducedMotion="user">
      {/* A utility bar mantém-se como elemento separado, sempre visível acima do
          header. No scroll desliza para cima (-60px) enquanto o header sobe 60px
          em simultâneo, animados pela mesma mola (framer-motion) — movimento único,
          sem «cola». O drawer (mobile) empurra apenas o header + conteúdo, deixando
          a utility bar visível por cima. */}
      <motion.div
        className="utility-bar-wrapper"
        initial={false}
        animate={{ y: utilityBarVisible ? 0 : -UTILITY_HEIGHT }}
        transition={slideSpring}
        style={{ position: 'fixed', top: 0, left: 0, right: 0, zIndex: 60, willChange: 'transform' }}
      >
        <UtilityBar lang={lang} t={t} />
      </motion.div>
      <motion.div
        className="header-wrapper"
        initial={false}
        animate={{ y: utilityBarVisible ? UTILITY_HEIGHT : 0 }}
        transition={slideSpring}
        style={{ position: 'fixed', top: 0, left: 0, right: 0, zIndex: 50, willChange: 'transform' }}
      >
        <Header lang={lang} t={t} onToggleDrawer={() => setDrawerOpen(!drawerOpen)} />
      </motion.div>
      <MobileDrawer
        lang={lang}
        t={t}
        open={drawerOpen}
        onClose={() => setDrawerOpen(false)}
      />
      <main style={{ paddingTop: MAIN_PADDING_TOP }}>{children}</main>
      <Footer lang={lang} t={t} />
    </MotionConfig>
  )
}
