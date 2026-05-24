const HERO_PHRASES = [
  { text: 'Atenção Farmacêutica', icon: '/assets/icons/Asset 1-branco.svg' },
  { text: 'Eventos Especializados', icon: '/assets/icons/Asset 7-branco.svg' },
  { text: 'Conteúdo de Qualidade', icon: '/assets/icons/Asset 11-branco.svg' },
  { text: 'Artigos Científicos', icon: '/assets/icons/Asset 15-branco.svg' },
  { text: 'Lives & Webinars', icon: '/assets/icons/Asset 20-branco.svg' }
];

const CYCLE_INTERVAL = 2500;
const ANIMATION_DURATION = 300;

let currentIndex = 0;
let exitHistory = [];
let intervalId = null;

function initHeroAnimated() {
  const container = document.querySelector('.hero-animated');
  if (!container) return;

  // Create initial ticker bottom elements (2 lines)
  const tickerBottom = document.querySelector('.hero-ticker-bottom');
  if (tickerBottom) {
    for (let i = 1; i <= 2; i++) {
      const el = document.createElement('span');
      el.className = 'hero-ticker-text' + (i === 1 ? ' hero-ticker-text--prominent' : '');
      tickerBottom.appendChild(el);
    }
  }

  // Set initial content
  renderTickerBottom();
  startCycle();
}

function startCycle() {
  if (intervalId) return;
  intervalId = setInterval(cycle, CYCLE_INTERVAL);
}

function stopCycle() {
  if (intervalId) {
    clearInterval(intervalId);
    intervalId = null;
  }
}

function cycle() {
  const cardText = document.querySelector('.hero-animated-text');
  const cardIcon = document.querySelector('.hero-animated-icon');
  if (!cardText || !cardIcon) return;

  const tickerBottom = document.querySelector('.hero-ticker-bottom');
  const tickerTop = document.querySelector('.hero-ticker-top');

  // --- BATCH ALL READS (before any writes) ---
  let bottomDistance = 0;
  let topDistance = 0;
  let topLine2Height = 0;

  const bottomLines = tickerBottom ? tickerBottom.querySelectorAll('.hero-ticker-text') : [];
  if (bottomLines.length >= 2) {
    const rect1 = bottomLines[0].getBoundingClientRect();
    const rect2 = bottomLines[1].getBoundingClientRect();
    bottomDistance = rect2.top - rect1.top;
  }

  const topLines = tickerTop ? tickerTop.querySelectorAll('.hero-ticker-text') : [];
  if (topLines.length >= 2) {
    const line1 = topLines[topLines.length - 1]; // prominent (closest to card)
    const line2 = topLines[0]; // not prominent (farther from card)
    const rect1 = line1.getBoundingClientRect();
    const rect2 = line2.getBoundingClientRect();
    topDistance = rect2.top - rect1.top;
    topLine2Height = rect2.height;
  }

  // --- BATCH ALL WRITES ---

  // 1. Ticker bottom: Line 2 moves to Line 1, Line 1 slides up and disappears
  if (bottomLines.length >= 2) {
    const line1 = bottomLines[0]; // prominent (closest to card)
    const line2 = bottomLines[1]; // not prominent

    line1.style.transition = 'transform 0.4s ease, opacity 0.4s ease';
    line1.style.transform = `translateY(-${bottomDistance}px)`;
    line1.style.opacity = '0';

    line2.style.transition = 'transform 0.4s ease, opacity 0.4s ease';
    line2.style.transform = `translateY(-${bottomDistance}px)`;
    line2.classList.add('hero-ticker-text--prominent');
  }

  // 2. Ticker top: Line 1 moves to Line 2, Line 2 slides up and disappears
  if (topLines.length >= 2) {
    const line1 = topLines[topLines.length - 1]; // prominent (closest to card)
    const line2 = topLines[0]; // not prominent (farther from card)

    line2.style.transition = 'transform 0.4s ease, opacity 0.4s ease';
    line2.style.transform = `translateY(-${topLine2Height + 10}px)`;
    line2.style.opacity = '0';

    line1.style.transition = 'transform 0.4s ease, opacity 0.4s ease';
    line1.style.transform = `translateY(${topDistance}px)`;
    line1.classList.remove('hero-ticker-text--prominent');
  }

  // 3. Slide card text + icon UP and out (together)
  cardText.style.transition = 'transform 0.3s ease, opacity 0.3s ease';
  cardText.style.transform = 'translateY(-120%)';
  cardText.style.opacity = '0';

  cardIcon.style.transition = 'transform 0.3s ease, opacity 0.3s ease';
  cardIcon.style.transform = 'translateY(-120%)';
  cardIcon.style.opacity = '0';

  setTimeout(() => {
    // 4. Add exited phrase to history
    exitHistory.unshift(HERO_PHRASES[currentIndex]);
    if (exitHistory.length > 2) exitHistory.pop();

    // 5. Update ticker top
    renderTickerTop();

    // 6. Move to next phrase
    currentIndex = (currentIndex + 1) % HERO_PHRASES.length;

    // 7. Update card content
    cardText.textContent = HERO_PHRASES[currentIndex].text;
    cardIcon.src = HERO_PHRASES[currentIndex].icon;

    // 8. Slide card text + icon IN from bottom (using rAF double instead of offsetHeight)
    cardText.style.transition = 'none';
    cardText.style.transform = 'translateY(120%)';
    cardText.style.opacity = '0';

    cardIcon.style.transition = 'none';
    cardIcon.style.transform = 'translateY(120%)';
    cardIcon.style.opacity = '0';

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        cardText.style.transition = 'transform 0.35s cubic-bezier(0.4,0,0.2,1), opacity 0.35s ease';
        cardText.style.transform = 'translateY(0)';
        cardText.style.opacity = '1';

        cardIcon.style.transition = 'transform 0.35s cubic-bezier(0.4,0,0.2,1), opacity 0.35s ease';
        cardIcon.style.transform = 'translateY(0)';
        cardIcon.style.opacity = '1';
      });
    });

    // 9. Update ticker bottom
    renderTickerBottom();
  }, ANIMATION_DURATION);
}

