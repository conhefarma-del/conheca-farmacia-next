# Módulo de Entrevistas - Plano de Implementação

> **Para agentes de implementação:** Use a skill `superpowers:executing-plans` para executar este plano passo a passo.

**Goal:** Criar um módulo completo de Entrevistas com profissionais de saúde, seguindo o padrão da arquitetura dos Artigos, com suporte para vídeo (YouTube API com lazy loading), áudio embed, sumário executivo opcional, pull quotes, Q&A em timeline vertical e transcrição expansível.

**Arquitetura:** Segue o padrão Artigos:
- Página de lista: `entrevistas.html` (grid de cards com filtros e pesquisa)
- Página de detalhe: `entrevista.html` (conteúdo completo com sidebar)
- Dados: JSON em `src/content/interviews-catalog.json`
- Lógica: `src/interviews-logic.js` (lista) e `src/interview-detail.js` (detalhe)

**Tech Stack:**
- HTML5, TailwindCSS v4, JavaScript (ES6+)
- YouTube IFrame API (com lazy loading via thumbnail)
- Video.js para customização do player
- DOMPurify para sanitização
- Marcador.js para renderização de Markdown

---

## Estrutura de Ficheiros

### Criar:
- `entrevistas.html` — Página de listagem
- `entrevista.html` — Página de detalhe
- `src/interviews-logic.js` — Lógica da lista
- `src/interview-detail.js` — Lógica do detalhe
- `src/content/interviews-catalog.json` — Catálogo de dados
- `src/interview-video.js` — Módulo de vídeo (YouTube API + Video.js)

### Modificar:
- `src/script.js` — Adicionar navegação para nova secção (se necessário)
- `src/input.css` — Estilos específicos para entrevistas

---

## Tasks

### Task 1: Estrutura de Dados (JSON Catalog)

**Files:**
- Create: `src/content/interviews-catalog.json`

- [ ] **Step 1: Criar JSON com estrutura completa**

```json
{
  "interviews": [
    {
      "id": "001-dra-ana-silva",
      "slug": "001-dra-ana-silva",
      "title": "O Papel do Farmacêutico na Saúde Pública",
      "excerpt": "Conversa com Dra. Ana Silva sobre desafios da farmácia clínica em Angola.",
      "category": "profissionais",
      "categoryLabel": "Profissionais",
      "interviewee": {
        "name": "Dra. Ana Silva",
        "role": "Farmacêutica Clínica · Hospital Nacional",
        "bio": "15 anos de experiência em farmácia hospitalar.",
        "avatar": "AS",
        "avatarBg": "#00493a"
      },
      "interviewer": {
        "name": "João Santos",
        "role": "Editor",
        "avatar": "JS",
        "avatarBg": "#0a844f"
      },
      "date": "2026-05-10",
      "readTime": 12,
      "videoDuration": "25:30",
      "thumbnail": "/content/interviews/ana-silva-thumb.jpg",
      "videoId": "dQw4w9WgXcQ",
      "audioUrl": null,
      "executiveSummary": "Principais pontos: 1) Importância da formação contínua; 2) Necessidade de mais farmacêuticos clínicos; 3) Papel na prevenção.",
      "pullQuotes": [
        "O farmacêutico é a última barreira entre o erro de medicação e o doente.",
        "Precisamos de mais formação prática e menos teoria descontextualizada."
      ],
      "qa": [
        {
          "question": "Qual é o maior desafio da farmácia em Angola?",
          "answer": "A falta de recursos e a necessidade de formação contínua."
        },
        {
          "question": "Que conselho dá a jovens farmacêuticos?",
          "answer": "Nunca parem de estudar e estejam onde o doente precisa."
        }
      ],
      "content": "## Introdução\n\nA Dra. Ana Silva partilha a sua experiência...\n\n## Formação\n\nO percurso académico...",
      "references": [
        "Ordem dos Farmacêuticos de Angola. Relatório 2025.",
        "WHO. Global Pharmacy Workforce Statistics, 2024."
      ],
      "related": ["002-genericos", "003-saude-mental"]
    }
  ]
}
```

---

### Task 2: Página de Listagem (entrevistas.html)

**Files:**
- Create: `entrevistas.html`
- Modify: `src/interviews-logic.js`

