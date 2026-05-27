# Hero Animated Card — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Substituir os 5 cards estáticos da hero por 1 card animado com ticker vertical de texto.

**Architecture:** Um único card com gradiente verde no lado direito da hero. JavaScript gere o ciclo de 5 frases com ícones — texto entra por baixo, destaca-se no card, sai por cima. CSS transitions para todas as animações.

**Tech Stack:** Vanilla JavaScript (ES modules), CSS transitions, Tailwind CSS v4 (`@layer components`)

**Spec:** `docs/superpowers/specs/2026-05-24-hero-animated-card.md`

---

## Ficheiros envolvidos

| Ficheiro | Ação | Responsabilidade |
|---|---|---|
| `src/hero-animated.js` | **Criar** | Lógica de animação: ciclo de frases, tickers, ícones |
| `index.html:168-193` | **Modificar** | Substituir hero-cards por hero-animated |
| `src/input.css:148-263` | **Modificar** | Remover hero-card CSS, adicionar hero-animated CSS |
| `src/input.css:1217-1228` | **Modificar** | Remover dark mode hero-card, adicionar hero-animated |

---

### Task 1: Criar `src/hero-animated.js`

**Ficheiro:** `src/hero-animated.js` (novo)

- [ ] **Step 1: Criar o módulo com dados e funções**

```javascript
const HERO_PHRASES = [
  { text: 'Atenção Farmacêutica', icon: '/assets/icons/Asset 1-branco.svg' },
  { text: 'Eventos Especializados', icon: '/assets/icons/Asset 7-branco.svg' },
  { text: 'Conteúdo de Qualidade', icon: '/assets/icons/Asset 11-branco.svg' },
  { text: 'Artigos Científicos', icon: '/assets/icons/Asset 15-branco.svg' },
  { text: 'Lives & Webinars', icon: '/assets/icons/Asset 20-branco.svg' }
];

const CYCLE_INTERVAL = 2500;
const ANIMATION_DURATION = 500;

let currentIndex = 0;
let exitHistory = [];
let intervalId = null;

function initHeroAnimated() {
  const container = document.querySelector('.hero-animated');
  if (!container) return;

  renderTickerBottom();
  startCycle();
}

function startCycle() {
  intervalId = setInterval(cycle, CYCLE_INTERVAL);
}

function cycle() {
  const cardText = document.querySelector('.hero-animated-text');
  const cardIcon = document.querySelector('.hero-animated-icon');
  if (!cardText || !cardIcon) return;

  // 1. Slide current text UP and out
  cardText.style.transform = 'translateY(-120%)';
  cardText.style.opacity = '0';

  setTimeout(() => {
    // 2. Add exited phrase to history (most recent first)
    exitHistory.unshift(HERO_PHRASES[currentIndex]);
    if (exitHistory.length > 2) exitHistory.pop();

    // 3. Update ticker top
    renderTickerTop();

    // 4. Move to next phrase
    currentIndex = (currentIndex + 1) % HERO_PHRASES.length;

    // 5. Update card content
    cardText.textContent = HERO_PHRASES[currentIndex].text;
    cardIcon.src = HERO_PHRASES[currentIndex].icon;

    // 6. Slide new text IN from bottom
    cardText.style.transition = 'none';
    cardText.style.transform = 'translateY(120%)';
    cardText.style.opacity = '0';

    requestAnimationFrame(() => {
      cardText.style.transition = 'transform 0.5s cubic-bezier(0.4,0,0.2,1), opacity 0.5s ease';
      cardText.style.transform = 'translateY(0)';
      cardText.style.opacity = '1';
    });

    // 7. Update ticker bottom
    renderTickerBottom();
  }, ANIMATION_DURATION);
}

function renderTickerTop() {
  const tickerTop = document.querySelector('.hero-ticker-top');
  if (!tickerTop) return;

  tickerTop.innerHTML = '';
  // Render reversed so most recent is at bottom (closest to card)
  const reversed = [...exitHistory].reverse();
  reversed.forEach((phrase, i) => {
    const el = document.createElement('span');
    el.textContent = phrase.text;
    const isRecent = i === reversed.length - 1;
    el.className = 'hero-ticker-text' + (isRecent ? ' hero-ticker-text--prominent' : '');
    el.style.cssText = 'opacity:0;transform:translateY(10px);transition:all 0.4s ease;';
    tickerTop.appendChild(el);
    requestAnimationFrame(() => {
      el.style.opacity = '';
      el.style.transform = '';
    });
  });
}

function renderTickerBottom() {
  const tickerBottom = document.querySelector('.hero-ticker-bottom');
  if (!tickerBottom) return;

  tickerBottom.innerHTML = '';
  for (let i = 1; i <= 2; i++) {
    const idx = (currentIndex + i) % HERO_PHRASES.length;
    const el = document.createElement('span');
    el.textContent = HERO_PHRASES[idx].text;
    const isNext = i === 1;
    el.className = 'hero-ticker-text' + (isNext ? ' hero-ticker-text--prominent' : '');
    tickerBottom.appendChild(el);
  }
}

// Respect reduced motion preference
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
if (prefersReducedMotion.matches) {
  // Show static text, no animation
  document.addEventListener('DOMContentLoaded', () => {
    const cardText = document.querySelector('.hero-animated-text');
    if (cardText) cardText.textContent = HERO_PHRASES[0].text;
  });
} else {
  document.addEventListener('DOMContentLoaded', initHeroAnimated);
}

export { HERO_PHRASES };
```

