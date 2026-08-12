'use client'

import { useLayoutEffect, useRef, useContext } from 'react'
import gsap from 'gsap'
import { LangContext } from '@/lib/contexts'

const PHRASES = [
  { key: 'hero.animated_text', icon: '/assets/icons/Asset 1-branco.svg' },
  { key: 'hero.animated_eventos', icon: '/assets/icons/Asset 7-branco.svg' },
  { key: 'hero.animated_conteudo', icon: '/assets/icons/Asset 11-branco.svg' },
  { key: 'hero.animated_artigos', icon: '/assets/icons/Asset 15-branco.svg' },
  { key: 'hero.animated_lives', icon: '/assets/icons/Asset 20-branco.svg' },
]

const EXIT_DURATION = 0.3
const SLIDE_IN_DURATION = 0.4
const HOLD_DURATION = 0.5
const CYCLE_INTERVAL = 2.0
const REPEAT_DELAY = CYCLE_INTERVAL - EXIT_DURATION - SLIDE_IN_DURATION - HOLD_DURATION

/**
 * Ticker vertical que mostra, em cada momento, o estado passado/futuro do card.
 *
 * Layout (de cima para baixo):
 *   [t2] histórico distante  (opacity 0.35)
 *   [t1] histórico recente   (opacity 0.7 + scale 1.28)
 *   [card] actual
 *   [b1] próximo              (opacity 0.7 + scale 1.28)
 *   [b2] a seguir             (opacity 0.35)
 *
 * Em cada ciclo (a cada CYCLE_INTERVAL):
 *   1. EXIT (0.3s): card sobe e sai pela 1ª linha do top.
 *      t1 do top sobe uma posição (vira t2, perde scale).
 *      t2 do top sobe e desaparece.
 *      b1 do bottom sobe e vira o novo card.
 *      b2 do bottom sobe e vira t1 (ganha scale + opacity 0.7).
 *   2. SWAP: actualizar DOM (textos, ícones, classes).
 *   3. SLIDE-IN (0.4s): card novo aparece (fade-in) na sua posição central.
 *   4. HOLD (0.5s): card fica parado, visível.
 *   5. REPEAT_DELAY: pausa até CYCLE_INTERVAL.
 */