- [ ] **Step 1: Criar estrutura HTML base**

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Entrevistas - Conheça Farmácia</title>
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700&display=swap" rel="stylesheet" />
</head>
<body class="antialiased text-brand-deep bg-brand-bg">
  <!-- Header (igual artigos.html) -->
  <header class="header">
    <!-- ... header content ... -->
  </header>

  <main class="container mx-auto px-4 py-12">
    <!-- Título e Filtros -->
    <section class="mb-12">
      <h1 class="text-4xl font-bold mb-4">Entrevistas</h1>
      <p class="text-lg text-gray-600 dark:text-gray-400 mb-8">
        Conversas com profissionais de saúde sobre desafios, inovação e o futuro da farmácia.
      </p>
      
      <!-- Barra de Pesquisa -->
      <div class="mb-6">
        <input 
          type="text" 
          id="search-input" 
          placeholder="Pesquisar entrevistas..." 
          class="form-input w-full max-w-md"
        />
      </div>

      <!-- Filtros de Categoria -->
      <div class="flex flex-wrap gap-2 mb-6">
        <button class="filter-btn active" data-category="all">Todas</button>
        <button class="filter-btn" data-category="profissionais">Profissionais</button>
        <button class="filter-btn" data-category="lideres">Líderes</button>
        <button class="filter-btn" data-category="educadores">Educadores</button>
      </div>
    </section>

    <!-- Grid de Entrevistas -->
    <div id="interviews-grid" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Preenchido via JS -->
    </div>

    <!-- Sem Resultados -->
    <div id="no-results" class="hidden text-center py-12">
      <p class="text-xl text-gray-500">Nenhuma entrevista encontrada.</p>
    </div>
  </main>

  <!-- Footer -->
  <footer class="footer">
    <!-- ... footer content ... -->
  </footer>

  <script type="module" src="/src/interviews-logic.js"></script>
</body>
</html>
```

- [ ] **Step 2: Criar lógica JavaScript (`src/interviews-logic.js`)**

```javascript
import interviewsData from "./content/interviews-catalog.json";

let interviews = [];
let currentFilter = "all";
let searchTerm = "";

const categoryColors = {
  profissionais: "#ff6c23",
  lideres: "#0a844f",
  educadores: "#002a32",
  investigadores: "#006171",
};

