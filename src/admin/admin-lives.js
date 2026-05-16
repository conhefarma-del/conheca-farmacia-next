// src/admin/admin-lives.js
import { supabaseClient } from '../config.js';
import { checkAuth } from './lib/auth.js';
import { logAudit } from './lib/audit-logger.js';

// Check authentication
await checkAuth();

let allLives = [];
let currentFilter = { status: 'all', category: 'all' };

// Load lives
async function loadLives() {
 const { data: lives, error } = await supabaseClient
 .from('lives')
 .select('*')
 .order('date', { ascending: false });

 if (error) {
 console.error('Erro ao carregar lives:', error);
 return;
 }

 allLives = lives || [];
 renderLives();
 setupFilters();
}

// Filter lives based on current filter
function getFilteredLives() {
 return allLives.filter(live => {
 const statusMatch = currentFilter.status === 'all' || live.status === currentFilter.status;
 const categoryMatch = currentFilter.category === 'all' || live.category === currentFilter.category;
 return statusMatch && categoryMatch;
 });
}

// Render lives table
function renderLives() {
 const tbody = document.getElementById('lives-table');
 const lives = getFilteredLives();

 if (!lives || lives.length === 0) {
 tbody.innerHTML = '<tr><td colspan="6">Nenhuma live encontrada</td></tr>';
 return;
 }

 tbody.innerHTML = lives.map(live => `
 <tr>
 <td>${escapeHtml(live.title)}</td>
 <td>${escapeHtml(live.category_label || live.category)}</td>
 <td>${formatDate(live.date)}</td>
 <td>${escapeHtml(live.platform || '-')}</td>
 <td>
 <span class="admin-badge admin-badge-${live.status}">
 ${live.status === 'published' ? 'Publicado' : 'Rascunho'}
 </span>
 </td>
 <td>
 <a href="/src/admin/lives/edit.html?id=${live.id}" class="admin-btn admin-btn-sm">Editar</a>
 </td>
 </tr>
 `).join('');
}

// Setup filters
function setupFilters() {
 const statusFilter = document.getElementById('filter-status');
 const categoryFilter = document.getElementById('filter-category');

 statusFilter?.addEventListener('change', (e) => {
 currentFilter.status = e.target.value;
 renderLives();
 });

 categoryFilter?.addEventListener('change', (e) => {
 currentFilter.category = e.target.value;
 renderLives();
 });
}

// Helper: Escape HTML
function escapeHtml(text) {
 if (!text) return '';
 const div = document.createElement('div');
 div.textContent = text;
 return div.innerHTML;
}

// Helper: Format date
function formatDate(dateString) {
 if (!dateString) return '-';
 const date = new Date(dateString);
 return date.toLocaleDateString('pt-PT', {
 day: '2-digit',
 month: '2-digit',
 year: 'numeric'
 });
}

// Initialize
loadLives();

// Logout handler
document.getElementById('logout-btn')?.addEventListener('click', (e) => {
 e.preventDefault();
 import('./lib/auth.js').then(({ logout }) => logout());
});
