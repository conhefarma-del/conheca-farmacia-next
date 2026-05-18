// src/admin/admin-events.js
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
import { getAllEvents, deleteEvent as apiDeleteEvent } from '../lib/api.js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://your-project.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'your-anon-key';
const supabase = createClient(supabaseUrl, supabaseAnonKey);

let allEvents = [];
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

// Load events
async function loadEvents() {
  try {
    const events = await getAllEvents();
    allEvents = events || [];
    renderEvents();
    renderStats();
  } catch (error) {
    console.error('Erro ao carregar eventos:', error);
  }
}

// Render stats
function renderStats() {
  const total = allEvents.length;
  const published = allEvents.filter(e => e.status === 'published').length;
  const drafts = allEvents.filter(e => e.status === 'draft').length;

  document.getElementById('stat-total').textContent = total;
  document.getElementById('stat-published').textContent = published;
  document.getElementById('stat-drafts').textContent = drafts;
}

// Filter events
function getFilteredEvents() {
  if (!searchQuery) return allEvents;
  const q = searchQuery.toLowerCase();
  return allEvents.filter(event => {
    const title = (event.title || '').toLowerCase();
    const excerpt = (event.excerpt || '').toLowerCase();
    const category = (event.category_label || event.category || '').toLowerCase();
    return title.includes(q) || excerpt.includes(q) || category.includes(q);
  });
}

// Render events list
function renderEvents() {
  const container = document.getElementById('events-container');
  const events = getFilteredEvents();

  if (!events || events.length === 0) {
    container.innerHTML = '<p class="admin-text-muted">Nenhum evento encontrado</p>';
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
          <th>Tipo</th>
          <th>Status</th>
          <th>Ações</th>
        </tr>
      </thead>
      <tbody>
        ${events.map(event => `
          <tr>
            <td>${escapeHtml(event.title)}</td>
            <td>${escapeHtml(event.category_label || event.category || '-')}</td>
            <td>${formatDate(event.date)}</td>
            <td>${event.type === 'presencial' ? 'Presencial' : event.type === 'online' ? 'Online' : 'Híbrido'}</td>
            <td>
              <span class="admin-status-badge ${event.status === 'published' ? 'admin-status-published' : 'admin-status-draft'}">
                ${event.status === 'published' ? 'Publicado' : 'Rascunho'}
              </span>
            </td>
            <td>
              <div class="admin-actions">
                <a href="/src/admin/eventos/edit.html?id=${event.id}" class="admin-btn admin-btn-secondary">
                  <i data-lucide="pencil"></i>
                  Editar
                </a>
                <button onclick="deleteEvent('${event.id}', '${escapeHtml(event.title)}')" class="admin-btn admin-btn-danger">
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

// Delete event
window.deleteEvent = async function(id, title) {
  if (!confirm(`Tem certeza que deseja excluir o evento "${title}"?`)) return;

  try {
    const error = await apiDeleteEvent(id);
    if (error) throw error;

    loadEvents();
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
      renderEvents();
    }, 300);
  });
}

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  const isAuth = await checkAuth();
  if (isAuth) {
    loadEvents();
    initSearch();
  }
});
