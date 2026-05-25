// src/pesquisa-logic.js
// Logica da pagina de pesquisa — Conheca Farmacia

import { searchAllContent } from './lib/search.js';
import { escapeHtml, escapeAttr, validateUrl } from './lib/security.js';
import {
  setDocumentTitle,
  setMetaDescription,
  setCanonicalUrl,
  setOpenGraphTags,
  setTwitterCardTags,
  injectJsonLd
} from './lib/seo.js';

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------

const PER_PAGE = 15;

const TYPE_META = {
  articles: { icon: '\ud83d\udcc4', label: 'Artigo', page: 'artigo.html' },
  events:   { icon: '\ud83d\udcc5', label: 'Evento', page: 'evento.html' },
  lives:    { icon: '\ud83c\udfac', label: 'Live',   page: 'lives.html' }
};

const MONTHS_PT = [
  'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
  'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
];

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

let currentParams = null;
let cachedItems = [];      // All merged results from last search
let cachedTotal = 0;

// ---------------------------------------------------------------------------
// URL helpers
// ---------------------------------------------------------------------------

function readParams() {
  const sp = new URLSearchParams(window.location.search);
  return {
    q:     sp.get('q')     || '',
    tipo:  sp.get('tipo')  || 'todos',
    ordem: sp.get('ordem') || 'recente',
    p:     Math.max(1, parseInt(sp.get('p'), 10) || 1)
  };
}

function pushParams(params) {
  const sp = new URLSearchParams();
  if (params.q)              sp.set('q', params.q);
  if (params.tipo !== 'todos') sp.set('tipo', params.tipo);
  if (params.ordem !== 'recente') sp.set('ordem', params.ordem);
  if (params.p > 1)          sp.set('p', String(params.p));

  const qs = sp.toString();
  const url = qs ? `${window.location.pathname}?${qs}` : window.location.pathname;
  window.history.pushState(params, '', url);
}

// ---------------------------------------------------------------------------
// Date formatting
// ---------------------------------------------------------------------------

function formatDatePt(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return '';
  return `${d.getDate()} ${MONTHS_PT[d.getMonth()]} ${d.getFullYear()}`;
}

// ---------------------------------------------------------------------------
// Rendering helpers
// ---------------------------------------------------------------------------

/**
 * Escape a string for safe use inside a RegExp.
 */
