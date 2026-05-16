// src/admin/admin-events.js
import { supabaseClient } from '../config.js';
import { checkAuth, logout } from './lib/auth.js';
import { logAudit } from './lib/audit-logger.js';

// Check authentication
await checkAuth();

let allEvents = [];
let currentFilter = { status: 'all', category: 'all' };

// Load events
async function loadEvents() {
 const { data: events, error } = await supabaseClient
 .from('events')
 .select('*')
 .order('date', { ascending: true });

 if (error) {
 console.error('Erro ao carregar eventos:', error);
 return;
 }

 allEvents = events || [];
 renderEvents();
 setupFilters();
}

// Filter events based on current filter
function getFilteredEvents() {
 return allEvents.filter(event => {
 const statusMatch = currentFilter.status === 'all' || event.status === currentFilter.status;
 const categoryMatch = currentFilter.category === 'all' || event.category === currentFilter.category;
 return statusMatch && categoryMatch;
 });
}

// Render events table
function renderEvents() {
 const tbody = document.getElementById('events-table');
 const events = getFilteredEvents();

 if (!events || events.length === 0) {
 tbody.innerHTML = '<tr><td colspan="6">Nenhum evento encontrado</td></tr>';
 return;
 }

 tbody.innerHTML = events.map(event => `
 <tr>
 <td>${escapeHtml(event.title)}</td>
 <td>${escapeHtml(event.category_label || event.category)}</td>
 <td>${formatDate(event.date)}</td>
 <td>${event.type === 'presencial' ? 'Presencial' : event.type === 'online' ? 'Online' : 'Híbrido'}</td>
 <td>
 <span class="admin-badge admin-badge-${event.status}">
 ${event.status === 'published' ? 'Publicado' : 'Rascunho'}
 </span>
 </td>
 <td>
 <a href="/src/admin/eventos/edit.html?id=${event.id}" class="admin-btn admin-btn-sm">
 Editar
 </a>
 <button onclick="deleteEvent('${event.id}', '${escapeHtml(event.title)}')" class="admin-btn admin-btn-sm admin-btn-danger">
 Excluir
 </button>
 </td>
 </tr>
 `).join('');
}

// Setup filter event listeners
function setupFilters() {
 const statusFilter = document.getElementById('filter-status');
 const categoryFilter = document.getElementById('filter-category');

 statusFilter?.addEventListener('change', (e) => {
 currentFilter.status = e.target.value;
 renderEvents();
 });

 categoryFilter?.addEventListener('change', (e) => {
 currentFilter.category = e.target.value;
 renderEvents();
 });

 // Logout handler
 document.getElementById('logout-btn')?.addEventListener('click', (e) => {
 e.preventDefault();
 logout();
 });
}

// Delete event
window.deleteEvent = async function(id, title) {
 if (!confirm(`Tem certeza que deseja excluir o evento "${title}"?`)) return;

 try {
 // Get event data before deletion for audit
 const { data: event } = await supabaseClient
 .from('events')
 .select('*')
 .eq('id', id)
 .single();

 const { error } = await supabaseClient
 .from('events')
 .delete()
 .eq('id', id);

 if (error) {
 alert('Erro ao excluir: ' + error.message);
 return;
 }

 // Log audit
 await logAudit('DELETE', 'events', id, event, null);

 // Reload list
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

// Initialize
loadEvents();
