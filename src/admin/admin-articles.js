// src/admin/admin-articles.js
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
import { getAllArticles, deleteArticle as apiDeleteArticle } from '../lib/api.js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://your-project.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'your-anon-key';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

let allArticles = [];
let currentFilter = { status: 'all' };
let searchQuery = '';

// Verificar autenticação
async function checkAuth() {
  const { data: { session } } = await supabase.auth.getSession();

  if (!session) {
    window.location.href = '/src/admin/index.html';
    return false;
  }

  return true;
}

// Logout
document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
  e.preventDefault();
  await supabase.auth.signOut();
  window.location.href = '/src/admin/index.html';
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
                <a href="/src/admin/artigos/edit.html?id=${article.id}" class="admin-btn admin-btn-secondary">
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

// Helper functions
function escapeHtml(text) {
  if (!text) return '';
  return text.replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}

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
    loadArticles();
    initSearch();
  }
});