function escapeRegExp(str) {
  return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

/**
 * Highlight query terms in already-escaped HTML text.
 * Wraps each match in <mark> for visual emphasis.
 */
function highlightTerms(text, query) {
  if (!query || !query.trim()) return text;

  const words = query.trim().split(/\s+/).filter(Boolean);
  if (words.length === 0) return text;

  const pattern = words.map(escapeRegExp).join('|');
  const regex = new RegExp(`(${pattern})`, 'gi');
  return text.replace(regex, '<mark class="search-highlight">$1</mark>');
}

function renderCard(item, contentType, query) {
  const meta = TYPE_META[contentType];
  if (!meta) return '';

  const rawTitle    = escapeHtml(item.title || 'Sem titulo');
  const rawExcerpt  = escapeHtml(item.excerpt || '');
  const safeTitle   = highlightTerms(rawTitle, query);
  const safeExcerpt = highlightTerms(rawExcerpt, query);
  const safeAlt     = escapeAttr(item.title || 'Imagem');
  const safeImg     = validateUrl(item.imageUrl);
  const slug        = encodeURIComponent(item.slug || item.id);
  const href        = `${meta.page}?id=${slug}`;
  const date        = formatDatePt(item.publishedDate || item.date);

  return `
    <a href="${href}" class="search-result-card">
      <div class="search-result-image">
        <img src="${safeImg}" alt="${safeAlt}" loading="lazy">
      </div>
      <div class="search-result-body">
        <span class="search-result-type">${meta.icon} ${escapeHtml(meta.label)}</span>
        <h3 class="search-result-title">${safeTitle}</h3>
        <p class="search-result-excerpt">${safeExcerpt}</p>
        ${date ? `<span class="search-result-date">${date}</span>` : ''}
      </div>
    </a>`;
}

function mergeResults(data) {
  const items = [];

  for (const a of (data.articles || [])) {
    items.push({ ...a, _type: 'articles' });
  }
  for (const e of (data.events || [])) {
    items.push({ ...e, _type: 'events' });
  }
  for (const l of (data.lives || [])) {
    items.push({ ...l, _type: 'lives' });
  }

  return items;
}

function renderSkeletons(count = 6) {
  let html = '';
  for (let i = 0; i < count; i++) {
    html += `
      <div class="search-result-card skeleton-card">
        <div class="search-result-image skeleton-pulse"></div>
        <div class="search-result-body">
          <span class="skeleton-pulse" style="width:60px;height:14px;display:block;border-radius:4px"></span>
          <h3 class="skeleton-pulse" style="width:80%;height:20px;display:block;border-radius:4px;margin:8px 0"></h3>
          <p class="skeleton-pulse" style="width:100%;height:14px;display:block;border-radius:4px;margin-bottom:6px"></p>
          <p class="skeleton-pulse" style="width:60%;height:14px;display:block;border-radius:4px"></p>
        </div>
      </div>`;
  }
  return html;
}

function renderPagination(currentPage, totalResults) {
  const totalPages = Math.ceil(totalResults / PER_PAGE);
  if (totalPages <= 1) return '';

  let html = '<div class="search-pagination">';

  if (currentPage > 1) {
    html += `<button class="page-btn" data-page="${currentPage - 1}" aria-label="Pagina anterior">&larr;</button>`;
  }

  for (let i = 1; i <= totalPages; i++) {
    const active = i === currentPage ? ' active' : '';
    html += `<button class="page-btn${active}" data-page="${i}">${i}</button>`;
  }

  if (currentPage < totalPages) {
    html += `<button class="page-btn" data-page="${currentPage + 1}" aria-label="Pagina seguinte">&rarr;</button>`;
  }

  html += '</div>';
  return html;
}

// ---------------------------------------------------------------------------
// SEO
// ---------------------------------------------------------------------------

function updateSEO(query) {
  const q = (query || '').trim();
  const title = q
    ? `Pesquisa: ${q} — Conheca Farmacia`
    : 'Pesquisa — Conheca Farmacia';
  const description = q
    ? `Resultados da pesquisa por "${q}" em artigos, eventos e lives da Conheca Farmacia.`
    : 'Pesquise artigos, eventos e lives sobre farmacia e saude na Conheca Farmacia.';

  const canonical = q
    ? `${window.location.origin}/pesquisa.html?q=${encodeURIComponent(q)}`
    : `${window.location.origin}/pesquisa.html`;

  setDocumentTitle(title);
  setMetaDescription(description);
  setCanonicalUrl(canonical);
  setOpenGraphTags({
    title,
    description,
    url: canonical,
    type: 'website'
  });
  setTwitterCardTags({ title, description });

  injectJsonLd({
    '@context': 'https://schema.org',
    '@type': 'SearchResultsPage',
    'name': title,
    'description': description,
    'url': canonical
  }, 'pesquisa-jsonld');
}

// ---------------------------------------------------------------------------
// Core search flow
// ---------------------------------------------------------------------------

/**
 * Fetch all results from Supabase and cache them.
 * Then render the requested page from the cache.
 */
async function runSearch(params) {
  currentParams = { ...params };
  pushParams(params);
  updateSEO(params.q);

  const container  = document.getElementById('search-results');
  const countEl    = document.getElementById('search-count');
  const pagination = document.getElementById('search-pagination');
  const emptyEl    = document.getElementById('search-empty');

  if (!container) return;

  // Show loading skeletons
  container.innerHTML = renderSkeletons();
  if (pagination) pagination.innerHTML = '';
  if (emptyEl) emptyEl.style.display = 'none';

  // Sync filter/sort UI
  syncFilterButtons(params.tipo);
  syncSortSelect(params.ordem);

  // If no query, show empty state immediately
  if (!params.q || !params.q.trim()) {
    container.innerHTML = '';
    if (countEl) countEl.textContent = '';
    if (emptyEl) {
      emptyEl.textContent = 'Escreva o que pretende pesquisar.';
      emptyEl.style.display = 'block';
    }
    cachedItems = [];
    cachedTotal = 0;
    return;
  }

  try {
    const data = await searchAllContent(params.q, params.tipo, params.ordem);

    // Cache all merged results
    cachedItems = mergeResults(data);
    cachedTotal = data.total;

    renderCurrentPage(params);
  } catch (_err) {
    container.innerHTML = '';
    if (emptyEl) {
      emptyEl.textContent = 'Ocorreu um erro ao pesquisar. Tente novamente.';
      emptyEl.style.display = 'block';
    }
    cachedItems = [];
    cachedTotal = 0;
  }
}

/**
 * Render the current page from cached results.
 * Used for page changes without re-fetching.
 */
function renderCurrentPage(params) {
  const container  = document.getElementById('search-results');
  const countEl    = document.getElementById('search-count');
  const pagination = document.getElementById('search-pagination');
  const emptyEl    = document.getElementById('search-empty');

  if (!container) return;
  if (emptyEl) emptyEl.style.display = 'none';

  // Update count
  if (countEl) {
    if (cachedTotal > 0) {
      countEl.textContent = `${cachedTotal} resultado${cachedTotal !== 1 ? 's' : ''} encontrado${cachedTotal !== 1 ? 's' : ''}`;
    } else {
      countEl.textContent = '';
    }
  }

  // Empty state
  if (cachedItems.length === 0) {
    container.innerHTML = '';
    if (emptyEl) {
      emptyEl.textContent = `Nenhum resultado encontrado para "${params.q}".`;
      emptyEl.style.display = 'block';
    }
    if (pagination) pagination.innerHTML = '';
    return;
  }

  // Paginate from cache
  const from = (params.p - 1) * PER_PAGE;
  const to = from + PER_PAGE;
  const pageItems = cachedItems.slice(from, to);

  // Render cards
  container.innerHTML = pageItems
    .map((item) => renderCard(item, item._type, params.q))
    .join('');

  // Pagination
  if (pagination) {
    pagination.innerHTML = renderPagination(params.p, cachedTotal);
  }
}

/**
 * Navigate to a different page (client-side, no re-fetch).
 */
function goToPage(newPage) {
  const totalPages = Math.ceil(cachedTotal / PER_PAGE);
  if (newPage < 1 || newPage > totalPages || newPage === currentParams.p) return;

  currentParams.p = newPage;
  pushParams(currentParams);
  renderCurrentPage(currentParams);

  // Scroll to results
  const container = document.getElementById('search-results');
  if (container) container.scrollIntoView({ behavior: 'smooth', block: 'start' });
}

// ---------------------------------------------------------------------------
// UI sync helpers
// ---------------------------------------------------------------------------

function syncFilterButtons(tipo) {
  const buttons = document.querySelectorAll('[data-filter]');
  buttons.forEach((btn) => {
    const isActive = btn.getAttribute('data-filter') === tipo;
    btn.classList.toggle('active', isActive);
    btn.setAttribute('aria-pressed', String(isActive));
  });
}

function syncSortSelect(ordem) {
  const select = document.getElementById('search-sort');
  if (select) select.value = ordem;
}

// ---------------------------------------------------------------------------
// Event binding
// ---------------------------------------------------------------------------

function bindEvents() {
  const input = document.getElementById('search-input');
  const searchBtn = document.getElementById('search-btn');

  /**
   * Trigger a new search from the input value.
   */
  function triggerSearch() {
    if (!input) return;
    const q = input.value.trim();
    currentParams.q = q;
    currentParams.p = 1;
    runSearch(currentParams);
  }

  // Search on Enter key
  if (input) {
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Enter') {
        e.preventDefault();
        triggerSearch();
      }
    });
  }

  // Search on button click
  if (searchBtn) {
    searchBtn.addEventListener('click', (e) => {
      e.preventDefault();
      triggerSearch();
    });
  }

  // Filter buttons (Todos / Artigos / Eventos / Lives)
  document.addEventListener('click', (e) => {
    const btn = e.target.closest('[data-filter]');
    if (!btn) return;

    e.preventDefault();
    const tipo = btn.getAttribute('data-filter');
    if (tipo === currentParams.tipo) return;

    currentParams.tipo = tipo;
    currentParams.p = 1;
    runSearch(currentParams);
  });

  // Sort select
  const sortSelect = document.getElementById('search-sort');
  if (sortSelect) {
    sortSelect.addEventListener('change', () => {
      currentParams.ordem = sortSelect.value;
      currentParams.p = 1;
      runSearch(currentParams);
    });
  }

  // Pagination (delegated)
  const paginationEl = document.getElementById('search-pagination');
  if (paginationEl) {
    paginationEl.addEventListener('click', (e) => {
      const btn = e.target.closest('.page-btn');
      if (!btn) return;

      e.preventDefault();
      const raw = btn.getAttribute('data-page');
      if (!raw) return;

      const newPage = parseInt(raw, 10);
      if (!isNaN(newPage)) {
        goToPage(newPage);
      }
    });
  }

  // Back/forward browser buttons
  window.addEventListener('popstate', () => {
    currentParams = readParams();

    // If we have cached results and only the page changed, just re-render
    if (cachedItems.length > 0) {
      renderCurrentPage(currentParams);
    } else {
      runSearch(currentParams);
    }

    // Sync search input value
    if (input && input.value !== currentParams.q) {
      input.value = currentParams.q;
    }
  });
}

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

export function initSearch() {
  currentParams = readParams();

  // Sync input with URL param
  const input = document.getElementById('search-input');
  if (input && currentParams.q) {
    input.value = currentParams.q;
  }

  bindEvents();

  // If there's a query in the URL, run search immediately
  if (currentParams.q) {
    runSearch(currentParams);
  }
}

// Auto-init on DOMContentLoaded
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initSearch);
} else {
  initSearch();
}
