import { getArticles } from './lib/api.js';
import { escapeHtml } from './lib/security.js';
import { logger } from './lib/logger.js';
import { subscribeToNewsletter } from './lib/newsletter.js';

let articles = [];
let currentFilter = "all";
let searchTerm = "";

// Cores por categoria (mesmo padrão que events-logic.js)
const categoryColors = {
  profissionais: "#ff6c23",
  "voce-sabia": "#0a844f",
  "conheca-medicamento": "#7c3aed",
  curiosidades: "#002a32",
  saude: "#006171",
  legislacao: "#ff4d4d",
};

// Initialize after DOM loads
document.addEventListener("DOMContentLoaded", () => {
  const grid = document.getElementById("articles-grid");
  const noResults = document.getElementById("no-results");
  const searchInput = document.getElementById("search-input");
  const filterButtons = document.querySelectorAll(".filter-btn");

  function renderArticles() {
    logger.log("Renderizando artigos. Total:", articles.length);

    const filtered = articles.filter((article) => {
      const matchesFilter =
        currentFilter === "all" || article.category === currentFilter;
      const matchesSearch =
        article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.excerpt.toLowerCase().includes(searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    });

    logger.log("Artigos filtrados:", filtered.length);

    grid.innerHTML = "";

    if (filtered.length === 0) {
      noResults.classList.remove("hidden");
    } else {
      noResults.classList.add("hidden");
      filtered.forEach((article) => {
        const card = document.createElement("article");
        card.className =
          "article-card article-card-anim border border-brand-divider/10";
        card.innerHTML = `
          <img src="${escapeHtml(article.image)}" alt="${escapeHtml(article.title)}" class="article-card-img" loading="lazy" decoding="async">
          <div class="article-card-content">
            <span class="article-tag" style="background-color: ${categoryColors[article.category]}20; color: ${categoryColors[article.category]}; border: 1px solid ${categoryColors[article.category]}40">${escapeHtml(article.categoryLabel)}</span>
            <h3 class="article-card-title">${escapeHtml(article.title)}</h3>
            <p class="article-card-excerpt">${escapeHtml(article.excerpt)}</p>
            <a href="artigo.html?id=${encodeURIComponent(article.slug)}" class="article-card-link" aria-label="Ler artigo: ${escapeHtml(article.title)}">Ler mais <span>→</span></a>
          </div>
        `;
        grid.appendChild(card);
      });
    }
  }

  // Filter Click Event
  filterButtons.forEach((btn) => {
    btn.addEventListener("click", () => {
      filterButtons.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentFilter = btn.dataset.filter;
      renderArticles();
    });
  });

  // Search Input Event
  searchInput.addEventListener("input", (e) => {
    searchTerm = e.target.value;
    renderArticles();
  });

   // Load articles from Supabase (with JSON fallback)
  (async () => {
    articles = await getArticles();
    logger.log("Artigos carregados do Supabase:", articles.length);
    renderArticles();
  })();

  // Newsletter subscription
  const newsletterForm = document.getElementById("newsletter-form");
  if (newsletterForm) {
    newsletterForm.addEventListener("submit", async (e) => {
      e.preventDefault();
      const emailInput = document.getElementById("newsletter-email");
      const honeypot = newsletterForm.querySelector('[name="website"]');
      const submitBtn = newsletterForm.querySelector('button[type="submit"]');

      if (honeypot && honeypot.value) {
        newsletterForm.reset();
        return;
      }

      submitBtn.disabled = true;
      submitBtn.textContent = "A subscrever...";

      const result = await subscribeToNewsletter(emailInput.value, false);

      submitBtn.disabled = false;
      submitBtn.textContent = "Subscrever";

      const feedback = document.getElementById("newsletter-feedback");
      if (feedback) {
        feedback.className = "mt-4 rounded-lg px-4 py-3 text-sm text-center";
        if (result.success) {
          feedback.classList.add("bg-green-100", "text-green-800", "border", "border-green-300");
          feedback.textContent = result.message || "Subscrição realizada com sucesso!";
          newsletterForm.reset();
        } else {
          feedback.classList.add("bg-red-100", "text-red-800", "border", "border-red-300");
          feedback.textContent = result.error || "Erro ao subscrever.";
        }
        feedback.classList.remove("hidden");
        setTimeout(() => feedback.classList.add("hidden"), 5000);
      }
    });
  }
});