- [ ] **Step 2: Validar sintaxe**

```bash
node --check src/hero-animated.js
```

Esperado: sem erros (saída vazia).

---

### Task 2: Atualizar HTML — substituir hero-cards por hero-animated

**Ficheiro:** `index.html:168-193`

- [ ] **Step 1: Substituir o bloco hero-cards**

Substituir:
```html
      <!-- Right Column: Info Cards -->
      <div class="hero-cards" role="list" aria-label="Serviços principais">
        <div class="hero-card hero-card--wide" role="listitem" tabindex="0">
          <img src="/assets/icons/Asset 1-branco.svg" alt="" class="hero-card-icon" aria-hidden="true">
          <div class="hero-card-body">
            <h3 class="hero-card-title">Atenção Farmacêutica</h3>
            <p class="hero-card-desc">Acompanhamento personalizado e orientação profissional para o seu tratamento.</p>
          </div>
        </div>
        <div class="hero-card" role="listitem" tabindex="0">
          <img src="/assets/icons/Asset 7-branco.svg" alt="" class="hero-card-icon" aria-hidden="true">
          <h3 class="hero-card-title">Eventos Especializados</h3>
        </div>
        <div class="hero-card" role="listitem" tabindex="0">
          <img src="/assets/icons/Asset 11-branco.svg" alt="" class="hero-card-icon" aria-hidden="true">
          <h3 class="hero-card-title">Conteúdo de Qualidade</h3>
        </div>
        <div class="hero-card" role="listitem" tabindex="0">
          <img src="/assets/icons/Asset 15-branco.svg" alt="" class="hero-card-icon" aria-hidden="true">
          <h3 class="hero-card-title">Artigos Científicos</h3>
        </div>
        <div class="hero-card hero-card--centered" role="listitem" tabindex="0">
          <img src="/assets/icons/Asset 20-branco.svg" alt="" class="hero-card-icon" aria-hidden="true">
          <h3 class="hero-card-title">Lives & Webinars</h3>
        </div>
      </div>
```

Por:
```html
      <!-- Right Column: Animated Card -->
      <div class="hero-animated">
        <div class="hero-ticker-top" aria-hidden="true"></div>
        <div class="hero-animated-card" role="status" aria-live="polite">
          <img class="hero-animated-icon" src="/assets/icons/Asset 1-branco.svg" alt="" aria-hidden="true">
          <span class="hero-animated-text">Atenção Farmacêutica</span>
        </div>
        <div class="hero-ticker-bottom" aria-hidden="true"></div>
      </div>
```

- [ ] **Step 2: Adicionar script module no final do body**

Após a linha `<script type="module" src="/src/home-events-logic.js"></script>`, adicionar:

```html
<script type="module" src="/src/hero-animated.js"></script>
```

---

### Task 3: Remover CSS dos hero-cards antigos

**Ficheiro:** `src/input.css`

- [ ] **Step 1: Remover bloco hero-cards grid (linhas 148-177)**

Remover desde `/* Hero Cards Grid */` até ao fecho do `@media (min-width: 1024px)`.

