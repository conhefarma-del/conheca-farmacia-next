import { getArticles } from './lib/api.js';

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
    console.log("Renderizando artigos. Total:", articles.length);

    const filtered = articles.filter((article) => {
      const matchesFilter =
        currentFilter === "all" || article.category === currentFilter;
      const matchesSearch =
        article.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        article.excerpt.toLowerCase().includes(searchTerm.toLowerCase());
      return matchesFilter && matchesSearch;
    });

    console.log("Artigos filtrados:", filtered.length);

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
          <img src="${article.image}" alt="${article.title}" class="article-card-img" loading="lazy" decoding="async">
          <div class="article-card-content">
            <span class="article-tag" style="background-color: ${categoryColors[article.category]}20; color: ${categoryColors[article.category]}; border: 1px solid ${categoryColors[article.category]}40">${article.categoryLabel}</span>
            <h3 class="article-card-title">${article.title}</h3>
            <p class="article-card-excerpt">${article.excerpt}</p>
            <a href="artigo.html?id=${article.id}" class="article-card-link">Ler mais <span>→</span></a>
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
    console.log("Artigos carregados do Supabase:", articles.length);
    renderArticles();
  })();
});
