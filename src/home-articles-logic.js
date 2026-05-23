import { getFeaturedArticles } from './lib/api.js';
import { escapeHtml } from './lib/security.js';
import { logger } from './lib/logger.js';

const categoryColors = {
  profissionais: "#ff6c23",
  "voce-sabia": "#0a844f",
  "conheca-medicamento": "#7c3aed",
  curiosidades: "#002a32",
  saude: "#006171",
  legislacao: "#ff4d4d",
};

function renderFeaturedArticles(articles, container) {
  if (!container) return;
  container.innerHTML = '';

  if (articles.length === 0) {
    container.innerHTML = '<p class="text-center text-brand-deep/60 col-span-full">Nenhum artigo em destaque no momento.</p>';
    return;
  }

  articles.forEach((article) => {
    const color = categoryColors[article.category] || '#00493a';
    const card = document.createElement('article');
    card.className = 'article-card border border-brand-divider/10';
    card.innerHTML = `
      <img src="${escapeHtml(article.image)}" alt="${escapeHtml(article.title)}" class="article-card-img" loading="lazy" decoding="async">
      <div class="article-card-content">
        <span class="article-tag" style="background-color: ${color}20; color: ${color}; border: 1px solid ${color}40">${escapeHtml(article.categoryLabel)}</span>
        <h3 class="article-card-title">${escapeHtml(article.title)}</h3>
        <p class="article-card-excerpt">${escapeHtml(article.excerpt)}</p>
        <a href="artigo.html?id=${encodeURIComponent(article.slug)}" class="article-card-link" aria-label="Ler artigo: ${escapeHtml(article.title)}">Ler mais <span>→</span></a>
      </div>
    `;
    container.appendChild(card);
  });
}

async function initHomeArticles() {
  const container = document.getElementById('home-articles-grid');
  if (!container) return;

  logger.log('🏠 Home Articles: Carregando destaques...');
  const articles = await getFeaturedArticles(3);
  logger.log(`📰 Artigos em destaque: ${articles.length}`);
  renderFeaturedArticles(articles, container);
}

document.addEventListener('DOMContentLoaded', initHomeArticles);
