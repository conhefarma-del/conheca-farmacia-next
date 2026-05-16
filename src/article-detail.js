import { getArticleBySlug, getArticles } from "./lib/api.js";
import { renderBreadcrumb } from "./breadcrumb.js";

// Cores por categoria (mesmo padrão que articles-logic.js)
const categoryColors = {
  profissionais: "#ff6c23",
  "voce-sabia": "#0a844f",
  "conheca-medicamento": "#7c3aed",
  curiosidades: "#002a32",
  saude: "#006171",
  legislacao: "#ff4d4d",
};

// Show loading skeleton while fetching data
function showLoadingState() {
  const hero = document.getElementById("article-hero");
  const body = document.getElementById("article-body");
  const relatedSection = document.querySelector(".article-related-section");

  if (hero) hero.style.opacity = "0.4";
  if (body) {
    body.innerHTML = `
      <div class="animate-pulse space-y-4">
        <div class="h-4 bg-brand-deep/10 rounded w-3/4"></div>
        <div class="h-4 bg-brand-deep/10 rounded w-full"></div>
        <div class="h-4 bg-brand-deep/10 rounded w-5/6"></div>
        <div class="h-4 bg-brand-deep/10 rounded w-2/3"></div>
        <div class="h-4 bg-brand-deep/10 rounded w-full"></div>
        <div class="h-4 bg-brand-deep/10 rounded w-4/5"></div>
      </div>`;
  }
  if (relatedSection) relatedSection.style.display = "none";
}

// Remove loading skeleton after data arrives
function hideLoadingState() {
  const hero = document.getElementById("article-hero");
  if (hero) hero.style.opacity = "1";
}

// Format date to Portuguese
function formatDate(dateStr) {
  const date = new Date(dateStr);
  const options = { year: "numeric", month: "long", day: "numeric" };
  return date.toLocaleDateString("pt-PT", options);
}

// Render article references section
function renderReferences(article) {
  const referencesSection = document.getElementById(
    "article-references-section"
  );
  const referencesList = document.getElementById("article-references");

  if (!referencesSection || !referencesList) return;

  // Check if article has references
  if (!article.references || article.references.length === 0) {
    referencesSection.style.display = "none";
    return;
  }

  // Show section and render references
  referencesSection.style.display = "block";
  referencesList.innerHTML = "";

  article.references.forEach((ref, index) => {
    const refElement = document.createElement("div");
    refElement.className = "reference-item";
    refElement.innerHTML = `
      <span class="reference-number">${index + 1}.</span>
      <span class="reference-text">${ref}</span>
    `;
    referencesList.appendChild(refElement);
  });
}

// Initialize carousel navigation for related articles
function initCarouselNavigation() {
  const relatedGrid = document.getElementById("related-articles-grid");

  if (!relatedGrid) return;

  const articles = relatedGrid.querySelectorAll(".article-card");
  const articlesCount = articles.length;

  // Only activate carousel if 3 or more articles
  if (articlesCount < 3) {
    return;
  }

  // Create wrapper for carousel
  const wrapper = document.createElement("div");
  wrapper.className = "related-carousel-wrapper";

  // Clone and replace grid with wrapper
  relatedGrid.parentNode.insertBefore(wrapper, relatedGrid);
  wrapper.appendChild(relatedGrid);

  // Add carousel classes and remove grid classes that conflict
  relatedGrid.classList.add("related-carousel-container");
  relatedGrid.classList.remove(
    "grid",
    "grid-cols-1",
    "md:grid-cols-2",
    "lg:grid-cols-3",
    "gap-8"
  );

  // Add carousel item classes to each card
  articles.forEach((article) => {
    article.classList.add("related-carousel-item");
  });

  // Create navigation buttons
  const prevBtn = document.createElement("button");
  prevBtn.className = "carousel-nav-btn carousel-nav-btn--left";
  prevBtn.setAttribute("aria-label", "Artigo anterior");
  prevBtn.innerHTML =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M15 18l-6-6 6-6"/></svg>';

  const nextBtn = document.createElement("button");
  nextBtn.className = "carousel-nav-btn carousel-nav-btn--right";
  nextBtn.setAttribute("aria-label", "Próximo artigo");
  nextBtn.innerHTML =
    '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>';

  // Scroll behavior - scroll by card width + gap
  const firstCard = relatedGrid.querySelector(".article-card");
  const cardWidth = firstCard ? firstCard.offsetWidth : 300;
  const gap = 24; // gap-6 = 1.5rem = 24px
  const scrollAmount = cardWidth + gap;

  prevBtn.addEventListener("click", () => {
    relatedGrid.scrollBy({ left: -scrollAmount, behavior: "smooth" });
  });

  nextBtn.addEventListener("click", () => {
    relatedGrid.scrollBy({ left: scrollAmount, behavior: "smooth" });
  });

  // Insert buttons into wrapper
  wrapper.appendChild(prevBtn);
  wrapper.appendChild(nextBtn);
}