document.addEventListener("DOMContentLoaded", () => {
  const grid = document.getElementById("interviews-grid");
  const noResults = document.getElementById("no-results");
  const searchInput = document.getElementById("search-input");
  const filterButtons = document.querySelectorAll(".filter-btn");

  function renderInterviews() {
    const filtered = interviews.filter((interview) => {
      const matchesFilter =
        currentFilter === "all" || interview.category === currentFilter;
      const matchesSearch =
        interview.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        interview.excerpt.toLowerCase().includes(searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    });

    grid.innerHTML = "";

    if (filtered.length === 0) {
      noResults.classList.remove("hidden");
    } else {
      noResults.classList.add("hidden");
      filtered.forEach((interview) => {
        const card = document.createElement("article");
        card.className = "interview-card border border-brand-divider/10 rounded-lg overflow-hidden shadow-soft hover:shadow-md transition-shadow";
        card.innerHTML = `
          <div class="relative">
            <img src="${interview.thumbnail}" alt="${interview.title}" class="w-full h-48 object-cover" loading="lazy" />
            ${interview.videoId ? `<div class="absolute inset-0 flex items-center justify-center bg-black/30"><svg class="w-16 h-16 text-white"><use href="#play-icon"></use></svg></div>` : ''}
          </div>
          <div class="p-4">
            <span class="text-xs font-semibold px-2 py-1 rounded" style="background-color: ${categoryColors[interview.category]}20; color: ${categoryColors[interview.category]}">${interview.categoryLabel}</span>
            <h3 class="text-xl font-bold mt-2 mb-2">${interview.title}</h3>
            <p class="text-gray-600 dark:text-gray-400 text-sm mb-3">${interview.excerpt}</p>
            <div class="flex items-center justify-between text-xs text-gray-500">
              <span>${interview.interviewee.name}</span>
              <span>${interview.videoDuration || interview.readTime + ' min'}</span>
            </div>
          </div>
        `;
        card.addEventListener("click", () => {
          window.location.href = `entrevista.html?id=${interview.id}`;
        });
        grid.appendChild(card);
      });
    }
  }

  // Event Listeners
  searchInput?.addEventListener("input", (e) => {
    searchTerm = e.target.value;
    renderInterviews();
  });

  filterButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      filterButtons.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentFilter = btn.dataset.category;
      renderInterviews();
    });
  });

  interviews = interviewsData.interviews;
  renderInterviews();
});
```

---

### Task 3: Página de Detalhe (entrevista.html)

**Files:**
- Create: `entrevista.html`
- Modify: `src/interview-detail.js`

- [ ] **Step 1: Estrutura HTML com todas as secções**

Layout: 2/3 conteúdo + 1/3 sidebar (igual artigo.html)

```html
<main class="container mx-auto px-4 py-12">
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
    <!-- Conteúdo Principal (2/3) -->
    <div class="lg:col-span-2">
      <!-- Zona de Vídeo (condicional) -->
      <section id="video-section" class="mb-8">
        <div id="video-container" class="video-wrapper">
          <!-- YouTube IFrame API -->
        </div>
      </section>

      <!-- Sumário Executivo (opcional) -->
      <section id="executive-summary" class="mb-8 p-4 bg-brand-accent/5 border-l-4 border-brand-accent rounded">
        <h2 class="text-lg font-bold mb-2">Sumário Executivo</h2>
        <p id="summary-text" class="text-gray-700 dark:text-gray-300"></p>
      </section>

      <!-- Pull Quotes -->
      <section id="pull-quotes" class="mb-8">
        <!-- Pull quotes inseridas via JS -->
      </section>

      <!-- Conteúdo Principal (Markdown) -->
      <article id="content" class="prose prose-lg dark:prose-invert"></article>

      <!-- Q&A Timeline Vertical -->
      <section id="qa-section" class="mt-12">
        <h2 class="text-2xl font-bold mb-6">Perguntas & Respostas</h2>
        <div id="qa-timeline" class="relative border-l-2 border-brand-accent pl-6 space-y-6">
          <!-- QA items via JS -->
        </div>
      </section>

      <!-- Transcrição Expansível -->
      <section class="mt-12">
        <button id="toggle-transcript" class="btn-primary mb-4">
          Mostrar Transcrição Completa
        </button>
        <div id="transcript" class="hidden prose dark:prose-invert"></div>
      </section>

      <!-- Referências -->
      <section id="references-section" class="mt-12">
        <h3 class="text-lg font-bold mb-4">Referências</h3>
        <div id="references"></div>
      </section>
    </div>

    <!-- Sidebar (1/3) -->
    <aside class="lg:col-span-1">
      <!-- Info Entrevistado -->
      <div class="bg-brand-bg-alt p-6 rounded-lg shadow-soft">
        <img src="${interviewee.avatar}" class="w-20 h-20 rounded-full mb-4" />
        <h3 class="font-bold text-lg">${interviewee.name}</h3>
        <p class="text-sm text-gray-600 dark:text-gray-400">${interviewee.role}</p>
        <p class="text-sm mt-2">${interviewee.bio}</p>
      </div>

      <!-- Partilha -->
      <div class="mt-6">
        <h4 class="font-semibold mb-3">Partilhar</h4>
        <div class="flex gap-2">
          <button class="share-btn twitter">Twitter</button>
          <button class="share-btn linkedin">LinkedIn</button>
          <button class="share-btn whatsapp">WhatsApp</button>
          <button class="share-btn copy">Copiar Link</button>
        </div>
      </div>

      <!-- Entrevistas Relacionadas -->
      <div class="mt-6">
        <h4 class="font-semibold mb-3">Também pode gostar</h4>
        <div id="related-interviews"></div>
      </div>
    </aside>
  </div>
</main>
```

---

### Task 4: Módulo de Vídeo (YouTube API + Lazy Loading)

**Files:**
- Create: `src/interview-video.js`

- [ ] **Step 1: Implementar lazy loading com thumbnail**

```javascript
export function loadYouTubePlayer(containerId, videoId, onReady) {
  const container = document.getElementById(containerId);
  
  // Criar thumbnail
  const thumbnailUrl = `https://img.youtube.com/vi/${videoId}/hqdefault.jpg`;
  
  container.innerHTML = `
    <div class="youtube-thumbnail relative cursor-pointer" data-video-id="${videoId}">
      <img src="${thumbnailUrl}" alt="YouTube thumbnail" class="w-full h-full object-cover" />
      <div class="absolute inset-0 flex items-center justify-center bg-black/40 hover:bg-black/30 transition">
        <div class="play-button w-20 h-20 bg-white/90 rounded-full flex items-center justify-center">
          <svg class="w-8 h-8 text-brand-primary"><use href="#play-icon"></use></svg>
        </div>
      </div>
    </div>
  `;

  const thumbnail = container.querySelector('.youtube-thumbnail');
  thumbnail.addEventListener('click', () => {
    // Carregar YouTube IFrame API
    if (!window.YT) {
      const tag = document.createElement('script');
      tag.src = 'https://www.youtube.com/iframe_api';
      tag.onload = () => initPlayer();
      document.head.appendChild(tag);
    } else {
      initPlayer();
    }

    function initPlayer() {
      container.innerHTML = `
        <div id="youtube-player"></div>
      `;
      
      const player = new YT.Player('youtube-player', {
        videoId: videoId,
        playerVars: {
          autoplay: 1,
          modestbranding: 1,
          rel: 0,
        },
        events: {
          onReady: (event) => {
            onReady?.(event);
          }
        }
      });
    }
  });
}
```

---

### Task 5: Estilos CSS para Entrevistas

**Files:**
- Modify: `src/input.css`

- [ ] **Step 1: Adicionar estilos específicos**

```css
/* Interview Cards */
.interview-card {
  @apply bg-brand-bg rounded-lg overflow-hidden transition-all duration-300;
}

