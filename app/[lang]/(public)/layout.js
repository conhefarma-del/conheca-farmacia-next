'use client'

import { useState } from 'react'
import { LangContext } from '@/lib/contexts'
import { useContext } from 'react'
import UtilityBar from '@/components/layout/UtilityBar'
import Header from '@/components/layout/Header'
import MobileDrawer from '@/components/layout/MobileDrawer'
import Footer from '@/components/layout/Footer'

export default function PublicLayout({ children }) {
  const { lang, translations, t } = useContext(LangContext)
  const [drawerOpen, setDrawerOpen] = useState(false)

  return (
    <>
      <UtilityBar lang={lang} t={t} />
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
