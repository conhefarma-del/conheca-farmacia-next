// src/admin/lib/preview.js
// Módulo de pré-visualização de artigos para o admin
import { escapeHtml } from '../../lib/security.js';

let markedLoaded = false;
let dompurifyLoaded = false;
let overlayCreated = false;

/**
 * Carrega marked.js e DOMPurify via CDN (lazy)
 */
async function ensureLibraries() {
  if (!markedLoaded) {
    await new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/marked/marked.min.js';
      script.onload = () => { markedLoaded = true; resolve(); };
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }
  if (!dompurifyLoaded) {
    await new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/npm/dompurify@3.0.6/dist/purify.min.js';
      script.onload = () => { dompurifyLoaded = true; resolve(); };
      script.onerror = reject;
      document.head.appendChild(script);
    });
  }
}

/**
 * Cria o overlay de preview se ainda não existir
 */
function createOverlay() {
  if (overlayCreated) return;
  overlayCreated = true;

  const overlay = document.createElement('div');
  overlay.id = 'preview-overlay';
  overlay.className = 'admin-editor-overlay';
  overlay.innerHTML = `
    <div class="admin-preview-content">
      <div class="admin-preview-header">
        <span class="admin-preview-title">Pré-visualização</span>
        <button class="admin-editor-close" id="preview-close-btn" aria-label="Fechar preview">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="6" x2="6" y2="18"></line>
            <line x1="6" y1="6" x2="18" y2="18"></line>
          </svg>
        </button>
      </div>
      <div class="admin-preview-body" id="preview-body"></div>
    </div>
  `;
  document.body.appendChild(overlay);

  // Fechar ao clicar no backdrop
  overlay.addEventListener('click', (e) => {
    if (e.target === overlay) closePreview();
  });

  // Fechar com Escape
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && overlay.classList.contains('active')) {
      closePreview();
    }
  });

  // Fechar com botão
  document.getElementById('preview-close-btn').addEventListener('click', closePreview);
}

/**
 * Formata data para formato português
 */
function formatDate(dateStr) {
  if (!dateStr) return '';
  const date = new Date(dateStr + 'T00:00:00');
  return date.toLocaleDateString('pt-PT', { year: 'numeric', month: 'long', day: 'numeric' });
}


/**
 * Gera o HTML do preview a partir dos dados do formulário
 */
function generatePreviewHTML(data) {
  const categoryLabel = escapeHtml(data.categoryLabel || data.category || '');
  const title = escapeHtml(data.title || 'Sem título');
  const imageSrc = data.imageUrl || '';
  const date = formatDate(data.publishedDate);
  const authorName = escapeHtml(data.authorName || '');
  const authorRole = escapeHtml(data.authorRole || '');
  const readTime = data.readTime ? `${data.readTime} min de leitura` : '';
  const excerpt = escapeHtml(data.excerpt || '');

  // Renderizar markdown
  let bodyHTML = '';
  if (data.content) {
    const rawHTML = marked.parse(data.content);
    bodyHTML = DOMPurify.sanitize(rawHTML, {
      ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br', 'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'ul', 'ol', 'li', 'blockquote', 'code', 'pre', 'a', 'img', 'table', 'thead', 'tbody', 'tr', 'th', 'td'],
      ALLOWED_ATTR: ['href', 'src', 'alt', 'title', 'target']
    });
  }

  return `
    <div class="preview-hero">
      ${categoryLabel ? `<span class="preview-category-badge">${categoryLabel}</span>` : ''}
      <h1 class="preview-hero-title">${title}</h1>
      ${imageSrc ? `<img src="${imageSrc}" alt="${title}" class="preview-featured-image" onerror="this.style.display='none'">` : ''}
      ${authorName || date || readTime ? `
        <div class="preview-meta-bar">
          <div class="preview-author">
            <div class="preview-author-avatar">${authorName ? authorName.charAt(0).toUpperCase() : '?'}</div>
            <div>
              ${authorName ? `<div class="preview-author-name">${authorName}</div>` : ''}
              ${authorRole ? `<div class="preview-author-role">${authorRole}</div>` : ''}
            </div>
          </div>
          <div class="preview-meta-info">
            ${date ? `<span>${date}</span>` : ''}
            ${readTime ? `<span>${readTime}</span>` : ''}
          </div>
        </div>
      ` : ''}
    </div>
    ${excerpt ? `<div class="preview-excerpt">${excerpt}</div>` : ''}
    <div class="preview-article-body">${bodyHTML}</div>
  `;
}

/**
 * Abre o preview com os dados do formulário
 * @param {Object} formData - { title, content, category, categoryLabel, imageUrl, publishedDate, authorName, authorRole, readTime, excerpt }
 */
export async function openPreview(formData) {
  try {
    await ensureLibraries();
    createOverlay();

    const html = generatePreviewHTML(formData);
    document.getElementById('preview-body').innerHTML = html;

    const overlay = document.getElementById('preview-overlay');
    overlay.classList.add('active');
    document.body.style.overflow = 'hidden';
  } catch (error) {
    console.error('Erro ao abrir preview:', error);
    alert('Erro ao carregar preview. Verifique a consola.');
  }
}

/**
 * Fecha o preview
 */
export function closePreview() {
  const overlay = document.getElementById('preview-overlay');
  if (overlay) {
    overlay.classList.remove('active');
    document.body.style.overflow = '';
  }
}
