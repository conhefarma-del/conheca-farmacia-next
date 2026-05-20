// src/admin/admin-events.js
import { supabaseClient } from '../config.js';
import { checkAuth, logout, initIdleTimeout } from './lib/auth.js';
import { escapeHtml } from '../lib/security.js';
import { getAllEvents, deleteEvent as apiDeleteEvent, getTopEventsByViews, getTopEventsByFillRate, getUpcomingEvents } from '../lib/api.js';

const supabase = supabaseClient;

let allEvents = [];
let searchQuery = '';

// Logout
document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
  e.preventDefault();
  await logout();
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
                <a href="./edit.html?id=${event.id}" class="admin-btn admin-btn-secondary">
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

// Analytics
async function loadAnalytics(metric = 'views') {
  const list = document.getElementById('analytics-list');
  if (!list) return;

  list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">A carregar...</p>';

  try {
    let data = [];

    if (metric === 'views') {
      data = await getTopEventsByViews(3);
    } else if (metric === 'fill') {
      data = await getTopEventsByFillRate(3);
    } else if (metric === 'upcoming') {
      data = await getUpcomingEvents(3);
    }

    if (!data || data.length === 0) {
      list.innerHTML = '<p style="color: var(--admin-text-muted); font-size: 13px;">Sem dados ainda</p>';
      return;
    }

    list.innerHTML = data.map((event, i) => {
      let value = '';

      if (metric === 'views') {
        value = (event.view_count || 0).toString();
      } else if (metric === 'fill') {
        value = `${event.fill_rate || 0}%`;
      } else if (metric === 'upcoming') {
        const dateStr = event.date ? formatDate(event.date) : '-';
        const location = event.location ? ` · ${escapeHtml(event.location)}` : '';
        value = `${dateStr}${location}`;
      }

      return `
        <div class="admin-analytics-item">
          <span class="admin-analytics-rank">${i + 1}</span>
          <span class="admin-analytics-title">${escapeHtml(event.title)}</span>
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
    loadEvents();
    initSearch();
    initAnalyticsFilters();
    loadAnalytics('views');
  }
});