export default function HeroAnimated() {
  const { t } = useContext(LangContext)
  const rootRef = useRef(null)
  const t2Ref = useRef(null)
  const t1Ref = useRef(null)
  const cardIconRef = useRef(null)
  const cardTextRef = useRef(null)
  const b1Ref = useRef(null)
  const b2Ref = useRef(null)

  useLayoutEffect(() => {
    if (typeof window === 'undefined') return

    const prefersReducedMotion = window.matchMedia(
      '(prefers-reduced-motion: reduce)'
    ).matches

    const rootEl = rootRef.current
    const t2 = t2Ref.current
    const t1 = t1Ref.current
    const cardIcon = cardIconRef.current
    const cardText = cardTextRef.current
    const b1 = b1Ref.current
    const b2 = b2Ref.current
    if (!rootEl || !t2 || !t1 || !cardIcon || !cardText || !b1 || !b2) return

    const total = PHRASES.length
    let currentIndex = 0

    function getText(idx) {
      return t(PHRASES[idx].key)
    }

    function applySlotContent(el, idx, prominent) {
      el.textContent = getText(idx)
      el.classList.toggle('hero-ticker-text--prominent', !!prominent)
    }

    function render() {
      const prev = (currentIndex - 1 + total) % total
      const prev2 = (currentIndex - 2 + total) % total
      const next = (currentIndex + 1) % total
      const next2 = (currentIndex + 2) % total

      applySlotContent(t2, prev2, false)
      applySlotContent(t1, prev, true)
      cardText.textContent = getText(currentIndex)
      cardIcon.src = PHRASES[currentIndex].icon
      applySlotContent(b1, next, true)
      applySlotContent(b2, next2, false)
    }

    render()

    if (prefersReducedMotion) return

    // Distância vertical entre duas linhas consecutivas (altura + gap).
    // Usamos t1 e t2, ambos já renderizados e em row no flex column do tickerTop.
    const r1 = t1.getBoundingClientRect()
    const r2 = t2.getBoundingClientRect()
    const lineStep = Math.abs(r2.top - r1.top)
    const lineHeight = r1.height

    const tl = gsap.timeline({ repeat: -1, repeatDelay: REPEAT_DELAY, paused: true })

    function buildIteration() {
      // --- EXIT: tudo sobe `lineStep` px em paralelo ---
      // Translação vertical de todos os 5 elementos
      tl.to(
        [t2, t1, cardText, cardIcon, b1, b2],
        { y: -lineStep, duration: EXIT_DURATION, ease: 'power2.inOut' },
        0
      )

      // Card perde opacidade (vai sair de cena)
      tl.to(
        [cardText, cardIcon],
        { opacity: 0, duration: EXIT_DURATION, ease: 'power2.in' },
        0
      )

      // t2 (histórico distante) continua a subir e desaparece
      tl.to(
        t2,
        {
          y: -lineStep - lineHeight,
          opacity: 0,
          duration: EXIT_DURATION,
          ease: 'power2.in',
        },
        0
      )

      // t1 (recente) sobe para a posição de t2 e perde a prominent
      tl.to(
        t1,
        {
          opacity: 0.35,
          scale: 1,
          duration: EXIT_DURATION,
          ease: 'power2.inOut',
          onStart() {
            t1.classList.remove('hero-ticker-text--prominent')
          },
        },
        0
      )

      // b1 (próximo) sobe para a posição do card e perde a prominent
      tl.to(
        b1,
        {
          opacity: 0.35,
          scale: 1,
          duration: EXIT_DURATION,
          ease: 'power2.inOut',
          onStart() {
            b1.classList.remove('hero-ticker-text--prominent')
          },
        },
        0
      )

      // b2 (a seguir) sobe para a posição de t1 e ganha prominent
      tl.to(
        b2,
        {
          opacity: 0.7,
          scale: 1.28,
          duration: EXIT_DURATION,
          ease: 'power2.inOut',
          onStart() {
            b2.classList.add('hero-ticker-text--prominent')
          },
        },
        0
      )

      // --- SWAP: a meio do exit, reposiciona e actualiza DOM ---
      tl.add(() => {
        currentIndex = (currentIndex + 1) % total
        // Reposiciona todos os elementos na sua posição original
        gsap.set([t2, t1, cardText, cardIcon, b1, b2], {
          y: 0,
          scale: 1,
          opacity: 0,
        })
        // Actualiza o conteúdo de cada slot
        render()
        // Reaplica as opacidades correctas (render() também mexe nas classes
        // prominent, mas o opacity inline ficou a 0 acima; restauramos aqui)
        gsap.set(t2, { opacity: 0.35 })
        gsap.set(t1, { opacity: 0.7, scale: 1.28 })
        gsap.set(b1, { opacity: 0.7, scale: 1.28 })
        gsap.set(b2, { opacity: 0.35 })
        // O card precisa de ficar a 0 para fazer fade-in a seguir
        gsap.set([cardText, cardIcon], { opacity: 0 })
      })

      // --- SLIDE-IN: card novo aparece com fade-in ---
      tl.to(
        [cardText, cardIcon],
        { opacity: 1, duration: SLIDE_IN_DURATION, ease: 'power2.out' }
      )

      // --- HOLD: card fica parado e visível ---
      if (HOLD_DURATION > 0) {
        tl.to({}, { duration: HOLD_DURATION })
      }
    }

    buildIteration()

    // P3: a animação só corre quando o hero está visível. O IntersectionObserver
    // arranca a timeline na primeira vez que o hero entra no ecrã e pausa sempre
    // que sai — o loop infinito deixa de ocupar a main thread durante o scroll.
    let hasStarted = false
    let isInView = false

    const io = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          isInView = entry.isIntersecting
          if (isInView) {
            if (!hasStarted) {
              hasStarted = true
              tl.play(0)
            } else if (!document.hidden) {
              tl.resume()
            }
          } else {
            tl.pause()
          }
        }
      },
      { threshold: 0 }
    )
    io.observe(rootEl)

    const onRepeat = () => {
      tl.clear()
      buildIteration()
      tl.play(0)
    }
    tl.eventCallback('onRepeat', onRepeat)

    const onVis = () => {
      if (document.hidden) tl.pause()
      else if (isInView) tl.resume()
    }
    document.addEventListener('visibilitychange', onVis)

    return () => {
      tl.kill()
      tl.eventCallback('onRepeat', null)
      io.disconnect()
      document.removeEventListener('visibilitychange', onVis)
    }
  }, [t])

  return (
    <div ref={rootRef} className="hero-animated" aria-label="Serviços principais">
      <div className="hero-ticker-top" aria-hidden="true">
        <span ref={t2Ref} className="hero-ticker-text"></span>
        <span ref={t1Ref} className="hero-ticker-text hero-ticker-text--prominent"></span>
      </div>
      <div className="hero-animated-card">
        <img
          ref={cardIconRef}
          src={PHRASES[0].icon}
          alt=""
          className="hero-animated-icon"
          aria-hidden="true"
        />
        <span ref={cardTextRef} className="hero-animated-text">
          {t(PHRASES[0].key)}
        </span>
      </div>
      <div className="hero-ticker-bottom" aria-hidden="true">
        <span ref={b1Ref} className="hero-ticker-text hero-ticker-text--prominent"></span>
        <span ref={b2Ref} className="hero-ticker-text"></span>
      </div>
    </div>
  )
}
