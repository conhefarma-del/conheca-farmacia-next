import { getArticleBySlug, getArticles } from "./lib/api.js";
import { renderBreadcrumb } from "./breadcrumb.js";
import { t } from "./i18n.js";
import { errorHandler } from "./lib/error-handler.js";
import { supabaseClient } from "./config.js";
import { escapeHtml } from "./lib/security.js";
import {
  setDocumentTitle,
  setMetaDescription,
  setCanonicalUrl,
  setOpenGraphTags,
  setTwitterCardTags,
  injectJsonLd,
  buildArticleSchema,
  buildBreadcrumbSchema,
} from "./lib/seo.js";

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
      <span class="reference-text">${escapeHtml(ref)}</span>
    `;
    referencesList.appendChild(refElement);
  });
}

// Render share section with OG tags and share buttons
function renderShareSection(article) {
  const url = window.location.href;
  const title = article.title;
  const description = article.description || article.excerpt || '';
  const image = article.image || '';

  // OG tags set via seo.js (called in loadArticle after data arrives)

  // Set share links
  const encodedUrl = encodeURIComponent(url);
  const encodedTitle = encodeURIComponent(title);
  const encodedText = encodeURIComponent(`${title} — ${description}`);

  const whatsapp = document.getElementById('share-whatsapp');
  const facebook = document.getElementById('share-facebook');
  const linkedin = document.getElementById('share-linkedin');
  const generic = document.getElementById('share-generic');

  if (whatsapp) whatsapp.href = `https://wa.me/?text=${encodedTitle}%20${encodedUrl}`;
  if (facebook) facebook.href = `https://www.facebook.com/sharer/sharer.php?u=${encodedUrl}`;
  if (linkedin) linkedin.href = `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}`;

  // Track share clicks
  if (whatsapp) whatsapp.addEventListener('click', () => trackShare(article.id));
  if (facebook) facebook.addEventListener('click', () => trackShare(article.id));
  if (linkedin) linkedin.addEventListener('click', () => trackShare(article.id));

  // Generic share: Web Share API (mobile) or copy link (desktop)
  if (generic) {
    generic.addEventListener('click', async () => {
      trackShare(article.id);
      if (navigator.share) {
        try {
          await navigator.share({ title, text: description, url });
        } catch (e) {
          // User cancelled — ignore
        }
      } else {
        try {
          await navigator.clipboard.writeText(url);
          showToast('Link copiado!');
        } catch (e) {
          // Fallback for older browsers
          const input = document.createElement('input');
          input.value = url;
          document.body.appendChild(input);
          input.select();
          document.execCommand('copy');
          document.body.removeChild(input);
          showToast('Link copiado!');
        }
      }
    });
  }
}

// Show toast notification
function showToast(message) {
  const existing = document.querySelector('.share-toast');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.className = 'share-toast';
  toast.textContent = message;
  document.body.appendChild(toast);

  requestAnimationFrame(() => toast.classList.add('show'));
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 2000);
}

// Track article page view
function trackPageView(slug) {
  supabaseClient.rpc('increment_view_count', { article_slug: slug }).then(() => {}).catch(() => {});
}

// Track share action
function trackShare(articleId) {
  supabaseClient.rpc('increment_share_count', { row_id: articleId }).then(() => {}).catch(() => {});
}

