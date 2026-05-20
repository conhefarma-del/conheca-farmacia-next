/**
 * Dashboard - Admin
 * Carrega estatísticas e renderiza gráficos
 */

import { supabaseClient } from '../config.js';
import { checkAuth, initIdleTimeout } from './lib/auth.js';
import { escapeHtml } from '../lib/security.js';
import {
  getArticles,
  getLives,
  getPublishedArticlesCount,
  getPublishedEventsCount,
  getPublishedLivesCount,
  getAdminUsersCount,
  getNewsletterSubscribersCount,
  getUniqueCategoriesCount,
  getRecentAdminActivity,
  getCategoryDistribution,
  getPageViewsByPeriod,
  getInscriptionsByPeriod
} from '../lib/api.js';
import { searchAllContent } from '../lib/search.js';

const supabase = supabaseClient;

// Formatar número com separador de milhares
function formatNumber(num) {
  return new Intl.NumberFormat('pt-PT').format(num);
}

// Carregar estatísticas
async function loadStats() {
  try {
    const [
      articlesCount,
      eventsCount,
      livesCount,
      usersCount,
      categoriesCount,
      activity
    ] = await Promise.all([
      getPublishedArticlesCount(),
      getPublishedEventsCount(),
      getPublishedLivesCount(),
      getAdminUsersCount(),
      getUniqueCategoriesCount(),
      getRecentAdminActivity(10)
    ]);

    // Atualizar cards de estatísticas
    document.getElementById('stat-articles').textContent = formatNumber(articlesCount);
    document.getElementById('stat-events').textContent = formatNumber(eventsCount);
    document.getElementById('stat-users').textContent = formatNumber(usersCount);
    document.getElementById('stat-files').textContent = formatNumber(livesCount);
    document.getElementById('stat-categories').textContent = formatNumber(categoriesCount);
    document.getElementById('stat-total').textContent = formatNumber(articlesCount + eventsCount + livesCount);

    // Carregar timeline de atividades na secção de atualizações
    loadActivityTimeline(activity || []);

    // Carregar distribuição de categorias para o gráfico
    loadCategoryChart();
  } catch (error) {
    console.error('Erro ao carregar estatísticas:', error);
  }
}

// Mapear table_name para label em português
const tableLabels = {
  articles: 'Artigo',
  events: 'Evento',
  lives: 'Live'
};

// Mapear action para label em português
const actionLabels = {
  CREATE: 'Criado',
  UPDATE: 'Atualizado',
  DELETE: 'Eliminado',
  PUBLISH: 'Publicado',
  UNPUBLISH: 'Despublicado'
};

// Formatar data/hora: "11:32 / 18/05/2026"
function formatDateTime(dateStr) {
  const d = new Date(dateStr);
  const time = d.toLocaleTimeString('pt-PT', { hour: '2-digit', minute: '2-digit' });
  const date = d.toLocaleDateString('pt-PT', { day: '2-digit', month: '2-digit', year: 'numeric' });
  return `${time} / ${date}`;
}

// Carregar timeline de atividades
function loadActivityTimeline(activity) {
  const container = document.getElementById('latest-events');

  if (!activity || activity.length === 0) {
    container.innerHTML = '<div class="admin-timeline"><div class="admin-timeline-item"><div class="admin-timeline-dot-wrapper"><div class="admin-timeline-dot action-create"></div></div><div class="admin-timeline-content"><div class="admin-timeline-text">Sem atividades recentes</div></div></div></div>';
    return;
  }

  const html = activity.map(item => {
    const tableLabel = tableLabels[item.table_name] || item.table_name;
    const actionLabel = actionLabels[item.action] || item.action;
    const actionClass = item.action.toLowerCase();
    const badgeText = `${tableLabel} ${actionLabel}`;
    const timeText = formatDateTime(item.created_at);

    // Extrair título do conteúdo de new_values
    let contentTitle = '';
    if (item.new_values) {
      const values = typeof item.new_values === 'string' ? JSON.parse(item.new_values) : item.new_values;
      contentTitle = escapeHtml(values.title || values.name || '');
    }

    return `
      <div class="admin-timeline-item">
        <div class="admin-timeline-dot-wrapper">
          <div class="admin-timeline-dot action-${actionClass}"></div>
        </div>
        <div class="admin-timeline-content">
          <div class="admin-timeline-text">${badgeText}${contentTitle ? ': ' + contentTitle : ''}</div>
          <div class="admin-timeline-badges">
            <span class="admin-timeline-badge badge-type badge-${actionClass}">${badgeText}</span>
            <span class="admin-timeline-badge badge-time">${timeText}</span>
          </div>
        </div>
      </div>
    `;
  }).join('');

  container.innerHTML = `<div class="admin-timeline">${html}</div>`;
}

