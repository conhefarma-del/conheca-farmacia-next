# Event Cards - Reestruturar Layout e Adicionar Dark Mode

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reestruturar o layout dos cards de evento para ter o header no topo (em vez de lateral) e aplicar estilos dark mode consistentes.

**Architecture:**

- Manter a JavaScript de renderização (home-events-logic.js, events-logic.js) mas ajustar HTML template para estrutura vertical
- Usar CSS Grid para layout do event-card (1 coluna ao invés de 2 colunas no desktop)
- Aplicar dark mode usando `html.dark .event-card` com variáveis CSS existentes

**Tech Stack:**

- Tailwind CSS v4 com variáveis CSS customizadas
- Vanilla JavaScript (módulos home-events-logic.js e events-logic.js)
- HTML templates gerados via JavaScript

---

## Files to Modify

- `src/input.css` - Adicionar estilos dark mode para event-card e reestruturar layout
- `src/events-logic.js` - Ajustar template HTML do event-card (se necessário)
- `src/home-events-logic.js` - Ajustar template HTML do event-card na home (se necessário)

---

## Task 1: Reestruturar layout do event-card para header no topo

**Files:**

- Modify: `src/input.css` (linha ~254-284)
- Modify: `src/events-logic.js:111-176` (template HTML)
- Modify: `src/home-events-logic.js:58-85` (template HTML)

- [ ] **Passo 1: Atualizar CSS para remover flex-row em desktop**

O CSS atual usa `flex md:flex-row` para colocar header na lateral. Mudar para estrutura de coluna única:

```css
/* Event Card Refatorado - Header no topo */
.event-card {
  @apply bg-white rounded-2xl overflow-hidden shadow-soft transition-all duration-300 
    hover:shadow-md-soft hover:-translate-y-2 flex flex-col h-full border border-brand-divider/10;
}

.event-card-header {
  @apply relative h-48 overflow-hidden w-full; /* w-full para ocupar toda largura */
}

.event-card-content {
  @apply p-6 flex flex-col flex-grow w-full; /* w-full para ocupar toda largura */
}
```

- [ ] **Passo 2: Atualizar template no events-logic.js**

O template já está correto (linhas 64-84), mas remover qualquer classe `md:flex-row` se existir:

```javascript
const card = document.createElement("div");
card.className = "event-card";
card.innerHTML = `
  <div class="event-card-header">
    <div class="event-card-date-box" style="background-color: ${categoryColor}">
      <div class="day">${day}</div>
      <div class="month">${month}</div>
    </div>
    <img src="${event.image}" alt="${event.title}" class="event-card-image">
  </div>
  <div class="event-card-content">
    <div class="event-date">
      ${fullDate}
    </div>
    <h3 class="event-card-title">${event.title}</h3>
    <p class="event-card-desc">${event.excerpt}</p>
    <a href="evento.html?id=${event.slug}" class="btn btn-primary btn-small w-full btn-inscrever">Mais Informações</a>
  </div>
`;
```

- [ ] **Passo 3: Atualizar template no home-events-logic.js**

Mesma alteração no home-events-logic.js (linhas 58-85):

```javascript
const card = document.createElement("div");
card.className = "event-card";
card.innerHTML = `
  <div class="event-card-header">
    <div class="event-card-date-box" style="background-color: ${categoryColor}">
      <div class="day">${day}</div>
      <div class="month">${month}</div>
    </div>
    <img src="${event.image}" alt="${event.title}" class="event-card-image">
  </div>
  <div class="event-card-content">
    <div class="event-date">
      ${fullDate}
    </div>
    <h3 class="event-card-title">${event.title}</h3>
    <p class="event-card-desc">${event.excerpt}</p>
    <a href="evento.html?id=${event.slug}" class="btn btn-primary btn-small w-full btn-inscrever">Mais Informações</a>
  </div>
`;
```

- [ ] **Passo 4: Commit**

```bash
git add src/input.css src/events-logic.js src/home-events-logic.js
git commit -m "feat: reestruturar event-card com header no topo"
```

---

## Task 2: Aplicar dark mode no event-card

**Files:**

- Modify: `src/input.css` (após linha 284, após estilos de event-card)

- [ ] **Passo 1: Adicionar regras dark mode para event-card**

Adicionar após os estilos de event-card:

```css
/* Dark mode event card */
html.dark .event-card {
  background-color: var(--color-brand-bg-alt);
  border-color: var(--color-brand-divider);
}

html.dark .event-card-title {
  color: var(--color-brand-deep);
}

html.dark .event-card-desc {
  color: var(--color-brand-deep);
  opacity: 0.7;
}

html.dark .event-date {
  color: var(--color-brand-deep);
  opacity: 0.7;
}

html.dark .event-card-image {
  opacity: 0.9;
}
```

- [ ] **Passo 2: Compromit**

```bash
git add src/input.css
git commit -m "feat: adicionar estilos dark mode para event-card"
```

---

## Task 3: Verificar visualização no browser

**Test:** Visual verification in browser

- [ ] **Executar servidor de desenvolvimento**

Run: `npm run dev`

- [ ] **Testar em eventos.html:**

1. Abrir http://localhost:5173/eventos.html
2. Verificar que o header do card ocupa todo o topo (largura total)
3. Verificar que o conteúdo está abaixo do header
4. Clicar no toggle de dark mode
5. Verificar:
   - Background do card: `#111816` (var(--color-brand-bg-alt))
   - Borda: `#1f2927` (var(--color-brand-divider))
   - Texto do título: `#e5e7eb` (var(--color-brand-deep))
   - Data e descrição com opacidade adequada
   - Imagem com leve redução de opacidade

- [ ] **Testar em index.html:**

1. Abrir http://localhost:5173/index.html
2. Rolar até "Eventos em Destaque"
3. Verificar mesmos critérios de dark mode
4. Verificar que layout vertical se mantém em mobile e desktop

- [ ] **Commit se necessário** (apenas ajustes)

---

## Verification

Após implementação:

1. [ ] Header do card ocupa toda largura no topo (não lateral)
2. [ ] Conteúdo está abaixo do header (estrutura vertical)
3. [ ] Layout vertical funciona em mobile e desktop
4. [ ] Dark mode aplica background `#111816`
5. [ ] Dark mode aplica borda `#1f2927`
6. [ ] Textos têm contraste adequado em ambos modos
7. [ ] Toggle light/dark funciona sem flicker
8. [ ] Cards em eventos.html e index.html consistentes

---

## Execution Handoff

**Plan complete and saved to `docs/superpowers/plans/event-cards-restructure-dark-mode.md`**

Two execution options:

**1. Subagent-Driven (recommended)** - Dispatch fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
