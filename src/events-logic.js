import { supabaseClient } from "./config.js";
import { getEvents } from "./lib/api.js";
import { escapeHtml, validateUrl } from "./lib/security.js";
import { logger } from "./lib/logger.js";
import { subscribeToNewsletter } from "./lib/newsletter.js";

let events = [];
let currentStatus = "upcoming";
let currentCategory = "all";

// Função para contar inscrições reais do Supabase
async function getInscriptionCount(eventoSlug) {
  try {
    const { data, error, count } = await supabaseClient
      .from("inscricoes")
      .select("*", { count: "exact", head: true })
      .eq("evento_slug", eventoSlug);

    if (error) return null;

    return count || 0;
  } catch {
    return null;
  }
}

document.addEventListener("DOMContentLoaded", async () => {
  const grid = document.getElementById("events-grid");
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
    // Import the color map from config
    // Since we can't import directly in this context, we'll define it here
    // but it should match what's in config.js
    const colors = {
      workshop: "#ff6c23",
      palestra: "#0a844f",
      congresso: "#002a32",
      seminario: "#7c3aed",
      outro: "#6b7280",
    };
    return colors[category] || "#00493a";
  }

  async function renderEvents() {
    const filtered = events.filter((event) => {
      const matchesStatus = event.status === currentStatus;
      const matchesCategory =
        currentCategory === "all" || event.category === currentCategory;
      return matchesStatus && matchesCategory;
    });

    if (!grid) return;
    grid.innerHTML = "";

    if (filtered.length === 0) {
      noResults?.classList.remove("hidden");
    } else {
      noResults?.classList.add("hidden");

      for (const event of filtered) {
        const card = document.createElement("article");
        card.className = "event-card";

        const categoryColor = getCategoryColor(event.category);
        const dateObj = new Date(event.date + "T00:00:00");
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

        let inscriptionCount = event.registered;
        const realCount = await getInscriptionCount(event.slug);
        if (realCount !== null) inscriptionCount = realCount;

        const spotsLeft = event.capacity - inscriptionCount;
        const isCapacityFull = spotsLeft <= 0;

        card.innerHTML = `
<div class="event-card-header relative">
 <div class="event-card-date-box" style="background-color: ${categoryColor}">
 <div class="day">${day}</div>
 <div class="month">${month}</div>
 </div>
 <img src="${escapeHtml(event.image)}" alt="${escapeHtml(event.title)}" class="event-card-image" loading="lazy" decoding="async">
</div>

<div class="event-card-content">
 <div class="flex flex-row flex-wrap items-center gap-2 mb-4">
 <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider"
 style="background-color: ${categoryColor}20; color: ${categoryColor}; border: 1px solid ${categoryColor}40">
 ${escapeHtml(event.categoryLabel)}
 </span>
 <span class="inline-block text-[10px] font-bold px-2 py-1 rounded uppercase tracking-wider bg-slate-100 text-slate-600 border border-slate-200">
 ${event.type === "online" ? "Online" : "Presencial"}
 </span>
 </div>

 <h3 class="event-card-title">${escapeHtml(event.title)}</h3>
 <p class="event-card-excerpt">${escapeHtml(event.excerpt)}</p>

 <div class="event-card-meta">
 <div class="event-meta-item">
 <span>${escapeHtml(event.time)} — ${escapeHtml(event.endTime)}</span>
 </div>
 <div class="event-meta-item">
 <span>${escapeHtml(event.location)}</span>
 </div>
 ${
   spotsLeft > 0
     ? `
 <div class="event-meta-item">
 <span>${spotsLeft} vagas disponíveis</span>
 </div>
 `
     : `
 <div class="event-meta-item" style="color: #dc2626; font-weight: 600;">
 <span>Evento completo</span>
 </div>
 `
 }
 </div>

 <div class="event-card-actions mt-auto">
 <a href="evento.html?id=${encodeURIComponent(event.slug)}" class="btn btn-secondary btn-small">
 Mais Informações
 </a>
 <button data-event-slug="${escapeHtml(event.slug)}" class="btn btn-primary btn-small btn-inscrever" ${event.status === "past" || isCapacityFull ? "disabled" : ""}>
 ${isCapacityFull ? "Completo" : event.status === "upcoming" ? "Inscrever-me" : "Ver Gravação"}
 </button>
 </div>
</div>
`;
        grid.appendChild(card);
      }
    }
  }

  // Temporal filter button event listeners
  temporalBtns.forEach((btn) => {
    btn.addEventListener("click", async () => {
      // Remove active class from all temporal buttons
      temporalBtns.forEach((button) => {
        button.classList.remove("active");
      });
      // Add active class to clicked button
      btn.classList.add("active");
      // Update current status filter
      currentStatus = btn.dataset.status;
      // Re-render events with new filter
      await renderEvents();
    });
  });

  // Set initial active state for temporal buttons
  // Default to showing upcoming events
  temporalBtns.forEach((btn) => {
    if (btn.dataset.status === "upcoming") {
      btn.classList.add("active");
    } else {
      btn.classList.remove("active");
    }
  });

  categoryBtns.forEach((btn) => {
    btn.addEventListener("click", async () => {
      categoryBtns.forEach((b) => b.classList.remove("active"));
      btn.classList.add("active");
      currentCategory = btn.dataset.category;
      await renderEvents();
    });
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

  // ==========================================
  // REFRESH ON FOCUS: Atualizar lista ao retornar à página
  // ==========================================
  window.addEventListener("focus", async () => {
    logger.log("👁️ Janela em foco, atualizando lista de eventos...");
    await renderEvents();
  });

  // Verificar se há parâmetro refresh=true na URL
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get("refresh") === "true") {
    logger.log("🔄 Parâmetro refresh=true detetado, atualizando...");
    await renderEvents();
    // Remover apenas o parâmetro refresh
    const newParams = new URLSearchParams(window.location.search);
    newParams.delete("refresh");
    const newUrl =
      window.location.pathname +
      (newParams.toString() ? "?" + newParams.toString() : "");
    window.history.replaceState({}, "", newUrl);
  }

  // Inicialização
  async function initializeEvents() {
    try {
      // Tentar buscar eventos do Supabase
      const supabaseEvents = await getEvents();
      events = supabaseEvents.map((event) => ({
        ...event,
        status: calculateStatus(event.date),
      }));
      logger.log("✅ Eventos carregados do Supabase:", events.length);
    } catch (error) {
      logger.warn("⚠️ Falha ao carregar do Supabase, usando fallback:", error);
      // Fallback para dados locais
      import("./content/events-catalog.json").then((module) => {
        events = module.default.events.map((event) => ({
          ...event,
          status: calculateStatus(event.date),
        }));
        logger.log("✅ Eventos carregados do fallback JSON:", events.length);
      });
    }

    await renderEvents();
  }

  initializeEvents();
});