.interview-card:hover {
  @apply shadow-md transform -translate-y-1;
}

/* Video Wrapper */
.video-wrapper {
  @apply relative w-full;
  aspect-ratio: 16 / 9;
}

/* Pull Quotes */
.pull-quote {
  @apply my-8 p-6 bg-brand-accent/10 border-l-4 border-brand-accent rounded-r-lg;
  font-size: 1.25rem;
  font-weight: 500;
  position: relative;
}

.pull-quote::before {
  content: """;
  @apply text-6xl text-brand-accent/30 absolute -top-4 -left-2;
}

/* QA Timeline */
.qa-item {
  @apply relative pb-8;
}

.qa-item::before {
  content: "";
  @apply absolute w-3 h-3 bg-brand-accent rounded-full -left-[31px] top-1;
}

.qa-question {
  @apply font-bold text-brand-primary mb-2;
}

/* Transcript Toggle */
.transcript-toggle {
  @apply px-4 py-2 bg-brand-primary text-white rounded hover:bg-brand-primary/90 transition;
}

/* Dark mode adjustments */
html.dark .pull-quote {
  @apply bg-brand-accent/20;
}
```

---

### Task 6: Funcionalidade de Partilha

**Files:**
- Create: `src/share-utils.js`

- [ ] **Step 1: Criar utilitários de partilha**

```javascript
export function initShareButtons() {
  const shareUrl = encodeURIComponent(window.location.href);
  const title = encodeURIComponent(document.title);

  document.querySelector('.share-btn.twitter')?.addEventListener('click', () => {
    window.open(`https://twitter.com/intent/tweet?text=${title}&url=${shareUrl}`, '_blank');
  });

  document.querySelector('.share-btn.linkedin')?.addEventListener('click', () => {
    window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${shareUrl}`, '_blank');
  });

  document.querySelector('.share-btn.whatsapp')?.addEventListener('click', () => {
    window.open(`https://wa.me/?text=${title}%20${shareUrl}`, '_blank');
  });

  document.querySelector('.share-btn.copy')?.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(window.location.href);
      // Mostrar toast de confirmação
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  });
}
```

---

## Verificação

### Testes a realizar:
1. **Lista:**
   - [ ] Carregar JSON e renderizar grid
   - [ ] Filtros de categoria funcionam
   - [ ] Pesquisa por texto funciona
   - [ ] Layout responsivo (mobile/desktop)

2. **Detalhe:**
   - [ ] Vídeo YouTube carrega apenas ao clicar (lazy)
   - [ ] Sumário executivo aparece apenas se preenchido
   - [ ] Pull quotes com bg-brand-bg e aspas
   - [ ] Q&A em timeline vertical
   - [ ] Transcrição expande/recolhe
   - [ ] Sidebar com info do entrevistado
   - [ ] Botões de partilha funcionam
   - [ ] Layout 2/3 + 1/3 responsivo

3. **Dark Mode:**
   - [ ] Todas as cores adaptam corretamente
   - [ ] Contraste adequado

4. **Performance:**
   - [ ] Lazy loading de imagens
   - [ ] Vídeo só carrega ao interagir
   - [ ] JSON não bloqueia renderização

---

## Notas de Implementação

- **Seguir padrão Artigos:** Reutilizar padrões de `articles-logic.js` e `article-detail.js`
- **JSON opcional:** Campos como `executiveSummary`, `pullQuotes`, `qa` são opcionais
- **Responsive:** Mobile-first, mas otimizado para desktop
- **Acessibilidade:** Focus states, ARIA labels, keyboard navigation
- **Commits frequentes:** Um commit por task concluída

---

**Plano criado:** 2026-05-10
**Próximos passos:** Executar plano com `superpowers:executing-plans` ou `superpowers:subagent-driven-development`
