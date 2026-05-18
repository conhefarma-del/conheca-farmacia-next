// src/admin/admin-lives.js
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
import { getAllLives, deleteLive as apiDeleteLive } from '../lib/api.js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://your-project.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'your-anon-key';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

let allLives = [];
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
  if (!searchQuery) return allLives;
  const q = searchQuery.toLowerCase();
  return allLives.filter(live => {
    const title = (live.title || '').toLowerCase();
    const resumo = (live.resumo || '').toLowerCase();
    const category = (live.category_label || live.category || live.categoria || '').toLowerCase();
    return title.includes(q) || resumo.includes(q) || category.includes(q);
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
                <a href="/src/admin/lives/edit.html?id=${live.id}" class="admin-btn admin-btn-secondary">
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
      renderLives();
    }, 300);
  });
}

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  const isAuth = await checkAuth();
  if (isAuth) {
    loadLives();
    initSearch();
  }
});