- [ ] **Step 2: Remover bloco hero-card base styles (linhas 179-263)**

Remover desde `/* Hero Card Base */` até ao fecho do `prefers-reduced-motion`.

- [ ] **Step 3: Remover dark mode hero-card (linhas 1217-1228)**

Remover:
```css
  /* Dark mode hero cards */
  html.dark .hero-card {
    background-color: var(--color-brand-primary);
    box-shadow: 0 4px 20px rgba(0, 92, 74, 0.15);
  }

  html.dark .hero-card:hover {
    box-shadow: 0 10px 30px rgba(0, 92, 74, 0.2);
  }

  html.dark .hero-card:focus-visible {
    outline-color: var(--color-brand-accent);
  }
```

---

### Task 4: Adicionar CSS hero-animated

**Ficheiro:** `src/input.css` (após `.hero-actions`, linha ~146)

- [ ] **Step 1: Adicionar estilos do card animado e tickers**

```css
  /* Hero Animated Card */
  .hero-animated {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0;
  }

  .hero-animated-card {
    background: linear-gradient(135deg, #00493a, #006171);
    color: #ffffff;
    border-radius: 1.25rem;
    padding: 2.5rem 3rem;
    display: flex;
    align-items: center;
    gap: 1.75rem;
    width: 100%;
    min-height: 130px;
    position: relative;
    overflow: hidden;
    box-shadow: 0 8px 32px rgba(0, 42, 50, 0.18);
  }

  .hero-animated-icon {
    width: 3.5rem;
    height: 3.5rem;
    object-fit: contain;
    flex-shrink: 0;
    padding: 0.5rem;
    background: rgba(255, 255, 255, 0.15);
    border-radius: 0.875rem;
  }

  .hero-animated-text {
    font-size: 1.75rem;
    font-weight: 700;
    letter-spacing: 0.02em;
    text-transform: uppercase;
    white-space: nowrap;
    transition: transform 0.5s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.5s ease;
  }

  /* Ticker texts */
  .hero-ticker-top,
  .hero-ticker-bottom {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 3px;
    margin: 14px 0;
    min-height: 40px;
  }

  .hero-ticker-text {
    font-size: 0.7rem;
    font-weight: 400;
    color: #777;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    opacity: 0.35;
    transition: all 0.4s ease;
  }

  .hero-ticker-text--prominent {
    font-size: 0.9rem;
    font-weight: 600;
    opacity: 0.7;
  }

  /* Mobile adjustments */
  @media (max-width: 767px) {
    .hero-animated-card {
      padding: 1.5rem 2rem;
      min-height: 100px;
      gap: 1rem;
    }

    .hero-animated-icon {
      width: 2.5rem;
      height: 2.5rem;
      padding: 0.375rem;
    }

    .hero-animated-text {
      font-size: 1.1rem;
    }

    .hero-ticker-text {
      font-size: 0.6rem;
    }

    .hero-ticker-text--prominent {
      font-size: 0.75rem;
    }
  }
```

---

### Task 5: Adicionar dark mode para hero-animated

**Ficheiro:** `src/input.css` (na secção de dark mode, após a remoção da Task 3)

- [ ] **Step 1: Adicionar regras dark mode**

```css
  /* Dark mode hero animated */
  html.dark .hero-animated-text {
    color: #ffffff;
  }

  html.dark .hero-ticker-text {
    color: var(--color-brand-deep);
  }
```

---

### Task 6: Validação

- [ ] **Step 1: Validar sintaxe JS**

```bash
node --check src/hero-animated.js
```

Esperado: sem erros.

- [ ] **Step 2: Build**

```bash
npm run build
```

Esperado: compila sem erros.

- [ ] **Step 3: Verificar CSS limpo**

```bash
grep -c "hero-card" src/input.css
```

Esperado: 0 ocorrências (todo o CSS hero-card foi removido).

- [ ] **Step 4: Verificar HTML**

```bash
grep -c "hero-animated" index.html
```

Esperado: ≥1 ocorrência (novo card animado presente).

- [ ] **Step 5: Verificar ícones**

```bash
ls public/assets/icons/Asset\ {1,7,11,15,20}-branco.svg
```

Esperado: 5 ficheiros existem.
