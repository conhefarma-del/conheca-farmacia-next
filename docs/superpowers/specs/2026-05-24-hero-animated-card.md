# Spec: Hero Animated Card — Ticker Vertical

## Contexto

Substituir os 5 cards estáticos da hero section por **1 card animado** com texto a ciclar num efeito de ticker vertical. O texto entra por baixo, destaca-se dentro do card, e sai por cima — criando um fluxo contínuo que mostra os 5 serviços principais da farmácia.

**Motivação:** Os 5 cards estáticos ocupam muito espaço e são estáticos. Um único card animado é mais impactante, informativo e dinâmico.

**Ficheiros envolvidos:**
- `index.html` (linhas 168-193) — secção hero-cards
- `src/input.css` — estilos hero-cards (a remover) + novos estilos hero-animated
- `src/hero-animated.js` — novo ficheiro, lógica de animação

---

## Comportamento

### Ciclo de animação (2.5s por frase)

1. **Entrada:** Texto desliza de baixo para cima até ao centro do card
2. **Destaque:** Texto permanece visível no card durante 2s
3. **Saída:** Texto desliza para cima e sai do card
4. **Fluxo nos tickers:**
   - Ticker bottom: Linha 2 → Linha 1 (ganha destaque); Linha 1 desliza para cima e desaparece
   - Ticker top: Linha 1 → Linha 2 (perde destaque); Linha 2 desliza para cima e desaparece
5. **Repetição:** Próxima frase entra por baixo no card

### Frases e ícones

| # | Frase | Ícone |
|---|---|---|
| 1 | Atenção Farmacêutica | `Asset 1-branco.svg` (cruz) |
| 2 | Eventos Especializados | `Asset 7-branco.svg` (calendário) |
| 3 | Conteúdo de Qualidade | `Asset 11-branco.svg` (pessoas) |
| 4 | Artigos Científicos | `Asset 15-branco.svg` (documento) |
| 5 | Lives & Webinars | `Asset 20-branco.svg` (play) |

### Ticker vertical (textos fora do card)

**Abaixo do card** (próximas frases a entrar):
- Linha 1 (junto ao card): próxima frase — **mais destaque** (0.9rem, weight 600, opacity 0.7)
- Linha 2: frase seguinte — **menos destaque** (0.7rem, weight 400, opacity 0.35)

**Acima do card** (frases que já saíram):
- Linha 1 (junto ao card): frase que acabou de sair — **mais destaque** (0.9rem, weight 600, opacity 0.7)
- Linha 2: penúltima a sair — **menos destaque** (0.7rem, weight 400, opacity 0.35)

**Distância:** Ticker top e bottom com a mesma distância ao card (margin 14px).

### Animação dos tickers — Fluxo contínuo entre posições

Em vez de textos aparecerem/desaparecerem, os textos **fluem** entre posições — movendo-se de uma linha para outra enquanto a linha de destino desliza para cima e desaparece.

**Abaixo do card (ticker bottom):**
- Linha 2 (sem destaque) → move-se para a posição da Linha 1 (ganha destaque)
- Linha 1 (com destaque) → desliza para cima e desaparece
- Ambas as animações acontecem **em simultâneo**
- A Linha 2 é preenchida com a nova frase seguinte

**Acima do card (ticker top):**
- Linha 1 (junto ao card, com destaque) → move-se para a posição da Linha 2 (perde destaque)
- Linha 2 → desliza para cima e desaparece
- A nova frase que saiu do card entra na Linha 1

**Transições:**
- Movimento entre posições: `transform 0.4s ease` (translateY)
- Opacidade: fade out do texto que sai (0.4s ease)
- Entrada de nova frase: fade in + slide (translateY 10px → 0, opacity 0 → valor final)

---

## Layout

### Desktop (≥1024px)
- Grid 2 colunas: hero-content (esquerda) + hero-animated (direita)
- Card animado no lado direito

### Tablet (768-1023px)
- Mantido 2 colunas

### Mobile (<768px)
- 1 coluna: título em cima, card animado em baixo
- Card full-width, texto menor

---

## Visual

