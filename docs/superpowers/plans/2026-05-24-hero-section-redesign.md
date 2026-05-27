# Plano: Hero Section Redesign — Melhorado

## Contexto
O plano original (`bubbly-hopping-bumblebee.md`) substitui a imagem do farmacêutico + card flutuante por 5 cards informativos em grid assimétrico. Após análise do código atual, identifiquei **13 melhorias** críticas que o plano original não contempla: dark mode ausente, cores hardcoded, CSS órfão, breakpoint abrupto, falta de acessibilidade e interação, caminhos de ícones errados, e ambiguidade no layout.

**Ficheiros envolvidos:**
- `index.html` (linhas 156-189) — estrutura Hero
- `src/input.css` (linhas 120-165 + 1119-1129) — CSS Hero + dark mode
- `public/content/articles/095bf382-00ca-4f62-979c-654e3720017a.png` — imagem a remover

---

## Task 1: Limpeza de CSS órfão

**Ficheiro:** `src/input.css`

### Regras a remover em `@layer components` (linhas 143-165):
- `.hero-visual` (linha 143)
- `.image-wrapper` (linha 147)
- `.hero-image` (linha 151)
- `.floating-card` (linha 155)
- `.card-item` (linha 159)
- `.checkmark` (linha 163)

### Regras dark mode a remover (linhas 1119-1129):
- Comentário `/* Dark mode floating card */` (linha 1119)
- `html.dark .floating-card` (linha 1120)
- `html.dark .card-item` (linha 1124)
- `html.dark .checkmark` (linha 1127)

### Regra órfã a decidir:
- `.hero-title .highlight` (linha 135): não existe no HTML atual. **Manter** — pode ser útil para destacar parte do título no futuro. Não incomoda.

---

## Task 2: Atualizar HTML da Hero

**Ficheiro:** `index.html` (linhas 156-189)

Substituir o conteúdo de `<section id="inicio">` por:

```html
<section id="inicio" class="hero">
  <div class="hero-container">
    <div class="hero-content">
      <h1 class="hero-title">Excelência no Cuidado Farmacêutico</h1>
      <p class="hero-subtitle">Acompanhamento clínico especializado para garantir a eficácia e segurança do tratamento. Valorizando a saúde através do conhecimento farmacêutico.</p>
      <div class="hero-actions">
        <a href="https://wa.me/244925696002?text=Olá,%20Conheça%20Farmácia" target="_blank" rel="noopener noreferrer" class="btn btn-primary">Fale Connosco</a>
      </div>
    </div>
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
  </div>
</section>
```

**Melhorias face ao plano original:**
| Questão | Plano original | Plano melhorado |
|---|---|---|
| Caminho ícones | `/public/assets/icons/...` (404) | `/assets/icons/...` (correto) |
| Acessibilidade | Nenhuma | `role="list/listitem"`, `aria-hidden`, `aria-label`, `tabindex` |
| Card 1 largo | Apenas `grid-column: span 2` | Modificador `--wide` com descrição extra |
| Texto h1 | Tinha `flex justify-center` inline | Alinhamento via CSS (desktop left, mobile center) |

---

## Task 3: CSS — Grid e layout dos cards

**Ficheiro:** `src/input.css` (após regras removidas na Task 1)

### 3.1 Ajustar hero-content (alinhamento)
```css
.hero-content {
  @apply text-center lg:text-left;
}
```

### 3.2 Grid com 3 breakpoints (mobile → tablet → desktop)
```css
.hero-cards {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}

/* Tablet: 2 colunas */
@media (min-width: 768px) {
  .hero-cards {
    grid-template-columns: repeat(2, 1fr);
  }
  .hero-card--wide {
    grid-column: span 2;
  }
  .hero-card--centered {
    grid-column: span 2;
  }
}

/* Desktop: 3 colunas assimétrico */
@media (min-width: 1024px) {
  .hero-cards {
    grid-template-columns: repeat(3, 1fr);
  }
  .hero-card--wide {
    grid-column: 1 / -1;
  }
  .hero-card--centered {
    grid-column: 2;
  }
}
```

**Layout resultante:**
- **Desktop (≥1024px):** Card 1 largo (3 col), Cards 2-4 (1 col cada), Card 5 centralizado
- **Tablet (768-1023px):** Card 1 largo (2 col), Cards 2+3, Cards 4+5 (ambos span 2)
- **Mobile (<768px):** 1 coluna, todos empilhados

