'use client'

import { motion, MotionConfig } from 'framer-motion'
import UtilityBar from './UtilityBar'
import Header from './Header'
import MobileDrawer from './MobileDrawer'

// Chrome animado do layout público (utility bar + header + drawer mobile).
// Isolado num componente próprio para que o framer-motion seja carregado como
// chunk separado via next/dynamic no PublicLayout — o bundle inicial de todas as
// páginas públicas fica mais leve e a biblioteca é cacheada entre páginas.
export default function AnimatedChrome({
  lang,
  t,
  utilityBarVisible,
  drawerOpen,
  onToggleDrawer,
  onCloseDrawer,
}) {
  // utility=60 + header=80 (h-20)
  const UTILITY_HEIGHT = 60
  const HEADER_HEIGHT = 80

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
        <Header lang={lang} t={t} onToggleDrawer={onToggleDrawer} />
      </motion.div>
      <MobileDrawer
        lang={lang}
        t={t}
        open={drawerOpen}
        onClose={onCloseDrawer}
      />
    </MotionConfig>
  )
}
