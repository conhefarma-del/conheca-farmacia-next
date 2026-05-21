// src/admin/newsletter.js
import { checkAuth, logout, getAdminProfile, updateTopBar, initIdleTimeout } from './lib/auth.js';
import { escapeHtml } from '../lib/security.js';
import { supabaseClient } from '../config.js';
import { getNewsletterSubscribers, sendContentAlert, unsubscribeById, deleteSubscriber, reactivateSubscriber } from '../lib/newsletter.js';
import { getArticles, getEvents, getLives } from '../lib/api.js';

let allSubscribers = [];
let currentFilter = 'all';
let selectedEmails = new Set();

// Format date for display
function formatDate(dateStr) {
  if (!dateStr) return '-';
  const date = new Date(dateStr);
  return date.toLocaleDateString('pt-PT', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).toUpperCase();
}

// Update stats cards
function updateStats(subscribers) {
  const total = subscribers.length;
  const active = subscribers.filter(s => s.status === 'active').length;
  const unsubscribed = subscribers.filter(s => s.status === 'unsubscribed').length;

  document.getElementById('stat-total').textContent = total;
  document.getElementById('stat-active').textContent = active;
  document.getElementById('stat-unsubscribed').textContent = unsubscribed;
}

// Get send mode
function getSendMode() {
  const checked = document.querySelector('input[name="send-mode"]:checked');
  return checked ? checked.value : 'all';
}

// Get selected emails for sending
function getTargetEmails() {
  const mode = getSendMode();
  const activeSubs = allSubscribers.filter(s => s.status === 'active');

  if (mode === 'all') return null; // null = send to all active
  if (mode === 'manual') return [...selectedEmails];
  if (mode === 'random') {
    const count = Math.min(parseInt(document.getElementById('random-count').value) || 10, activeSubs.length);
    const shuffled = [...activeSubs].sort(() => Math.random() - 0.5);
    return shuffled.slice(0, count).map(s => s.email);
  }
  return null;
}

// Render subscribers table
function renderSubscribers(subscribers) {
  const container = document.getElementById('subscribers-container');
  const mode = getSendMode();

  const filtered = currentFilter === 'all'
    ? subscribers
    : subscribers.filter(s => s.status === currentFilter);

  if (filtered.length === 0) {
    container.innerHTML = '<p class="admin-text-muted">Nenhum subscritor encontrado.</p>';
    return;
  }

  const showCheckbox = mode === 'manual';

  container.innerHTML = `
    <table class="admin-table" style="width: 100%; border-collapse: collapse;">
      <thead>
        <tr style="border-bottom: 1px solid var(--admin-border);">
          ${showCheckbox ? '<th style="width: 40px; padding: 12px 8px; text-align: center;"><input type="checkbox" id="select-all-checkbox" title="Selecionar todos" style="cursor: pointer;"></th>' : ''}
          <th style="text-align: left; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--admin-text-muted);">Email</th>
          <th style="text-align: left; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--admin-text-muted);">Estado</th>
          <th style="text-align: left; padding: 12px 16px; font-size: 13px; font-weight: 600; color: var(--admin-text-muted);">Data</th>
          <th style="width: 50px; padding: 12px 16px;"></th>
        </tr>
      </thead>
      <tbody>
        ${filtered.map(sub => `
          <tr style="border-bottom: 1px solid var(--admin-border);">
            ${showCheckbox ? `<td style="padding: 12px 8px; text-align: center;"><input type="checkbox" class="sub-checkbox" data-email="${escapeHtml(sub.email)}" ${selectedEmails.has(sub.email) ? 'checked' : ''} style="cursor: pointer;"></td>` : ''}
            <td style="padding: 12px 16px; font-size: 14px; color: var(--admin-text);">${escapeHtml(sub.email)}</td>
            <td style="padding: 12px 16px;">
              <span style="display: inline-block; padding: 4px 10px; border-radius: 12px; font-size: 12px; font-weight: 600;
                ${sub.status === 'active'
                  ? 'background: #dcfce7; color: #166534;'
                  : 'background: #fee2e2; color: #991b1b;'
                }">
                ${sub.status === 'active' ? 'Ativo' : 'Cancelado'}
              </span>
            </td>
            <td style="padding: 12px 16px; font-size: 13px; color: var(--admin-text-muted);">${formatDate(sub.created_at)}</td>
            <td style="padding: 12px 16px; text-align: center;">
              ${sub.status === 'unsubscribed' ? `
                <button class="reactivate-sub-btn" data-id="${sub.id}" data-email="${escapeHtml(sub.email)}" title="Reativar subscrição" style="background: none; border: none; cursor: pointer; color: #16a34a; padding: 4px; border-radius: 4px; display: inline-flex; align-items: center;">
                  <i data-lucide="rotate-ccw" style="width: 16px; height: 16px;"></i>
                </button>
              ` : `
                <button class="remove-sub-btn" data-id="${sub.id}" data-email="${escapeHtml(sub.email)}" title="Remover subscritor" style="background: none; border: none; cursor: pointer; color: var(--admin-text-muted); padding: 4px; border-radius: 4px; display: inline-flex; align-items: center;">
                  <i data-lucide="trash-2" style="width: 16px; height: 16px;"></i>
                </button>
              `}
            </td>
          </tr>
        `).join('')}
      </tbody>
    </table>
  `;

  // Re-render Lucide icons
  if (typeof lucide !== 'undefined') lucide.createIcons();

  // Setup checkbox events
  if (showCheckbox) {
    const selectAll = document.getElementById('select-all-checkbox');
    selectAll?.addEventListener('change', (e) => {
      document.querySelectorAll('.sub-checkbox').forEach(cb => {
        cb.checked = e.target.checked;
        const email = cb.dataset.email;
        if (e.target.checked) selectedEmails.add(email);
        else selectedEmails.delete(email);
      });
    });

    document.querySelectorAll('.sub-checkbox').forEach(cb => {
      cb.addEventListener('change', (e) => {
        const email = e.target.dataset.email;
        if (e.target.checked) selectedEmails.add(email);
        else selectedEmails.delete(email);
      });
    });
  }

  // Setup remove buttons
  document.querySelectorAll('.remove-sub-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      openRemoveModal(btn.dataset.id, btn.dataset.email);
    });
  });

  // Setup reactivate buttons
  document.querySelectorAll('.reactivate-sub-btn').forEach(btn => {
    btn.addEventListener('click', async () => {
      const result = await reactivateSubscriber(btn.dataset.id);
      if (result.success) {
        allSubscribers = await getNewsletterSubscribers();
        updateStats(allSubscribers);
        renderSubscribers(allSubscribers);
      }
    });
  });
}