### Card
- Background: `linear-gradient(135deg, #00493a, #006171)`
- Border-radius: 1.25rem (20px)
- Padding: 40px 48px
- Min-height: 130px
- Box-shadow: `0 8px 32px rgba(0,42,50,0.18)`
- Layout: flex-row (ícone à esquerda, texto à direita)

### Ícone
- Container: 60x60px, fundo `rgba(255,255,255,0.15)`, border-radius 14px
- Ícone SVG: 34x34px, stroke branco

### Texto dentro do card
- Font-size: 1.75rem
- Font-weight: 700
- Color: #ffffff
- Letter-spacing: 0.02em
- Text-transform: uppercase

### Textos ticker (fora do card)
- Mais destaque: 0.9rem, weight 600, color #777, opacity 0.7
- Menos destaque: 0.7rem, weight 400, color #777, opacity 0.35
- Text-transform: uppercase
- Letter-spacing: 0.08em

### Dark mode
- Card mantém gradiente (não muda)
- Textos ticker: usar `var(--color-brand-deep)` em vez de #777

---

## JavaScript (`src/hero-animated.js`)

### Estrutura
```javascript
// Array de frases com ícones
const HERO_PHRASES = [
  { text: 'Atenção Farmacêutica', icon: '/assets/icons/Asset 1-branco.svg' },
  { text: 'Eventos Especializados', icon: '/assets/icons/Asset 7-branco.svg' },
  { text: 'Conteúdo de Qualidade', icon: '/assets/icons/Asset 11-branco.svg' },
  { text: 'Artigos Científicos', icon: '/assets/icons/Asset 15-branco.svg' },
  { text: 'Lives & Webinars', icon: '/assets/icons/Asset 20-branco.svg' }
];
```

### Estado
- `currentIndex` — frase atual visível no card
- `exitHistory[]` — últimas 2 frases que saíram (mais recente primeiro)
- `intervalId` — referência ao setInterval

### Funções
- `initHeroAnimated()` — inicializa filas, arranca ciclo
- `cycle()` — executa um ciclo de transição com fluxo contínuo:
  1. Ticker bottom: Linha 2 move-se para Linha 1 (ganha destaque); Linha 1 desliza para cima e desaparece (em simultâneo)
  2. Ticker top: Linha 1 move-se para Linha 2 (perde destaque); Linha 2 desliza para cima e desaparece
  3. Card: texto atual desliza para cima e sai; novo texto entra por baixo
  4. Após animação (500ms): atualizar conteúdo dos tickers com novas frases
- `renderTickerTop()` — atualiza textos acima do card
- `renderTickerBottom()` — atualiza textos abaixo do card

### Acessibilidade
- `role="status"` + `aria-live="polite"` no card para anunciar mudanças
- Ticker top/bottom com `aria-hidden="true"` (decorativo)
- `prefers-reduced-motion: reduce` → desativar animação, mostrar texto estático

---

## Remoção do código anterior

### CSS a remover (src/input.css)
- `.hero-cards` grid rules (linhas 148-177)
- `.hero-card` base styles (linhas 179-243)
- `.hero-card--wide`, `.hero-card--centered` modifiers
- `.hero-card-icon`, `.hero-card-body`, `.hero-card-title`, `.hero-card-desc`
- `@keyframes heroCardFadeIn`
- Dark mode `.hero-card` rules
- `prefers-reduced-motion` rules for hero cards

### HTML a remover (index.html)
- `<div class="hero-cards">` com os 5 cards (linhas 168-193)

### HTML a adicionar
- `<div class="hero-animated">` com ticker-top, card, ticker-bottom

---

## Verificação

1. **Build:** `npm run build` sem erros
2. **Visual desktop:** Card animado no lado direito, texto a ciclar
3. **Visual mobile:** Card full-width abaixo do título
4. **Animação — Fluxo contínuo:**
   - Ticker bottom: texto da Linha 2 move-se para Linha 1 (ganha destaque) enquanto Linha 1 desliza para cima e desaparece (em simultâneo)
   - Ticker top: texto da Linha 1 move-se para Linha 2 (perde destaque) enquanto Linha 2 desliza para cima e desaparece
   - Card: texto sai por cima, novo entra por baixo
5. **Dark mode:** Textos ticker adaptados
6. **Acessibilidade:** `prefers-reduced-motion` desativa animação
7. **Ícones:** 5 ícones carregam sem 404
