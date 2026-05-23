// src/admin/admin-lives.js
import { supabaseClient } from '../config.js';
import { checkAuth, logout, initIdleTimeout } from './lib/auth.js';
import { escapeHtml } from '../lib/security.js';
import { getAllLives, deleteLive as apiDeleteLive, getTopLivesByViews, getTopLivesByAccess, getTopLivesByDownloads, getUpcomingLives } from '../lib/api.js';

const supabase = supabaseClient;

let allLives = [];
let searchQuery = '';
let sortField = 'date-desc';
let statusFilter = 'all';
let timeFilter = 'all';

// Logout
document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
  e.preventDefault();
  await logout();
});

// Load lives
async function loadLives() {
  try {
    const lives = await getAllLives();
    allLives = lives || [];
    renderLives();
    renderStats();
  } catch (error) {
    console.error('Erro ao carregar lives:', error);
  }
}

// Render stats
function renderStats() {
  const total = allLives.length;
  const published = allLives.filter(l => l.status === 'published').length;
  const drafts = allLives.filter(l => l.status === 'draft').length;

  document.getElementById('stat-total').textContent = total;
  document.getElementById('stat-published').textContent = published;
  document.getElementById('stat-drafts').textContent = drafts;
}

// Filter lives
function getFilteredLives() {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  let filtered = allLives.filter(live => {
    // Status filter
    if (statusFilter !== 'all' && live.status !== statusFilter) return false;

    // Time filter
    if (timeFilter !== 'all') {
      const liveDate = new Date(live.date);
      if (timeFilter === 'upcoming' && liveDate < today) return false;
      if (timeFilter === 'past' && liveDate >= today) return false;
    }

    // Search filter
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      const title = (live.title || '').toLowerCase();
      const resumo = (live.resumo || '').toLowerCase();
      const category = (live.category_label || live.category || live.categoria || '').toLowerCase();
      return title.includes(q) || resumo.includes(q) || category.includes(q);
    }

    return true;
  });

  // Sort
  filtered.sort((a, b) => {
    switch (sortField) {
      case 'date-asc': return new Date(a.date || 0) - new Date(b.date || 0);
      case 'date-desc': return new Date(b.date || 0) - new Date(a.date || 0);
      case 'title-asc': return (a.title || '').localeCompare(b.title || '', 'pt');
      case 'title-desc': return (b.title || '').localeCompare(a.title || '', 'pt');
      default: return 0;
    }
  });

  return filtered;
}

// List filters
function initListFilters() {
  const sortSelect = document.getElementById('sort-select');
  const statusSelect = document.getElementById('status-filter');
  const timeSelect = document.getElementById('time-filter');

  sortSelect?.addEventListener('change', (e) => {
    sortField = e.target.value;
    renderLives();
  });

  statusSelect?.addEventListener('change', (e) => {
    statusFilter = e.target.value;
    renderLives();
  });

  timeSelect?.addEventListener('change', (e) => {
    timeFilter = e.target.value;
    renderLives();
  });
}

// Render lives list
function renderLives() {
  const container = document.getElementById('lives-container');
  const lives = getFilteredLives();

  if (!lives || lives.length === 0) {
    container.innerHTML = '<p class="admin-text-muted">Nenhuma live encontrada</p>';
    return;
  }

  container.innerHTML = `
    <div class="admin-table-wrapper">
    <table class="admin-table">
      <thead>
        <tr>
          <th>Título</th>
          <th>Categoria</th>
          <th>Data</th>
          <th>Plataforma</th>
          <th>Status</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>
        ${lives.map(live => `
          <tr>
            <td>${escapeHtml(live.title)}</td>
            <td>${escapeHtml(live.category_label || live.category || '-')}</td>
            <td>${formatDate(live.date)}</td>
            <td>${escapeHtml(live.platform || '-')}</td>
            <td>
              <span class="admin-status-badge ${live.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}">
                ${live.status === 'published' ? 'Publicado' : 'Rascunho'}
              </span>
            </td>
            <td>
              <div class="admin-actions">
                <a href="./edit.html?id=${live.id}" class="admin-btn admin-btn-secondary">
                  <i data-lucide="pencil"></i>
                  Editar
                </a>
                <button onclick="deleteLive('${live.id}', '${escapeHtml(live.title)}')" class="admin-btn admin-btn-danger">
                  <i data-lucide="trash-2"></i>
                  Excluir
                </button>
              </div>
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
    </div>
  `;
  if (typeof lucide !== 'undefined') {
    lucide.createIcons();
  }
}

// Delete live
window.deleteLive = async function(id, title) {
  if (!confirm(`Tem certeza que deseja excluir a live "${title}"?`)) return;

  try {
    const error = await apiDeleteLive(id);
    if (error) throw error;

    loadLives();
  } catch (error) {
    alert('Erro ao excluir: ' + error.message);
  }
};


function formatDate(dateStr) {
  if (!dateStr) return '-';
  const date = new Date(dateStr);
  return date.toLocaleDateString('pt-PT');
}

// Search with debounce
let searchDebounce;
function initSearch() {
  const searchInput = document.getElementById('admin-search-input');
  if (!searchInput) return;

  searchInput.addEventListener('input', (e) => {
    clearTimeout(searchDebounce);
    searchDebounce = setTimeout(() => {
      searchQuery = e.target.value.trim();
      renderLives();
    }, 300);
  });
}

// Analytics
async function loadAnalytics(metric = 'views') {
  const list = document.getElementById('analytics-list');
  if (!list) return;

  list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">A carregar...</p>';

  try {
    let data = [];
    let valueKey = '';

    if (metric === 'views') {
      data = await getTopLivesByViews(3);
      valueKey = 'view_count';
    } else if (metric === 'access') {
      data = await getTopLivesByAccess(3);
      valueKey = 'access_count';
    } else if (metric === 'downloads') {
      data = await getTopLivesByDownloads(3);
      valueKey = 'download_count';
    } else if (metric === 'upcoming') {
      data = await getUpcomingLives(3);
    }

    if (!data || data.length === 0) {
      list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">Sem dados ainda</p>';
      return;
    }

    list.innerHTML = data.map((live, i) => {
      let value = '';

      if (metric === 'upcoming') {
        const dateStr = live.date ? formatDate(live.date) : '-';
        const platform = live.platform ? ` · ${escapeHtml(live.platform)}` : '';
        value = `${dateStr}${platform}`;
      } else {
        value = (live[valueKey] || 0).toString();
      }

      return `
        <div class="admin-analytics-item">
          <span class="admin-analytics-rank">${i + 1}</span>
          <span class="admin-analytics-title">${escapeHtml(live.title)}</span>
          <span class="admin-analytics-value">${value}</span>
        </div>
      `;
    }).join('');
  } catch (error) {
    console.error('Erro ao carregar analytics:', error);
    list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">Erro ao carregar</p>';
  }
}

function initAnalyticsFilters() {
  const container = document.getElementById('analytics-filters');
  if (!container) return;

  container.addEventListener('click', (e) => {
    const btn = e.target.closest('.admin-analytics-filter');
    if (!btn) return;

    container.querySelectorAll('.admin-analytics-filter').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    loadAnalytics(btn.dataset.metric);
  });
}

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  const isAuth = await checkAuth();
  if (isAuth) {
    initIdleTimeout();
    loadLives();
    initSearch();
    initListFilters();
    initAnalyticsFilters();
    loadAnalytics('views');
  }
});