// Load content dropdown for alert form
async function loadContentOptions() {
  const typeSelect = document.getElementById('alert-type');
  const contentSelect = document.getElementById('alert-content');

  async function refreshOptions() {
    const type = typeSelect.value;
    contentSelect.innerHTML = '<option value="">A carregar...</option>';

    try {
      let items = [];

      if (type === 'article') {
        items = await getArticles();
      } else if (type === 'event') {
        items = await getEvents();
      } else if (type === 'live') {
        items = await getLives();
      }

      if (items.length === 0) {
        contentSelect.innerHTML = '<option value="">Nenhum conteúdo encontrado</option>';
        return;
      }

      contentSelect.innerHTML =
        '<option value="">Selecionar conteúdo...</option>' +
        items.map(item => {
          const title = item.title || item.titulo || 'Sem título';
          const slug = item.slug || item.id;
          const date = item.date || '';
          const platform = item.platform || '';
          const location = item.location || '';
          const description = item.description || item.excerpt || '';
          return `<option value="${escapeHtml(slug)}" data-title="${escapeHtml(title)}" data-date="${escapeHtml(date)}" data-platform="${escapeHtml(platform)}" data-location="${escapeHtml(location)}" data-description="${escapeHtml(description)}">${escapeHtml(title)}</option>`;
        }).join('');
    } catch (err) {
      contentSelect.innerHTML = '<option value="">Erro ao carregar</option>';
    }
  }

  typeSelect.addEventListener('change', refreshOptions);
  await refreshOptions();
}

// Handle alert form submission
function setupAlertForm() {
  const form = document.getElementById('send-alert-form');
  const statusDiv = document.getElementById('send-alert-status');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const type = document.getElementById('alert-type').value;
    const contentSelect = document.getElementById('alert-content');
    const selectedOption = contentSelect.options[contentSelect.selectedIndex];

    if (!selectedOption || !selectedOption.value) {
      statusDiv.style.display = 'block';
      statusDiv.style.color = '#dc2626';
      statusDiv.textContent = 'Selecione um conteúdo.';
      return;
    }

    const btn = document.getElementById('send-alert-btn');
    btn.disabled = true;
    btn.innerHTML = '<i data-lucide="loader"></i> A enviar...';
    if (typeof lucide !== 'undefined') lucide.createIcons();

    statusDiv.style.display = 'block';
    statusDiv.style.color = 'var(--admin-text-muted)';
    statusDiv.textContent = 'A enviar alertas...';

    try {
      const title = selectedOption.dataset.title || selectedOption.textContent;
      const slug = selectedOption.value;

      // Build URL based on content type
      let url = '';
      if (type === 'article') url = `https://conhecafarmacia.netlify.app/artigo.html?id=${slug}`;
      else if (type === 'event') url = `https://conhecafarmacia.netlify.app/evento.html?id=${slug}`;
      else if (type === 'live') url = `https://conhecafarmacia.netlify.app/lives.html?id=${slug}`;

      const targetEmails = getTargetEmails();
      const result = await sendContentAlert(type, {
        title,
        url,
        description: selectedOption.dataset.description || '',
        date: selectedOption.dataset.date || '',
        platform: selectedOption.dataset.platform || '',
        location: selectedOption.dataset.location || '',
      }, targetEmails);

      if (result.success) {
        statusDiv.style.color = '#166534';
        const mode = getSendMode();
        const modeLabel = mode === 'manual' ? ' (selecionados)' : mode === 'random' ? ' (aleatório)' : '';
        statusDiv.textContent = `Alerta enviado com sucesso para ${result.sent} de ${result.total} subscritores${modeLabel}.`;
      } else {
        statusDiv.style.color = '#dc2626';
        statusDiv.textContent = result.error || 'Erro ao enviar alertas.';
      }
    } catch (err) {
      statusDiv.style.color = '#dc2626';
      statusDiv.textContent = 'Erro ao enviar alertas.';
    } finally {
      btn.disabled = false;
      btn.innerHTML = '<i data-lucide="send"></i> Enviar Alerta';
      if (typeof lucide !== 'undefined') lucide.createIcons();
    }
  });
}