// Track reading time (sends every 30s while page is visible)
function trackReadingTime(articleId) {
  let readingStart = Date.now();

  setInterval(() => {
    if (!document.hidden) {
      const elapsed = Math.floor((Date.now() - readingStart) / 1000);
      if (elapsed > 0) {
        supabaseClient.rpc('add_reading_time', { row_id: articleId, seconds: elapsed }).then(() => {}).catch(() => {});
        readingStart = Date.now();
      }
    }
  }, 30000);

  // Reset timer when page becomes visible again
  document.addEventListener('visibilitychange', () => {
    if (!document.hidden) {
      readingStart = Date.now();
    }
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
    errorHandler.handle(
      new Error("ID do artigo não fornecido"),
      { mode: "PAGE" }
    );
    return;
  }

  try {
    showLoadingState();

    // Fetch article from Supabase (with JSON fallback)
    const article = await getArticleBySlug(articleId);

    if (!article) {
      errorHandler.handle(
        new Error(`Artigo com slug ${articleId} não encontrado`),
        { mode: "PAGE" }
      );
      return;
    }

    // Breadcrumb
    const breadcrumbLevels = [
      { label: "Início", href: "/", i18nKey: "nav.inicio" },
      { label: "Artigos", href: "/artigos.html", i18nKey: "nav.artigos" },
      { label: article.title },
    ];
    renderBreadcrumb(breadcrumbLevels);
    injectJsonLd(buildBreadcrumbSchema(breadcrumbLevels));

    // Convert markdown to HTML (with sanitization)
    const rawHtmlContent = marked.parse(article.content);
    // MED-06: Restrict img src to Supabase Storage and relative paths only
    DOMPurify.addHook('afterSanitizeAttributes', function (node) {
      if (node.tagName === 'IMG') {
        const src = node.getAttribute('src');
        if (src && !src.startsWith('/') && !src.startsWith('./') && !src.startsWith('data:') && !src.includes('supabase.co')) {
          node.removeAttribute('src');
        }
      }
      if (node.tagName === 'A') {
        const href = node.getAttribute('href');
        if (href && (href.startsWith('javascript:') || href.startsWith('data:') || href.startsWith('vbscript:'))) {
          node.removeAttribute('href');
        }
      }
    });

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
    const dateEl = document.getElementById("article-date");
    dateEl.setAttribute("datetime", article.published_date || article.date || "");
    dateEl.textContent = formatDate(article.date);
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

    // Render share section
    renderShareSection(article);

    // Track page view
    trackPageView(article.slug);

    // Track reading time
    trackReadingTime(article.id);

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
        <img src="${escapeHtml(relArticle.image)}" alt="${escapeHtml(relArticle.title)}" class="article-card-img">
        <div class="article-card-content">
          <span class="article-tag" style="background-color: ${categoryColors[relArticle.category] || "#666"}20; color:
          ${categoryColors[relArticle.category] || "#666"}; border: 1px solid ${
          categoryColors[relArticle.category] || "#666"
        }40">${escapeHtml(relArticle.categoryLabel)}</span>
          <h3 class="article-card-title">${escapeHtml(relArticle.title)}</h3>
          <p class="article-card-excerpt">${escapeHtml(relArticle.excerpt)}</p>
          <a href="artigo.html?id=${encodeURIComponent(relArticle.slug)}" class="article-card-link" aria-label="Ler artigo: ${escapeHtml(relArticle.title)}">Ler mais <span>&rarr;</span></a>
        </div>
      `;
        relatedGrid.appendChild(card);
      });

      // Initialize carousel if 3 or more articles
      if (relatedArticles.length >= 3) {
        setTimeout(() => initCarouselNavigation(), 100);
      }
    }

    // SEO: meta tags, OG, Twitter Card, JSON-LD
    const seoDescription = article.metaDescription || article.excerpt || article.title;
    const seoImage = article.image || '';
    setDocumentTitle(`${article.title} - Conheça Farmácia`);
    setMetaDescription(seoDescription);
    setCanonicalUrl(window.location.href);
    setOpenGraphTags({ title: article.title, description: seoDescription, image: seoImage, url: window.location.href, type: 'article' });
    setTwitterCardTags({ title: article.title, description: seoDescription, image: seoImage });
    injectJsonLd(buildArticleSchema(article));

  } catch (error) {
    hideLoadingState();
    errorHandler.handle(error, { mode: "PAGE" });
  }
}

// Load article on page load
document.addEventListener("DOMContentLoaded", loadArticle);
