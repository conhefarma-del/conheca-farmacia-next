'use client'

import { useEffect, useRef, useContext } from 'react'
import { LangContext } from '@/lib/contexts'

const PHRASES = [
  { key: 'hero.animated_text', icon: '/assets/icons/Asset 1-branco.svg' },
  { key: 'hero.animated_eventos', icon: '/assets/icons/Asset 7-branco.svg' },
  { key: 'hero.animated_conteudo', icon: '/assets/icons/Asset 11-branco.svg' },
  { key: 'hero.animated_artigos', icon: '/assets/icons/Asset 15-branco.svg' },
  { key: 'hero.animated_lives', icon: '/assets/icons/Asset 20-branco.svg' },
]

const CYCLE_INTERVAL = 2500
const ANIMATION_DURATION = 300

export default function HeroAnimated() {
  const { t } = useContext(LangContext)

  // Refs for imperative DOM manipulation (matches original hero-animated.js)
  const containerRef = useRef(null)
  const cardIconRef = useRef(null)
  const cardTextRef = useRef(null)
  const tickerTopRef = useRef(null)
  const tickerBottomRef = useRef(null)

  const stateRef = useRef({
    currentIndex: 0,
    exitHistory: [],
    intervalId: null,
  })

  // Store t() in a ref so the interval callback always has the latest translations
  const tRef = useRef(t)
  tRef.current = t

  useEffect(() => {
    const container = containerRef.current
    if (!container) return

    const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches

    function getPhraseText(index) {
      return tRef.current(PHRASES[index].key)
    }

    function renderTickerTop() {
      const tickerTop = tickerTopRef.current
      if (!tickerTop) return
      const { exitHistory } = stateRef.current
      const reversed = [...exitHistory].reverse()
      let lines = tickerTop.querySelectorAll('.hero-ticker-text')

      // Add or remove elements to match
      while (lines.length < reversed.length) {
        const el = document.createElement('span')
        el.className = 'hero-ticker-text'
        tickerTop.appendChild(el)
        lines = tickerTop.querySelectorAll('.hero-ticker-text')
      }
      while (lines.length > reversed.length) {
        lines[lines.length - 1].remove()
        lines = tickerTop.querySelectorAll('.hero-ticker-text')
      }

      // Update in place (no innerHTML clear)
      reversed.forEach((idx, i) => {
        const isRecent = i === reversed.length - 1
        lines[i].textContent = getPhraseText(idx)
        lines[i].className = 'hero-ticker-text' + (isRecent ? ' hero-ticker-text--prominent' : '')
        lines[i].style.transition = 'none'
        lines[i].style.transform = ''
        lines[i].style.opacity = ''
      })
    }

    function renderTickerBottom() {
      const tickerBottom = tickerBottomRef.current
      if (!tickerBottom) return
      const { currentIndex } = stateRef.current
      const lines = tickerBottom.querySelectorAll('.hero-ticker-text')
      if (lines.length < 2) return

      // Line 1 = next phrase (prominent)
      const idx1 = (currentIndex + 1) % PHRASES.length
      lines[0].textContent = getPhraseText(idx1)
      lines[0].className = 'hero-ticker-text hero-ticker-text--prominent'
      lines[0].style.transition = 'none'
      lines[0].style.transform = ''
      lines[0].style.opacity = ''

      // Line 2 = phrase after next
      const idx2 = (currentIndex + 2) % PHRASES.length
      lines[1].textContent = getPhraseText(idx2)
      lines[1].className = 'hero-ticker-text'
      lines[1].style.transition = 'none'
      lines[1].style.transform = ''
      lines[1].style.opacity = ''
    }

    function cycle() {
      const cardText = cardTextRef.current
      const cardIcon = cardIconRef.current
      const tickerBottom = tickerBottomRef.current
      const tickerTop = tickerTopRef.current
      if (!cardText || !cardIcon) return

      // --- BATCH ALL READS (before any writes) ---
      let bottomDistance = 0
      let topDistance = 0
      let topLine2Height = 0

      const bottomLines = tickerBottom ? tickerBottom.querySelectorAll('.hero-ticker-text') : []
      if (bottomLines.length >= 2) {
        const rect1 = bottomLines[0].getBoundingClientRect()
        const rect2 = bottomLines[1].getBoundingClientRect()
        bottomDistance = rect2.top - rect1.top
      }

      const topLines = tickerTop ? tickerTop.querySelectorAll('.hero-ticker-text') : []
      if (topLines.length >= 2) {
        // prominent is the last child (closest to card)
        const line1 = topLines[topLines.length - 1]
        const line2 = topLines[0]
        const rect1 = line1.getBoundingClientRect()
        const rect2 = line2.getBoundingClientRect()
        topDistance = rect2.top - rect1.top
        topLine2Height = rect2.height
      }

      // --- BATCH ALL WRITES ---

      // 1. Ticker bottom: Line 2 → Line 1, Line 1 slides up and disappears
      if (bottomLines.length >= 2) {
        const line1 = bottomLines[0]
        const line2 = bottomLines[1]

        line1.style.transition = 'transform 0.4s ease, opacity 0.4s ease'
        line1.style.transform = `translateY(-${bottomDistance}px)`
        line1.style.opacity = '0'

        line2.style.transition = 'transform 0.4s ease, opacity 0.4s ease'
        line2.style.transform = `translateY(-${bottomDistance}px)`
        line2.classList.add('hero-ticker-text--prominent')
      }

      // 2. Ticker top: Line 1 → Line 2, Line 2 slides up and disappears
      if (topLines.length >= 2) {
        const line1 = topLines[topLines.length - 1]
        const line2 = topLines[0]

        line2.style.transition = 'transform 0.4s ease, opacity 0.4s ease'
        line2.style.transform = `translateY(-${topLine2Height + 10}px)`
        line2.style.opacity = '0'

        line1.style.transition = 'transform 0.4s ease, opacity 0.4s ease'
        line1.style.transform = `translateY(${topDistance}px)`
        line1.classList.remove('hero-ticker-text--prominent')
      }

      // 3. Slide card text + icon UP and out
      cardText.style.transition = 'transform 0.3s ease, opacity 0.3s ease'
      cardText.style.transform = 'translateY(-120%)'
      cardText.style.opacity = '0'

      cardIcon.style.transition = 'transform 0.3s ease, opacity 0.3s ease'
      cardIcon.style.transform = 'translateY(-120%)'
      cardIcon.style.opacity = '0'

      setTimeout(() => {
        // 4. Add exited phrase to history
        stateRef.current.exitHistory.unshift(stateRef.current.currentIndex)
        if (stateRef.current.exitHistory.length > 2) stateRef.current.exitHistory.pop()

        // 5. Update ticker top
        renderTickerTop()

        // 6. Move to next phrase
        stateRef.current.currentIndex = (stateRef.current.currentIndex + 1) % PHRASES.length

        // 7. Update card content
        cardText.textContent = getPhraseText(stateRef.current.currentIndex)
        cardIcon.src = PHRASES[stateRef.current.currentIndex].icon

        // 8. Slide card IN from bottom (rAF double — no offsetHeight forced reflow)
        cardText.style.transition = 'none'
        cardText.style.transform = 'translateY(120%)'
        cardText.style.opacity = '0'

        cardIcon.style.transition = 'none'
        cardIcon.style.transform = 'translateY(120%)'
        cardIcon.style.opacity = '0'

        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            cardText.style.transition = 'transform 0.35s cubic-bezier(0.4,0,0.2,1), opacity 0.35s ease'
            cardText.style.transform = 'translateY(0)'
            cardText.style.opacity = '1'

            cardIcon.style.transition = 'transform 0.35s cubic-bezier(0.4,0,0.2,1), opacity 0.35s ease'
            cardIcon.style.transform = 'translateY(0)'
            cardIcon.style.opacity = '1'
          })
        })

        // 9. Update ticker bottom
        renderTickerBottom()
      }, ANIMATION_DURATION)
    }

    function startCycle() {
      if (stateRef.current.intervalId) return
      stateRef.current.intervalId = setInterval(cycle, CYCLE_INTERVAL)
    }

    function stopCycle() {
      if (stateRef.current.intervalId) {
        clearInterval(stateRef.current.intervalId)
        stateRef.current.intervalId = null
      }
    }

    // Initialize: set initial card content
    cardTextRef.current.textContent = getPhraseText(0)
    cardIconRef.current.src = PHRASES[0].icon

    // Create 2 ticker-bottom lines
    for (let i = 0; i < 2; i++) {
      const el = document.createElement('span')
      el.className = 'hero-ticker-text' + (i === 0 ? ' hero-ticker-text--prominent' : '')
      tickerBottomRef.current.appendChild(el)
    }

    renderTickerBottom()

    if (prefersReducedMotion) return

    startCycle()

    const handleVisibility = () => {
      if (document.hidden) stopCycle()
      else startCycle()
    }
    document.addEventListener('visibilitychange', handleVisibility)

    return () => {
      stopCycle()
      document.removeEventListener('visibilitychange', handleVisibility)
    }
  }, [])

  return (
    <div className="hero-animated" ref={containerRef} aria-label="Serviços principais">
      {/* Ticker top (above card) */}
      <div className="hero-ticker-top" ref={tickerTopRef} aria-hidden="true" />

      {/* Card */}
      <div className="hero-animated-card">
        {/* eslint-disable-next-line @next/next/no-img-element */}
        <img
          ref={cardIconRef}
          src="/assets/icons/Asset 1-branco.svg"
          alt=""
          className="hero-animated-icon"
          aria-hidden="true"
        />
        <span ref={cardTextRef} className="hero-animated-text" />
      </div>

      {/* Ticker bottom (below card) */}
      <div className="hero-ticker-bottom" ref={tickerBottomRef} aria-hidden="true" />
    </div>
  )
}