// Setup filter buttons
function setupFilters() {
  const filterBtns = document.querySelectorAll('.filter-btn');

  filterBtns.forEach(btn => {
    btn.addEventListener('click', () => {
      filterBtns.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      currentFilter = btn.dataset.status;
      renderSubscribers(allSubscribers);
    });
  });
}

// Setup search
function setupSearch() {
  const searchInput = document.getElementById('admin-search-input');
  let debounceTimer;

  searchInput.addEventListener('input', (e) => {
    clearTimeout(debounceTimer);
    debounceTimer = setTimeout(() => {
      const query = e.target.value.toLowerCase().trim();

      if (!query) {
        renderSubscribers(allSubscribers);
        return;
      }

      const filtered = allSubscribers.filter(sub =>
        sub.email.toLowerCase().includes(query)
      );
      renderSubscribers(filtered);
    }, 300);
  });
}

// Remove subscriber modal
let pendingRemoveId = null;

function openRemoveModal(id, email) {
  pendingRemoveId = id;
  document.getElementById('remove-modal-email').textContent = email;
  const modal = document.getElementById('remove-modal');
  modal.style.display = 'flex';
}

function closeRemoveModal() {
  pendingRemoveId = null;
  document.getElementById('remove-modal').style.display = 'none';
}

function setupRemoveModal() {
  const modal = document.getElementById('remove-modal');

  document.getElementById('modal-cancel').addEventListener('click', closeRemoveModal);

  modal.addEventListener('click', (e) => {
    if (e.target === modal) closeRemoveModal();
  });

  document.getElementById('modal-unsub').addEventListener('click', async () => {
    if (!pendingRemoveId) return;
    const result = await unsubscribeById(pendingRemoveId);
    if (result.success) {
      allSubscribers = await getNewsletterSubscribers();
      updateStats(allSubscribers);
      renderSubscribers(allSubscribers);
    }
    closeRemoveModal();
  });

  document.getElementById('modal-delete').addEventListener('click', async () => {
    if (!pendingRemoveId) return;
    const result = await deleteSubscriber(pendingRemoveId);
    if (result.success) {
      allSubscribers = await getNewsletterSubscribers();
      updateStats(allSubscribers);
      renderSubscribers(allSubscribers);
    }
    closeRemoveModal();
  });
}

// Setup send mode radios
function setupSendMode() {
  const radios = document.querySelectorAll('input[name="send-mode"]');
  const randomWrapper = document.getElementById('random-count-wrapper');

  radios.forEach(radio => {
    radio.addEventListener('change', () => {
      randomWrapper.style.display = radio.value === 'random' && radio.checked ? 'flex' : 'none';
      selectedEmails.clear();
      renderSubscribers(allSubscribers);
    });
  });
}

// Initialize
document.addEventListener('DOMContentLoaded', async () => {
  try {
    await checkAuth();
    initIdleTimeout();

    const profile = await getAdminProfile();
    if (profile) updateTopBar(profile);

    // Logout handler
    document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
      e.preventDefault();
      await logout();
    });

    // Load subscribers
    allSubscribers = await getNewsletterSubscribers();
    updateStats(allSubscribers);
    renderSubscribers(allSubscribers);

    // Load sent count (placeholder — would need a dedicated API)
    document.getElementById('stat-sent').textContent = '-';

    // Setup interactions
    setupFilters();
    setupSearch();
    setupAlertForm();
    setupRemoveModal();
    setupSendMode();
    await loadContentOptions();

    // Re-render Lucide icons
    if (typeof lucide !== 'undefined') {
      lucide.createIcons();
    }
  } catch (err) {
    console.error('Newsletter admin error:', err);
  }
});