// Activity chart instance reference for dynamic updates
window.activityChartInstance = null;

// Renderizar gráfico de atividade (visitas + inscrições)
function renderActivityChart() {
  const ctx = document.getElementById('activityChart');
  if (!ctx) return;

  window.activityChartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['A carregar...'],
      datasets: [{
        label: 'Conteudos',
        data: [0],
        backgroundColor: 'rgba(249, 115, 22, 0.7)',
        borderRadius: 4,
        barThickness: 10,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.parsed.x + ' registos';
            }
          }
        }
      },
      scales: {
        x: {
          beginAtZero: true,
          grid: {
            color: 'rgba(0, 0, 0, 0.05)'
          }
        },
        y: {
          grid: {
            display: false
          }
        }
      }
    }
  });
}

// Carregar dados de atividade para um período
async function loadActivityData(period = 'week') {
  try {
    const [pageViews, inscriptions] = await Promise.all([
      getPageViewsByPeriod(period),
      getInscriptionsByPeriod(period)
    ]);

    const colors = [
      'rgba(59, 130, 246, 0.8)',   // azul - visitas
      'rgba(249, 115, 22, 0.8)',   // laranja - inscrições
    ];

    if (window.activityChartInstance) {
      window.activityChartInstance.data.labels = ['Visitas ao Site', 'Inscrições em Eventos'];
      window.activityChartInstance.data.datasets[0].data = [pageViews, inscriptions];
      window.activityChartInstance.data.datasets[0].backgroundColor = colors;
      window.activityChartInstance.update();
    }
  } catch (error) {
    console.error('Erro ao carregar dados de atividade:', error);
  }
}

// Inicializar filtros do gráfico de atividade
function initActivityFilters() {
  const filterContainer = document.getElementById('activity-filters');
  if (!filterContainer) return;

  filterContainer.addEventListener('click', (e) => {
    const btn = e.target.closest('.admin-chart-filter-btn');
    if (!btn) return;

    // Atualizar estado ativo
    filterContainer.querySelectorAll('.admin-chart-filter-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    // Carregar dados para o período selecionado
    const period = btn.dataset.period;
    loadActivityData(period);
  });
}

// Renderizar gráfico de estatísticas (distribuição de categorias)
function renderStatsChart() {
  const ctx = document.getElementById('statsChart');
  if (!ctx) return;

  // Store chart reference for updates
  window.statsChartInstance = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['A carregar...'],
      datasets: [{
        label: 'Conteúdos',
        data: [0],
        backgroundColor: 'rgba(249, 115, 22, 0.7)',
        borderRadius: 4,
        barThickness: 10,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      plugins: {
        legend: {
          display: false
        }
      },
      scales: {
        x: {
          beginAtZero: true,
          grid: {
            color: 'rgba(0, 0, 0, 0.05)'
          }
        },
        y: {
          grid: {
            display: false
          }
        }
      }
    }
  });
}