### 3.3 Estilo base dos cards
```css
.hero-card {
  background-color: var(--color-brand-primary);
  color: #ffffff;
  border-radius: 1rem;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 0.75rem;
  box-shadow: var(--shadow-soft);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.hero-card--wide {
  flex-direction: row;
  text-align: left;
  gap: 1.25rem;
}

.hero-card-icon {
  width: 2.5rem;
  height: 2.5rem;
  object-fit: contain;
  flex-shrink: 0;
}

.hero-card-title {
  font-weight: 700;
  font-size: 1rem;
  line-height: 1.4;
}

.hero-card-desc {
  font-size: 0.875rem;
  line-height: 1.5;
  opacity: 0.9;
}

/* Card largo volta a vertical em mobile */
@media (max-width: 767px) {
  .hero-card--wide {
    flex-direction: column;
    text-align: center;
    align-items: center;
  }
}
```

**Melhorias face ao original:**
| Questão | Plano original | Plano melhorado |
|---|---|---|
| Cor fundo | `#00493a` hardcoded | `var(--color-brand-primary)` → dark mode automático |
| Sombra | `0 4px 12px rgba(0,73,58,0.15)` custom | `var(--shadow-soft)` consistente |
| Breakpoints | Apenas 768px (abrupto) | 3 breakpoints (768px + 1024px) |
| Layout grid | "3+2 ou 2+2+1" ambíguo | Layout explícito por breakpoint |

---

## Task 4: Estados de interação + acessibilidade

```css
.hero-card:hover {
  transform: translateY(-0.25rem);
  box-shadow: var(--shadow-md-soft);
}

.hero-card:focus-visible {
  outline: 2px solid #ffffff;
  outline-offset: 2px;
}

@media (prefers-reduced-motion: reduce) {
  .hero-card {
    transition: none;
  }
  .hero-card:hover {
    transform: none;
  }
}
```

---

## Task 5: Dark mode

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

**Nota:** Sombras com `rgba(0, 42, 50, ...)` (variáveis default) são quase invisíveis sobre fundo `#0a0f0d`. Override com tons de `#005c4a` (brand-primary dark) dá contraste.

---

## Task 6: Animação de entrada (staggered fade-in)

```css
@keyframes heroCardFadeIn {
  from { opacity: 0; transform: translateY(1rem); }
  to { opacity: 1; transform: translateY(0); }
}

.hero-card {
  animation: heroCardFadeIn 0.5s ease-out both;
}
.hero-card:nth-child(1) { animation-delay: 0.1s; }
.hero-card:nth-child(2) { animation-delay: 0.2s; }
.hero-card:nth-child(3) { animation-delay: 0.3s; }
.hero-card:nth-child(4) { animation-delay: 0.4s; }
.hero-card:nth-child(5) { animation-delay: 0.5s; }

@media (prefers-reduced-motion: reduce) {
  .hero-card { animation: none; }
}
```

---

## Task 7: Remover imagem hero antiga

**Ficheiro:** `public/content/articles/095bf382-00ca-4f62-979c-654e3720017a.png`

- Verificar que não é referenciada noutro lado (grep confirmou: só no hero)
- Mover para `public/assets/unused/` temporariamente (não apagar de imediato)

---

## Task 8: Validação

1. **Build:** `npm run build` — sem erros
2. **Visual light mode:** Grid 3 cols desktop, 2 cols tablet, 1 col mobile
3. **Visual dark mode:** Cards `#005c4a`, sombras visíveis, focus accent
4. **Interação:** Hover (elevação + sombra), Tab (focus outline), sem reduced-motion
5. **Acessibilidade:** `prefers-reduced-motion: reduce` → sem animações/hover transform; leitor de tela anuncia "Serviços principais, lista, 5 itens"
6. **CSS limpo:** Grep por `.floating-card`, `.checkmark` no CSS compilado → 0 resultados
7. **Ícones:** 5 ícones carregam sem 404 no Network tab

---

## Resumo das melhorias face ao plano original

| # | Problema | Melhoria |
|---|---|---|
| 1 | Dark mode ausente | CSS dark mode completo com sombras adaptadas |
| 2 | CSS órfão não tratado | Task explícita para remover regras órfãs |
| 3 | Sombra hardcoded | Usar `var(--shadow-soft)` / `var(--shadow-md-soft)` |
| 4 | Cor hardcoded `#00493a` | Usar `var(--color-brand-primary)` |
| 5 | Breakpoint abrupto (só 768px) | 3 breakpoints: mobile/tablet/desktop |
| 6 | Sem interação (hover/focus) | Hover lift + focus-visible + tabindex |
| 7 | Sem acessibilidade | role="list/listitem", aria-hidden, aria-label, reduced-motion |
| 8 | Sem animação de entrada | Staggered fade-in com reduced-motion |
| 9 | Caminho ícones `/public/...` | Corrigido para `/assets/...` |
| 10 | Imagem antiga não tratada | Task para mover/remover |
| 11 | Dark mode CSS órfão | Remover + adicionar novos selectors |
| 12 | Layout grid ambíguo | Layout explícito por breakpoint |
| 13 | Alinhamento texto | Desktop: left; Mobile: center |
