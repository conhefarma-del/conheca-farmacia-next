import { getLives } from './lib/api.js';
import { escapeHtml, validateUrl } from './lib/security.js';
import { logger } from './lib/logger.js';
import { subscribeToNewsletter } from './lib/newsletter.js';

let lives = [];
let currentStatus = "upcoming";
let currentCategory = "all";

document.addEventListener("DOMContentLoaded", async () => {
  const grid = document.getElementById("lives-grid");
  const noResults = document.getElementById("no-results");
  const temporalBtns = document.querySelectorAll(".temporal-btn");
  const categoryBtns = document.querySelectorAll(".filter-btn");
  const newsletterForm = document.getElementById("newsletter-form");

  function getTodayDate() {
    return new Date().toISOString().split("T")[0];
  }

  function calculateStatus(eventDate) {
    const today = getTodayDate();
    return eventDate >= today ? "upcoming" : "past";
  }

  function formatDate(dateStr) {
    const date = new Date(dateStr + "T00:00:00");
    const options = { day: "numeric", month: "short", year: "numeric" };
    return date.toLocaleDateString("pt-PT", options).toUpperCase();
  }

  function getCategoryColor(category) {
    const colors = {
      live: "#006171",
      webinar: "#7c3aed",
      entrevista: "#ff6c23",
    };
    return colors[category] || "#00493a";
  }

  async function renderLives() {
    const filtered = lives.filter((live) => {
      const matchesStatus = live.status === currentStatus;
      const matchesCategory =
        currentCategory === "all" || live.categoria === currentCategory;
      return matchesStatus && matchesCategory;
    });

    if (!grid) return;
    grid.innerHTML = "";

    if (filtered.length === 0) {
      noResults?.classList.remove("hidden");
    } else {
      noResults?.classList.add("hidden");

      for (const live of filtered) {
        const card = document.createElement("article");
        card.className = "event-card";

        const categoryColor = getCategoryColor(live.categoria);
        const dateObj = new Date(live.data + "T00:00:00");
        const day = String(dateObj.getDate()).padStart(2, "0");
        const month = [
          "JAN",
          "FEV",
          "MAR",
          "ABR",
          "MAI",
          "JUN",
          "JUL",
          "AGO",
          "SET",
          "OUT",
          "NOV",
          "DEZ",
        ][dateObj.getMonth()];

        card.innerHTML = `
<div class="event-card-header relative">
 <div class="event-card-date-box" style="background-color: ${categoryColor}">
  <div class="day">${day}</div>
  <div class="month">${month}</div>
 </div>
 <img src="${escapeHtml(live.imagem)}" alt="${escapeHtml(live.titulo)}" class="event-card-image" loading="lazy" decoding="async">
</div>

<div class="event-card-content">
 <div class="flex flex-row flex-wrap items-center gap-2 mb-4">
  <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
  style="background-color: ${categoryColor}20; color: ${categoryColor}; border: 1px solid ${categoryColor}40">
  ${escapeHtml(live.categoriaLabel)}
  </span>
  <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
  ${escapeHtml(live.plataforma)}
  </span>
 </div>

 <h3 class="event-card-title">${escapeHtml(live.titulo)}</h3>
 <p class="event-card-excerpt">${escapeHtml(live.resumo)}</p>

 <div class="event-card-meta">
  <div class="event-meta-item">
   <span>${escapeHtml(live.hora)}</span>
  </div>
  <div class="event-meta-item">
   <span>${escapeHtml(live.plataforma)}</span>
  </div>
 </div>

 <div class="event-card-actions mt-auto">
  <a href="lives.html?id=${encodeURIComponent(live.slug)}" class="btn btn-secondary btn-small">
   Mais Informações
  </a>
  <a href="${validateUrl(live.link_acesso)}" target="_blank" rel="noopener noreferrer" class="btn btn-primary btn-small" style="background-color: ${categoryColor}; border-color: ${categoryColor}">
   ${live.status === "upcoming" ? "Aceder Live" : "Ver Gravação"}
  </a>
 </div>
</div>
`;
        grid.appendChild(card);
      }
    }
  }

  temporalBtns.forEach((btn) => {
    btn.addEventListener("click", async () => {
      temporalBtns.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentStatus = btn.dataset.status;
      await renderLives();
    });
  });

  categoryBtns.forEach((btn) => {
    btn.addEventListener("click", async () => {
      categoryBtns.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentCategory = btn.dataset.category;
      await renderLives();
    });
  });

  // Set initial active state for temporal buttons
  // Default to showing upcoming lives
  temporalBtns.forEach((btn) => {
    if (btn.dataset.status === "upcoming") {
      btn.classList.add("active");
    } else {
      btn.classList.remove("active");
    }
  });

  // Set initial active state for category buttons
  // Default to showing all categories
  categoryBtns.forEach((btn) => {
    if (btn.dataset.category === "all") {
      btn.classList.add("active");
    } else {
      btn.classList.remove("active");
    }
  });

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
      submitBtn.textContent = "Notifique-me";

      if (result.success) {
        newsletterForm.reset();
        alert(result.message);
      } else {
        alert(result.error);
      }
    });
  }

  // Refresh on focus
  window.addEventListener("focus", async () => {
    logger.log("👁️ Janela em foco, atualizando lista de lives...");
    await renderLives();
  });

  // Inicialização
  lives = await getLives();
  lives = lives.map((live) => ({
    ...live,
    status: calculateStatus(live.data),
  }));

  await renderLives();
});
