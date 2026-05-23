import eventsData from "./content/events-catalog.json";
import livesData from "./content/lives-catalog.json";
import { escapeHtml } from "./lib/security.js";
import { logger } from "./lib/logger.js";

/**
 * Formata uma data no formato YYYY-MM-DD para formato por extenso em PT
 */
function formatDate(dateStr) {
  const date = new Date(dateStr + "T00:00:00");
  const options = { year: "numeric", month: "long", day: "numeric" };
  return date.toLocaleDateString("pt-PT", options);
}

/**
 * Formata uma data simples (dia/mês)
 */
function formatDateCard(dateStr) {
  const date = new Date(dateStr + "T00:00:00");
  const day = String(date.getDate()).padStart(2, "0");
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
  ][date.getMonth()];
  return {
    day,
    month,
    full: date.toLocaleDateString("pt-PT", {
      day: "numeric",
      month: "long",
      year: "numeric",
    }),
  };
}

/**
 * Obtém a cor da categoria
 */
function getCategoryColor(category) {
  const colors = {
    workshop: "#ff6c23",
    palestra: "#0a844f",
    congresso: "#002a32",
  };
  return colors[category] || "#00493a";
}

/**
 * Calcula o status do evento (upcoming ou past)
 */
function calculateStatus(eventDate) {
  const today = new Date().toISOString().split("T")[0];
  return eventDate >= today ? "upcoming" : "past";
}

/**
 * Renderiza os cards de eventos regulares na Home
 */
function renderEventsGrid(events, container) {
  if (!container) return;

  container.innerHTML = "";

  if (events.length === 0) {
    container.innerHTML =
      '<p class="text-center text-brand-deep/60">Nenhum evento disponível no momento.</p>';
    return;
  }

  events.slice(0, 2).forEach((event) => {
    const categoryColor = getCategoryColor(event.category);
    const { day, month } = formatDateCard(event.date);
    const dateObj = new Date(event.date + "T00:00:00");
    const fullDate = dateObj.toLocaleDateString("pt-PT", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });

    const card = document.createElement("div");
    card.className = "event-card";
    card.innerHTML = `
			<div class="event-card-header">
				<div class="event-card-date-box" style="background-color: ${categoryColor}">
					<div class="day">${day}</div>
					<div class="month">${month}</div>
				</div>
				<img src="${escapeHtml(event.image)}" alt="${escapeHtml(event.title)}" class="event-card-image">
			</div>
			<div class="event-card-content">
				<div class="event-date">
					${fullDate}
				</div>
				<h3 class="event-card-title">${escapeHtml(event.title)}</h3>
				<p class="event-card-desc">${escapeHtml(event.excerpt)}</p>
				<a href="evento.html?id=${encodeURIComponent(event.slug)}" class="btn btn-primary btn-small w-full btn-inscrever" aria-label="Ver evento: ${escapeHtml(event.title)}">Saber mais</a>
			</div>
		`;
    container.appendChild(card);
  });
}

/**
 * Renderiza os cards de lives na Home
 */
function renderLivesGrid(lives, container) {
  if (!container) return;

  container.innerHTML = "";

  if (lives.length === 0) {
    container.innerHTML =
      '<p class="text-center text-brand-deep/60">Nenhuma live disponível no momento.</p>';
    return;
  }

  lives.slice(0, 2).forEach((live) => {
    const categoryColor = getCategoryColor(live.categoria);
    const { day, month } = formatDateCard(live.data);
    const dateObj = new Date(live.data + "T00:00:00");
    const fullDate = dateObj.toLocaleDateString("pt-PT", {
      day: "numeric",
      month: "long",
      year: "numeric",
    });

    const card = document.createElement("div");
    card.className = "event-card";
    card.innerHTML = `
			<div class="event-card-header">
				<div class="event-card-date-box" style="background-color: ${categoryColor}">
					<div class="day">${day}</div>
					<div class="month">${month}</div>
				</div>
				<img src="${escapeHtml(live.imagem)}" alt="${escapeHtml(live.titulo)}" class="event-card-image">
			</div>
			<div class="event-card-content">
				<div class="event-date">
					${fullDate}
				</div>
				<h3 class="event-card-title">${escapeHtml(live.titulo)}</h3>
				<p class="event-card-desc">${escapeHtml(live.resumo)}</p>
				<a href="lives.html?id=${encodeURIComponent(live.slug)}" class="btn btn-primary btn-small w-full btn-inscrever">Aceder Live</a>
			</div>
		`;
    container.appendChild(card);
  });
}

/**
 * Função principal de inicialização
 */
async function initHomeEvents() {
  logger.log("🏠 Home Events: Carregando catálogos...");

  // Carrega eventos regulares
  const eventsContainer = document.getElementById("home-events-grid");
  if (eventsContainer) {
    const events = eventsData.events || [];
    logger.log(`📅 Eventos regulares carregados: ${events.length}`);
    renderEventsGrid(events, eventsContainer);
  }

  // Carrega lives
  const livesContainer = document.getElementById("home-lives-grid");
  if (livesContainer) {
    const lives = livesData.events || [];
    logger.log(`📹 Lives carregadas: ${lives.length}`);
    renderLivesGrid(lives, livesContainer);
  }
}

// Exporta funções para uso externo se necessário
window.renderHomeEvents = initHomeEvents;

// Inicializa quando o DOM estiver pronto
document.addEventListener("DOMContentLoaded", initHomeEvents);