// Carregar gráfico de distribuição de categorias com dados reais
async function loadCategoryChart() {
  try {
    const distribution = await getCategoryDistribution();

    if (!distribution || distribution.length === 0) return;

    const colors = [
      '#ff6c23',
      '#0a844f',
      '#7c3aed',
      '#002a32',
      '#006171',
      '#7c3aed',
    ];

    // Formatar labels: capitalizar primeira letra, remover hífens
    function formatLabel(label) {
      return label.replace(/-/g, ' ').replace(/\b\w/g, c => c.toUpperCase());
    }

    if (window.statsChartInstance) {
      window.statsChartInstance.data.labels = distribution.map(d => formatLabel(d.category));
      window.statsChartInstance.data.datasets[0].data = distribution.map(d => d.count);
      window.statsChartInstance.data.datasets[0].backgroundColor = distribution.map((_, i) => colors[i % colors.length]);
      window.statsChartInstance.update();
    }
  } catch (error) {
    console.error('Erro ao carregar distribuição de categorias:', error);
  }
}

// Inicializar dashboard
async function init() {
  const isAuth = await checkAuth();
  if (!isAuth) return;

  initIdleTimeout();
  loadStats();
  renderActivityChart();
  renderStatsChart();
  initSearch();
  initActivityFilters();
  loadActivityData('week');
}

// Iniciar quando o DOM estiver pronto
document.addEventListener('DOMContentLoaded', init);

/**
 * Initialize search functionality
 */
function initSearch() {
  const searchInput = document.getElementById('admin-search-input');
  if (!searchInput) return;

  const searchResultsContainer = document.createElement('div');
  searchResultsContainer.className = 'admin-search-results';
  searchInput.parentNode.insertBefore(searchResultsContainer, searchInput.nextSibling);

  let debounceTimer;
  searchInput.addEventListener('input', (e) => {
    const query = e.target.value.trim();
    clearTimeout(debounceTimer);

    if (query.length < 2) {
      searchResultsContainer.innerHTML = '';
      return;
    }

    debounceTimer = setTimeout(async () => {
      try {
        const results = await searchAllContent(query);
        displaySearchResults(results, searchResultsContainer);
      } catch (error) {
        console.error('Error performing search:', error);
        searchResultsContainer.innerHTML = '<p class="admin-search-error">Erro ao realizar pesquisa</p>';
      }
    }, 300);
  });

  document.addEventListener('click', (e) => {
    if (!searchInput.contains(e.target) && !searchResultsContainer.contains(e.target)) {
      searchResultsContainer.innerHTML = '';
    }
  });
}

/**
 * Display search results
 */
function displaySearchResults(results, container) {
  if (!results || (results.articles.length === 0 && results.events.length === 0 && results.lives.length === 0)) {
    container.innerHTML = '<p class="admin-search-no-results">Nenhum resultado encontrado</p>';
    return;
  }

  let html = '<div class="admin-search-results-content">';

  if (results.articles.length > 0) {
    html += '<h4 class="admin-search-section-title">Artigos (' + results.articles.length + ')</h4><ul class="admin-search-list">';
    results.articles.slice(0, 5).forEach(article => {
      html += '<li class="admin-search-item"><a href="/artigos/' + article.slug + '" target="_blank" class="admin-search-link">' + escapeHtml(article.title) + '</a></li>';
    });
    html += '</ul>';
  }

  if (results.events.length > 0) {
    html += '<h4 class="admin-search-section-title">Eventos (' + results.events.length + ')</h4><ul class="admin-search-list">';
    results.events.slice(0, 5).forEach(event => {
      html += '<li class="admin-search-item"><a href="/eventos/' + event.slug + '" target="_blank" class="admin-search-link">' + escapeHtml(event.title) + '</a></li>';
    });
    html += '</ul>';
  }

  if (results.lives.length > 0) {
    html += '<h4 class="admin-search-section-title">Lives (' + results.lives.length + ')</h4><ul class="admin-search-list">';
    results.lives.slice(0, 5).forEach(live => {
      html += '<li class="admin-search-item"><a href="/lives/' + live.slug + '" target="_blank" class="admin-search-link">' + escapeHtml(live.title) + '</a></li>';
    });
    html += '</ul>';
  }

  html += '</div>';
  container.innerHTML = html;
}