function renderTickerTop() {
  const tickerTop = document.querySelector('.hero-ticker-top');
  if (!tickerTop) return;

  const reversed = [...exitHistory].reverse();
  let lines = tickerTop.querySelectorAll('.hero-ticker-text');

  // Add or remove elements to match exitHistory length
  while (lines.length < reversed.length) {
    const el = document.createElement('span');
    el.className = 'hero-ticker-text';
    tickerTop.appendChild(el);
    lines = tickerTop.querySelectorAll('.hero-ticker-text');
  }
  while (lines.length > reversed.length) {
    lines[lines.length - 1].remove();
    lines = tickerTop.querySelectorAll('.hero-ticker-text');
  }

  // Update elements in place (no innerHTML clear = no layout shift)
  reversed.forEach((phrase, i) => {
    const isRecent = i === reversed.length - 1;
    lines[i].textContent = phrase.text;
    lines[i].className = 'hero-ticker-text' + (isRecent ? ' hero-ticker-text--prominent' : '');
    // Reset animation styles (transition: none first to prevent flash)
    lines[i].style.transition = 'none';
    lines[i].style.transform = '';
    lines[i].style.opacity = '';
  });
}

function renderTickerBottom() {
  const tickerBottom = document.querySelector('.hero-ticker-bottom');
  if (!tickerBottom) return;

  const lines = tickerBottom.querySelectorAll('.hero-ticker-text');
  if (lines.length < 2) return;

  // Update Line 1 (next phrase, prominent)
  const idx1 = (currentIndex + 1) % HERO_PHRASES.length;
  lines[0].textContent = HERO_PHRASES[idx1].text;
  lines[0].className = 'hero-ticker-text hero-ticker-text--prominent';
  // Reset animation styles (transition: none first to prevent flash)
  lines[0].style.transition = 'none';
  lines[0].style.transform = '';
  lines[0].style.opacity = '';

  // Update Line 2 (phrase after next, not prominent)
  const idx2 = (currentIndex + 2) % HERO_PHRASES.length;
  lines[1].textContent = HERO_PHRASES[idx2].text;
  lines[1].className = 'hero-ticker-text';
  // Reset animation styles
  lines[1].style.transition = 'none';
  lines[1].style.transform = '';
  lines[1].style.opacity = '';
}

// Respect reduced motion preference
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
if (prefersReducedMotion.matches) {
  document.addEventListener('DOMContentLoaded', () => {
    const cardText = document.querySelector('.hero-animated-text');
    if (cardText) cardText.textContent = HERO_PHRASES[0].text;
  });
} else {
  document.addEventListener('DOMContentLoaded', initHeroAnimated);
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) stopCycle();
    else startCycle();
  });
}

export { HERO_PHRASES };
