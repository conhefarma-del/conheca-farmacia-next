// src/admin/admin-articles.js
import { supabaseClient } from '../config.js';
import { checkAuth, logout } from './lib/auth.js';
import { logAudit } from './lib/audit-logger.js';

// Check authentication
await checkAuth();

let allArticles = [];
let currentFilter = { status: 'all', category: 'all' };

// Load articles
async function loadArticles() {
    const { data: articles, error } = await supabaseClient
        .from('articles')
        .select('*')
        .order('created_at', { ascending: false });

    if (error) {
        console.error('Erro ao carregar artigos:', error);
        return;
    }

    allArticles = articles || [];
    renderArticles();
    setupFilters();
}

// Filter articles based on current filter
function getFilteredArticles() {
    return allArticles.filter(article => {
        const statusMatch = currentFilter.status === 'all' || article.status === currentFilter.status;
        const categoryMatch = currentFilter.category === 'all' || article.category === currentFilter.category;
        return statusMatch && categoryMatch;
    });
}

// Toggle article status (draft/published)
window.toggleStatus = async function(id, currentStatus) {
    const newStatus = currentStatus === 'published' ? 'draft' : 'published';

    if (!confirm(`Alterar status para "${newStatus === 'published' ? 'Publicado' : 'Rascunho'}"?`)) return;

    try {
        const { error } = await supabaseClient
            .from('articles')
            .update({ status: newStatus })
            .eq('id', id);

        if (error) throw error;

        // Log audit
        await logAudit('UPDATE', 'articles', id, { status: currentStatus }, { status: newStatus });

        // Reload list
        loadArticles();
    } catch (error) {
        alert('Erro ao alterar status: ' + error.message);
    }
};

// Render articles table
function renderArticles() {
    const tbody = document.getElementById('articles-table');
    const articles = getFilteredArticles();

    if (!articles || articles.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6">Nenhum artigo encontrado</td></tr>';
        return;
    }

    tbody.innerHTML = articles.map(article => `
        <tr>
            <td>${escapeHtml(article.title)}</td>
            <td>${escapeHtml(article.category_label || article.category)}</td>
            <td>
                <button
                    onclick="toggleStatus('${article.id}', '${article.status}')"
                    class="admin-badge admin-badge-${article.status}"
                    style="cursor: pointer; border: none; padding: 4px 12px; border-radius: 999px; font-size: 14px; font-weight: 500;"
                >
                    ${article.status === 'published' ? 'Publicado' : 'Rascunho'}
                </button>
            </td>
            <td>${formatDate(article.published_date)}</td>
            <td>${escapeHtml(article.author_name || '-')}</td>
            <td>
                <a href="/src/admin/artigos/edit.html?id=${article.id}" class="admin-btn admin-btn-sm">
                    Editar
                </a>
                <button onclick="deleteArticle('${article.id}', '${escapeHtml(article.title)}')" class="admin-btn admin-btn-sm admin-btn-danger">
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
        renderArticles();
    });

    categoryFilter?.addEventListener('change', (e) => {
        currentFilter.category = e.target.value;
        renderArticles();
    });

    // Logout handler
    document.getElementById('logout-btn')?.addEventListener('click', (e) => {
        e.preventDefault();
        logout();
    });
}

// Delete article
window.deleteArticle = async function(id, title) {
    if (!confirm(`Tem certeza que deseja excluir o artigo "${title}"?`)) return;

    try {
        // Get article data before deletion for audit
        const { data: article } = await supabaseClient
            .from('articles')
            .select('*')
            .eq('id', id)
            .single();

        const { error } = await supabaseClient
            .from('articles')
            .delete()
            .eq('id', id);

        if (error) {
            alert('Erro ao excluir: ' + error.message);
            return;
        }

        // Log audit
        await logAudit('DELETE', 'articles', id, article, null);

        // Reload list
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

// Initialize
loadArticles();
