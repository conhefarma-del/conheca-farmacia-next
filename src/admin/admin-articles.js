// src/admin/admin-articles.js
import { supabaseClient } from '../config.js';
import { checkAuth, logout, initIdleTimeout } from './lib/auth.js';
import { escapeHtml } from '../lib/security.js';
import { getAllArticles, deleteArticle as apiDeleteArticle, getTopArticlesByViews, getTopArticlesByShares, getTopArticlesByReadingTime } from '../lib/api.js';

const supabase = supabaseClient;

let allArticles = [];
let currentFilter = { status: 'all' };
let searchQuery = '';

// Logout
document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
  e.preventDefault();
  await logout();
});

// Load articles
async function loadArticles() {
  try {
    const articles = await getAllArticles();
    allArticles = articles || [];
    renderArticles();
    renderStats();
  } catch (error) {
    console.error('Erro ao carregar artigos:', error);
  }
}

// Render stats
function renderStats() {
  const total = allArticles.length;
  const published = allArticles.filter(a => a.status === 'published').length;
  const drafts = allArticles.filter(a => a.status === 'draft').length;

  document.getElementById('stat-total').textContent = total;
  document.getElementById('stat-published').textContent = published;
  document.getElementById('stat-drafts').textContent = drafts;
}

// Load analytics data for the top articles card
async function loadAnalytics(metric = 'views') {
  const list = document.getElementById('analytics-list');
  if (!list) return;

  list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">A carregar...</p>';

  try {
    let data = [];
    let valueKey = '';

    if (metric === 'views') {
      data = await getTopArticlesByViews(3);
      valueKey = 'view_count';
    } else if (metric === 'shares') {
      data = await getTopArticlesByShares(3);
      valueKey = 'share_count';
    } else if (metric === 'reading') {
      data = await getTopArticlesByReadingTime(3);
      valueKey = 'total_reading_time';
    }

    if (!data || data.length === 0) {
      list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">Sem dados ainda</p>';
      return;
    }

    list.innerHTML = data.map((article, i) => {
      let value = article[valueKey] || 0;
      let suffix = '';

      if (metric === 'reading') {
        if (value >= 3600) {
          suffix = `${Math.floor(value / 3600)}h ${Math.floor((value % 3600) / 60)}m`;
        } else if (value >= 60) {
          suffix = `${Math.floor(value / 60)}m ${value % 60}s`;
        } else {
          suffix = `${value}s`;
        }
      } else {
        suffix = value.toString();
      }

      return `
        <div class="admin-analytics-item">
          <span class="admin-analytics-rank">${i + 1}</span>
          <span class="admin-analytics-title">${escapeHtml(article.title)}</span>
          <span class="admin-analytics-value">${suffix}</span>
        </div>
      `;
    }).join('');
  } catch (error) {
    console.error('Erro ao carregar analytics:', error);
    list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">Erro ao carregar</p>';
  }
}

// Initialize analytics filters
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

// Render articles list
function renderArticles() {
  const container = document.getElementById('articles-container');
  const articles = getFilteredArticles();

  if (!articles || articles.length === 0) {
    container.innerHTML = '<p class="admin-text-muted">Nenhum artigo encontrado</p>';
    return;
  }

  container.innerHTML = `
    <div class="admin-table-wrapper">
    <table class="admin-table">
      <thead>
        <tr>
          <th>Título</th>
          <th>Categoria</th>
          <th>Status</th>
          <th>Data</th>
          <th>Autor</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>
        ${articles.map(article => `
          <tr>
            <td>${escapeHtml(article.title)}</td>
            <td>${escapeHtml(article.category_label || article.category || '-')}</td>
            <td>
              <button
                onclick="toggleStatus('${article.id}', '${article.status}')"
                class="admin-status-badge ${article.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}"
                style="cursor: pointer; border: none;"
              >
                ${article.status === 'published' ? 'Publicado' : 'Rascunho'}
              </button>
            </td>
            <td>${formatDate(article.published_date)}</td>
            <td>${escapeHtml(article.author_name || '-')}</td>
            <td>
              <div class="admin-actions">
                <a href="./edit.html?id=${article.id}" class="admin-btn admin-btn-secondary">
                  <i data-lucide="pencil"></i>
                  Editar
                </a>
                <button onclick="deleteArticle('${article.id}', '${escapeHtml(article.title)}')" class="admin-btn admin-btn-danger">
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

// Filter articles
function getFilteredArticles() {
  return allArticles.filter(article => {
    // Status filter
    if (currentFilter.status !== 'all' && article.status !== currentFilter.status) return false;

    // Search filter
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      const title = (article.title || '').toLowerCase();
      const excerpt = (article.excerpt || '').toLowerCase();
      const category = (article.category_label || article.category || '').toLowerCase();
      const author = (article.author_name || '').toLowerCase();

      if (!title.includes(q) && !excerpt.includes(q) && !category.includes(q) && !author.includes(q)) {
        return false;
      }
    }

    return true;
  });
}

// Toggle status
window.toggleStatus = async function(id, currentStatus) {
  const newStatus = currentStatus === 'published' ? 'draft' : 'published';

  if (!confirm(`Alterar status para "${newStatus === 'published' ? 'Publicado' : 'Rascunho'}"?`)) return;

  try {
    const { error } = await supabase
      .from('articles')
      .update({ status: newStatus })
      .eq('id', id);

    if (error) throw error;

    loadArticles();
  } catch (error) {
    alert('Erro ao alterar status: ' + error.message);
  }
};

// Delete article
window.deleteArticle = async function(id, title) {
  if (!confirm(`Tem certeza que deseja excluir o artigo "${title}"?`)) return;

  try {
    const error = await apiDeleteArticle(id);
    if (error) throw error;

    loadArticles();
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
      renderArticles();
    }, 300);
  });
}

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  const isAuth = await checkAuth();
  if (isAuth) {
    initIdleTimeout();
    loadArticles();
    initSearch();
    initAnalyticsFilters();
    loadAnalytics('views');
  }
});