// Load and render article
async function loadArticle() {
  const params = new URLSearchParams(window.location.search);
  const articleId = params.get("id");

  if (!articleId) {
    ErrorHandler.handle(
      new Error("ID do artigo não fornecido"),
      "PAGE",
      "Artigo não encontrado"
    );
    return;
  }

  try {
    showLoadingState();

    // Fetch article from Supabase (with JSON fallback)
    const article = await getArticleBySlug(articleId);

    if (!article) {
      ErrorHandler.handle(
        new Error(`Artigo com slug ${articleId} não encontrado`),
        "PAGE",
        "Artigo não encontrado"
      );
      return;
    }

    // Breadcrumb
    renderBreadcrumb([
      { label: "Início", href: "/" },
      { label: "Artigos", href: "/artigos.html" },
      { label: article.title },
    ]);

    // Convert markdown to HTML (with sanitization)
    const rawHtmlContent = marked.parse(article.content);
    // Sanitize HTML to prevent XSS injection
    const htmlContent = DOMPurify.sanitize(rawHtmlContent, {
      ALLOWED_TAGS: [
        "b",
        "i",
        "em",
        "strong",
        "p",
        "br",
        "h1",
        "h2",
        "h3",
        "h4",
        "h5",
        "h6",
        "ul",
        "ol",
        "li",
        "blockquote",
        "code",
        "pre",
        "a",
        "img",
        "table",
        "thead",
        "tbody",
        "tr",
        "th",
        "td",
      ],
      ALLOWED_ATTR: ["href", "src", "alt", "title", "target"],
    });

    // Populate hero section
    const categoryColor = categoryColors[article.category] || "#666";
    const categoryEl = document.getElementById("article-category");
    categoryEl.className = "article-tag";
    categoryEl.style.cssText = `background-color: ${categoryColor}20; color: ${categoryColor}; border: 1px solid
      ${categoryColor}40`;
    categoryEl.textContent = article.categoryLabel;
    document.getElementById("article-title").textContent = article.title;
    document.getElementById("article-featured-image").src = article.image;
    document.getElementById("article-featured-image").alt = article.title;

    // Populate meta bar
    document.getElementById("article-author-avatar").textContent =
      article.author.avatar;
    document.getElementById("article-author-avatar").style.backgroundColor =
      article.author.avatarBg;
    document.getElementById("article-author-name").textContent =
      article.author.name;
    document.getElementById("article-author-role").textContent =
      article.author.role;
    document.getElementById("article-date").textContent = formatDate(
      article.date
    );
    document.getElementById("article-readtime").textContent =
      `${article.readTime} min leitura`;

    // Populate article body
    document.getElementById("article-body").innerHTML = htmlContent;

    // Populate sidebar author card
    document.getElementById("sidebar-author-avatar").textContent =
      article.author.avatar;
    document.getElementById("sidebar-author-avatar").style.backgroundColor =
      article.author.avatarBg;
    document.getElementById("sidebar-author-role").textContent =
      article.author.role;
    document.getElementById("sidebar-author-name").textContent =
      article.author.name;
    document.getElementById("sidebar-author-bio").textContent =
      article.author.bio;

    // Render references section
    renderReferences(article);

    // Remove loading state
    hideLoadingState();

    // Load related articles (same category, exclude current)
    // Show all related articles (carousel activates if 3+ items)
    const allArticles = await getArticles();
    const relatedArticles = allArticles.filter(
      (a) => a.category === article.category && a.slug !== article.slug
    );

    const relatedSection = document.querySelector(".article-related-section");
    const relatedGrid = document.getElementById("related-articles-grid");

    // Only show related section if there are 2 or more related articles
    if (relatedArticles.length < 2) {
      relatedSection.style.display = "none";
    } else {
      relatedSection.style.display = "block";
      relatedGrid.innerHTML = "";

      relatedArticles.forEach((relArticle) => {
        const card = document.createElement("article");
        card.className = "article-card border border-brand-divider/10";
        card.innerHTML = `
        <img src="${relArticle.image}" alt="${relArticle.title}" class="article-card-img">
        <div class="article-card-content">
          <span class="article-tag" style="background-color: ${categoryColors[relArticle.category] || "#666"}20; color:
          ${categoryColors[relArticle.category] || "#666"}; border: 1px solid ${
          categoryColors[relArticle.category] || "#666"
        }40">${relArticle.categoryLabel}</span>
          <h3 class="article-card-title">${relArticle.title}</h3>
          <p class="article-card-excerpt">${relArticle.excerpt}</p>
          <a href="artigo.html?id=${relArticle.slug}" class="article-card-link">Ler mais <span>&rarr;</span></a>
        </div>
      `;
        relatedGrid.appendChild(card);
      });

      // Initialize carousel if 3 or more articles
      if (relatedArticles.length >= 3) {
        setTimeout(() => initCarouselNavigation(), 100);
      }
    }

    // Update page title
    document.title = `${article.title} - Conheça Farmácia`;
  } catch (error) {
    hideLoadingState();
    ErrorHandler.handle(error, "PAGE", "Desculpe, artigo não disponível");
  }
}

// Load article on page load
document.addEventListener("DOMContentLoaded", loadArticle);
