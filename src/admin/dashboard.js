/**
 * Dashboard - Admin
 * Carrega estatísticas e renderiza gráficos
 */

import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
import {
  getArticles,
  getEvents,
  getLives
} from '../lib/api.js';

// Configuração do Supabase
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://your-project.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'your-anon-key';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Verificar autenticação
async function checkAuth() {
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    window.location.href = '/src/admin/index.html';
    return false;
  }

  return true;
}

// Formatar número com separador de milhares
function formatNumber(num) {
  return new Intl.NumberFormat('pt-PT').format(num);
}

// Carregar estatísticas
async function loadStats() {
  try {
    const articles = await getArticles();
    const events = await getEvents();
    const lives = await getLives();

    // Atualizar cards de estatísticas
    document.getElementById('stat-articles').textContent = formatNumber(articles.length);
    document.getElementById('stat-events').textContent = formatNumber(events.length);
    document.getElementById('stat-users').textContent = formatNumber(21); // Simulado
    document.getElementById('stat-files').textContent = formatNumber(1220); // Simulado
    document.getElementById('stat-categories').textContent = formatNumber(65); // Simulado
    document.getElementById('stat-comments').textContent = formatNumber(9876); // Simulado

    // Carregar últimos eventos
    loadLatestEvents(events.slice(0, 5));
  } catch (error) {
    console.error('Erro ao carregar estatísticas:', error);
  }
}

// Carregar últimos eventos
function loadLatestEvents(events) {
  const container = document.getElementById('latest-events');

  if (!events || events.length === 0) {
    container.innerHTML = '<li class="admin-activity-item"><span class="admin-activity-desc">Sem eventos recentes</span></li>';
    return;
  }

  const eventIcons = {
    'page': 'stat-green',
    'comment': 'stat-purple',
    'user': 'stat-orange',
    'post': 'stat-blue'
  };

  container.innerHTML = events.map(event => `
    <li class="admin-activity-item">
      <div class="admin-activity-icon ${eventIcons.page || 'stat-green'}">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
        </svg>
      </div>
      <div class="admin-activity-content">
        <div class="admin-activity-title">${event.title || 'Evento'}</div>
        <div class="admin-activity-desc">${event.description ? event.description.substring(0, 50) + '...' : 'Novo Evento'}</div>
      </div>
      <span class="admin-activity-time">${event.date ? new Date(event.date).toLocaleDateString('pt-PT') : 'Hoje'}</span>
    </li>
  `).join('');
}

// Renderizar gráfico de estatísticas de utilizadores
function renderUserStatsChart() {
  const ctx = document.getElementById('userStatsChart');
  if (!ctx) return;

  // Dados simulados para o gráfico
  const data = {
    labels: ['9', '11', '13', '15', '17', '19', '21', '23', '25', '27', '29'],
    datasets: [{
      label: 'Utilizadores',
      data: [320, 400, 280, 350, 420, 480, 380, 450, 320, 380, 420],
      backgroundColor: 'rgba(16, 185, 129, 0.7)',
      borderRadius: 4,
    }]
  };

  new Chart(ctx, {
    type: 'bar',
    data: data,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return context.parsed.y + ' utilizadores';
            }
          }
        }
      },
      scales: {
        y: {
          beginAtZero: true,
          grid: {
            color: 'rgba(0, 0, 0, 0.05)'
          }
        },
        x: {
          grid: {
            display: false
          }
        }
      }
    }
  });
}

// Renderizar gráfico de estatísticas
function renderStatsChart() {
  const ctx = document.getElementById('statsChart');
  if (!ctx) return;

  new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['10', '20', '30', '40', '50', '60', '70', '80', '90', '100', '110', '120'],
      datasets: [
        {
          label: 'Visitantes',
          data: [120, 150, 180, 140, 160, 190, 200, 170, 210, 220, 240, 250],
          backgroundColor: 'rgba(249, 115, 22, 0.7)',
          borderRadius: 2,
        },
        {
          label: 'Subscritores',
          data: [80, 100, 120, 90, 110, 130, 140, 120, 150, 160, 170, 180],
          backgroundColor: 'rgba(139, 92, 246, 0.7)',
          borderRadius: 2,
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      indexAxis: 'y',
      plugins: {
        legend: {
          position: 'bottom'
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

// Renderizar gráfico de velocidade do site
function renderSpeedChart() {
  const ctx = document.getElementById('speedChart');
  if (!ctx) return;

  // Dados simulados
  const speedData = {
    labels: ['Grade', 'Page Size', 'Load Time', 'Requests'],
    datasets: [{
      data: [75, 100, 60, 42],
      backgroundColor: [
        'rgba(59, 130, 246, 0.7)',
        'rgba(139, 92, 246, 0.7)',
        'rgba(16, 185, 129, 0.7)',
        'rgba(249, 115, 22, 0.7)'
      ],
      borderWidth: 0
    }]
  };

  new Chart(ctx, {
    type: 'doughnut',
    data: speedData,
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          position: 'bottom'
        }
      }
    }
  });
}

// Inicializar dashboard
async function init() {
  const isAuth = await checkAuth();
  if (!isAuth) return;

  loadStats();
  renderUserStatsChart();
  renderStatsChart();
  renderSpeedChart();
  initSearch();
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
  if (!results || (results.articles.length === 0 && results.events.length === 0 && results.lives.length === 0 && results.users.length === 0)) {
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

  if (results.users.length > 0) {
    html += '<h4 class="admin-search-section-title">Utilizadores (' + results.users.length + ')</h4><ul class="admin-search-list">';
    results.users.slice(0, 5).forEach(user => {
      html += '<li class="admin-search-item">' + escapeHtml(user.name) + ' <span class="admin-search-email">' + escapeHtml(user.email) + '</span></li>';
    });
    html += '</ul>';
  }

  html += '</div>';
  container.innerHTML = html;
}

/**
 * Escape HTML to prevent XSS
 */
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
