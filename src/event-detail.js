// Importar configurações do Supabase
import { supabaseClient, SUPABASE_URL, SUPABASE_ANON_KEY } from "./config.js";
import { getEvents, getEventBySlug } from './lib/api.js';
import { renderBreadcrumb } from "./breadcrumb.js";
import { createPolling } from "./lib/polling.js";
import { getCachedCapacity, setCapacityCache } from "./lib/capacity-cache.js";

function formatDate(dateStr) {
  const date = new Date(dateStr + "T00:00:00");
  const options = { year: "numeric", month: "long", day: "numeric" };
  return date.toLocaleDateString("pt-PT", options);
}

function formatDateSimple(dateStr) {
  const date = new Date(dateStr + "T00:00:00");
  const options = { day: "2-digit", month: "2-digit", year: "numeric" };
  return date.toLocaleDateString("pt-PT", options);
}

// ==========================================
// DIAGNÓSTICO: Função exposta para debugging no console
// ==========================================
window.debugInscriptions = async function (slug) {
  const s = slug || new URLSearchParams(window.location.search).get("id");
  console.log("🔍 Debug: Contando inscrições para:", s);

  const { data, error, count } = await supabaseClient
    .from("inscricoes")
    .select("*", { count: "exact", head: true })
    .eq("evento_slug", s);

  console.log("📊 Resultado:", { data, error, count });
  console.log("📝 SQL: SELECT * FROM inscricoes WHERE evento_slug = ?", s);

  if (error) {
    console.error("❌ Erro:", error);
  } else {
    console.log(`✅ ${count} inscrições encontradas`);
  }
  return { data, error, count };
};

console.log("💡 DICA: Execute debugInscriptions() no console para debug");

// Função para contar inscrições reais do Supabase
async function getInscriptionCount(eventoSlug) {
  try {
    console.log(`🔍 Contando inscrições para: "${eventoSlug}"`);
    console.log(`🔗 SUPABASE_URL: ${SUPABASE_URL?.substring(0, 30)}...`);
    console.log(`🔑 SUPABASE_ANON_KEY presente: ${!!SUPABASE_ANON_KEY}`);

    // Verificar se Supabase está disponível
    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      console.warn("⚠️ Supabase credentials não disponíveis");
      return null;
    }

    // Método 1: Usar cliente Supabase (mais fiável que REST API direta)
    console.log("📡 A usar cliente Supabase...");
    console.log(`📊 Tabela: inscricoes, Filtro: evento_slug = "${eventoSlug}"`);

    const query = supabaseClient
      .from("inscricoes")
      .select("*", { count: "exact", head: true })
      .eq("evento_slug", eventoSlug);

    console.log(
      "📝 Query SQL equivalente: SELECT * FROM inscricoes WHERE evento_slug = ?",
      eventoSlug
    );

    const { data, error, count } = await query;

    if (error) {
      console.error("❌ Erro na query Supabase:", error.message);
      console.error("Código:", error.code);
      console.error("Detalhes:", error.details);
      console.error("Hint:", error.hint);

      // Erro RLS (42501) significa que a política bloqueia a acesso
      if (error.code === "42501") {
        console.error(
          '🚫 ERRO RLS: Política de segurança bloqueia leitura. Verifique as políticas da tabela "inscricoes".'
        );
      }

      return null;
    }

    console.log(`✅ Inscrições encontradas (Supabase): ${count}`);
    console.log(`📦 Dados retornados:`, data);
    return count || 0;
  } catch (error) {
    console.error("❌ Erro ao conectar com Supabase:", error.message);
    console.error("Stack:", error.stack);

    // Fallback: tentar REST API direta
    console.log("🔄 A tentar REST API direta...");
    try {
      const url = `${SUPABASE_URL}/rest/v1/inscricoes?evento_slug=eq.${encodeURIComponent(eventoSlug)}&limit=1`;
      console.log(`🌐 URL REST: ${url.substring(0, 100)}...`);

      const response = await fetch(url, {
        headers: {
          Authorization: `Bearer ${SUPABASE_ANON_KEY}`,
          apikey: SUPABASE_ANON_KEY,
          Prefer: "count=exact",
        },
      });

      console.log(`📡 Status HTTP: ${response.status} ${response.statusText}`);

      if (!response.ok) {
        console.error(`❌ REST API falhou: ${response.status}`);
        return null;
      }

      const contentRange = response.headers.get("content-range");
      console.log(`📦 Content-Range header: ${contentRange}`);

      if (!contentRange) return null;

      const count = parseInt(contentRange.split("/")[1]);
      console.log(`✅ Inscrições encontradas (REST): ${count}`);
      return count;
    } catch (e) {
      console.error("❌ REST API também falhou:", e.message);
      return null;
    }
  }
}

document.addEventListener("DOMContentLoaded", async () => {
  const params = new URLSearchParams(window.location.search);
  const eventId = params.get("id");

  const eventNotFound = document.getElementById("event-not-found");
  const similarEventsSection = document.getElementById(
    "similar-events-section"
  );

  if (!eventId) {
    eventNotFound.classList.remove("hidden");
    return;
  }

  try {
    // Load event from Supabase (with JSON fallback)
 console.log("Carregando evento do Supabase:", eventId);

    // Find event by slug (URL parameter contains the slug, not numeric ID)
    const event = await getEventBySlug(eventId);

    if (!event) {
      console.error(`Evento com ID/slug ${eventId} não encontrado`);
      eventNotFound.classList.remove("hidden");
      return;
    }

    console.log("Evento encontrado:", event);

    // Breadcrumb
    renderBreadcrumb([
      { label: "Início", href: "/" },
      { label: "Eventos", href: "/eventos.html" },
      { label: event.title },
    ]);

    // Calculate event status
    const today = new Date();
    const todayFormatted = today.toISOString().split("T")[0];
    const isUpcoming = event.date >= todayFormatted;
    const eventStatus = isUpcoming ? "upcoming" : "past";

    // Get category color
    function getCategoryColor(category) {
      const colors = {
        workshop: "#ff6c23",
        palestra: "#0a844f",
        congresso: "#002a32",
      };
      return colors[category] || "#00493a";
    }

    const categoryColor = getCategoryColor(event.category);

    // Populate Hero Section
    const categoryBadge = document.getElementById("event-category");
    categoryBadge.textContent = event.categoryLabel;
    categoryBadge.style.backgroundColor = categoryColor + "20";
    categoryBadge.style.color = categoryColor;

    document.getElementById("event-title").textContent = event.title;

    const featuredImage = document.getElementById("event-featured-image");
    featuredImage.src = event.image;
    featuredImage.alt = event.title;

    // Event Meta Bar
    const typeLabel = event.type === "online" ? "Online" : "Presencial";
    document.getElementById("event-type-meta").textContent = typeLabel;
    document.getElementById("event-type-meta").style.backgroundColor =
      categoryColor + "20";
    document.getElementById("event-type-meta").style.color = categoryColor;

    document.getElementById("event-date-meta").textContent = formatDate(
      event.date
    );
    document.getElementById("event-location-meta").textContent = event.location;
    document.getElementById("event-time-meta").textContent =
      `${event.time} — ${event.endTime}`;

    // Populate Content Section
    document.getElementById("event-description").textContent = event.excerpt;

    // Event Details
    document.getElementById("event-type-detail").textContent = typeLabel;
    document.getElementById("event-date-detail").textContent = formatDate(
      event.date
    );
    document.getElementById("event-time-detail").textContent =
      `${event.time} — ${event.endTime} (${calculateDuration(event.time, event.endTime)})`;
    document.getElementById("event-location-detail").textContent =
      event.location;

    // SINCRONIZAR COM SUPABASE: Contar inscrições reais
    let inscriptionCount = 0; // Default — registered count comes from Supabase inscriptions, not from event data
    console.log(`📊 Valor padrão (JSON): ${inscriptionCount}`);
    console.log(`📊 Slug do evento: ${event.slug}`);

    console.log("⏳ A consultar Supabase...");
    const realCount = await getInscriptionCount(event.slug);

    console.log(`🔍 Resultado da query: ${realCount}`);

    if (realCount !== null && realCount !== undefined && realCount >= 0) {
      inscriptionCount = realCount;
      console.log(`✅ Usando contagem real do Supabase: ${inscriptionCount}`);
    } else {
      console.log(
        `⚠️ Falha na query Supabase (retornou ${realCount}), usando JSON: ${inscriptionCount}`
      );
    }

    // Capacity Information - AGORA SINCRONIZADO
    const spotsLeft = event.capacity - inscriptionCount;
    const capacityPercent = Math.round(
      (inscriptionCount / event.capacity) * 100
    );

    console.log(
      `📈 Capacidade: ${event.capacity}, Inscrições: ${inscriptionCount}, Vagas: ${spotsLeft}, Percentual: ${capacityPercent}%`
    );

    const capacityFilled = document.getElementById("event-capacity-filled");
    capacityFilled.style.width = capacityPercent + "%";
    capacityFilled.style.backgroundColor =
      capacityPercent >= 100 ? "#dc2626" : categoryColor;

    const capacityText = document.getElementById("event-capacity-text");
    if (spotsLeft > 0) {
      capacityText.textContent = `${spotsLeft} vagas disponíveis de ${event.capacity}`;
      capacityText.style.color = "#1f2937"; // cor normal
    } else {
      capacityText.textContent = "Evento completo - Sem vagas disponíveis";
      capacityText.style.color = "#dc2626";
    }

    // Registration Button
    const registrationBtn = document.getElementById("event-registration-btn");
    registrationBtn.setAttribute("data-event-slug", event.slug);

    if (eventStatus === "past") {
      registrationBtn.textContent = "Ver Gravação";
      registrationBtn.classList.remove("btn-primary");
      registrationBtn.classList.add("btn-secondary");
      registrationBtn.disabled = true;
    } else if (spotsLeft <= 0) {
      // BLOQUEAR SE CAPACIDADE ATINGIDA
      registrationBtn.textContent = "Evento Completo";
      registrationBtn.disabled = true;
      registrationBtn.classList.add("btn-disabled");
      console.log("🚫 Inscrições fechadas - Capacidade máxima atingida");
    } else {
      registrationBtn.textContent = "Inscrever-me";
      registrationBtn.disabled = false;
    }

    // Speakers Section (below Inscrever-me)
    renderSpeakers(event.hosts || [event.host], categoryColor);

    // Update Page Title
    document.title = `${event.title} - Conheça Farmácia`;

    // Similar Events
    const allEvents = await getEvents();
  const similarEvents = getSimilarEvents(allEvents, event);
    if (similarEvents.length >= 2) {
      similarEventsSection.classList.remove("hidden");
      renderSimilarEvents(similarEvents, allEvents);
    } else {
      similarEventsSection.classList.add("hidden");
    }
  } catch (error) {
    console.error("Erro ao carregar detalhe do evento:", error);
    eventNotFound.classList.remove("hidden");
  }

  // ==========================================
  // REFRESH CAPACITY: Atualizar vagas periodicamente
  // ==========================================
  let pollingInstance = null;
  let event = null; // Reference to current event for capacity updates

  async function refreshCapacity() {
    console.log("🔄 Atualizando contagem de vagas...");
    updateCapacityStatus("updating");

    // Tentar obter do cache primeiro
    const cached = await getCachedCapacity(event.slug);
    if (cached) {
      updateCapacityUI(cached);
      updateCapacityStatus("valid");
      console.log("✅ Dados do cache utilizados");
      return;
    }

    // Cache inválido ou expirado - buscar dados frescos
    const realCount = await getInscriptionCount(event.slug);

    if (realCount !== null && realCount !== undefined) {
      const spotsLeft = event.capacity - realCount;
      const capacityPercent = Math.round((realCount / event.capacity) * 100);

      const capacityData = { spotsLeft, capacityPercent, realCount };

      // Guardar no cache
      await setCapacityCache(event.slug, capacityData);

      updateCapacityUI(capacityData);
      updateCapacityStatus("valid");
      console.log(`✅ Vagas atualizadas: ${spotsLeft} disponíveis`);
    } else {
      updateCapacityStatus("error");
    }
  }

  function updateCapacityUI(data) {
    const { spotsLeft, capacityPercent, realCount } = data;

    // Atualizar barra de capacidade
    const capacityFilled = document.getElementById("event-capacity-filled");
    if (capacityFilled) {
      capacityFilled.style.width = capacityPercent + "%";
      capacityFilled.style.backgroundColor =
        capacityPercent >= 100 ? "#dc2626" : categoryColor;
    }

    // Atualizar texto de vagas
    const capacityText = document.getElementById("event-capacity-text");
    if (capacityText) {
      if (spotsLeft > 0) {
        capacityText.textContent = `${spotsLeft} vagas disponíveis de ${event.capacity}`;
        capacityText.style.color = "#1f2937";
      } else {
        capacityText.textContent = "Evento completo - Sem vagas disponíveis";
        capacityText.style.color = "#dc2626";
      }
    }

    // Atualizar botão de inscrição
    const registrationBtn = document.getElementById("event-registration-btn");
    if (registrationBtn) {
      if (spotsLeft <= 0) {
        registrationBtn.textContent = "Evento Completo";
        registrationBtn.disabled = true;
        registrationBtn.classList.add("btn-disabled");
      }
    }
  }

  // Indicador visual de status
  function updateCapacityStatus(status, message) {
    const statusEl = document.getElementById("capacity-status");
    if (!statusEl) return;

    const dot = statusEl.querySelector(".status-dot");
    const text = statusEl.querySelector(".status-text");
    if (!dot || !text) return;

    dot.classList.remove("updating", "error", "valid");

    switch (status) {
      case "updating":
        dot.classList.add("updating");
        text.textContent = "A atualizar...";
        break;
      case "error":
        dot.classList.add("error");
        text.textContent = message || "Erro na atualização";
        break;
      case "valid":
        dot.classList.add("valid");
        text.textContent = "Vagas atualizadas";
        break;
      default:
        text.textContent = "Vagas atualizadas agora";
    }
  }

  // Iniciar polling com cleanup e visibility detection
  function startCapacityPolling() {
    pollingInstance = createPolling(refreshCapacity, {
      initialInterval: 30000, // 30s em primeiro plano
      maxInterval: 120000, // 2min máximo com backoff
      maxRetries: 5,
      useBackoff: true,
    });

    // Setup cleanup quando elemento for removido
    const eventContainer = document.getElementById("event-capacity-container");
    pollingInstance.setupCleanup(eventContainer);
  }

  startCapacityPolling();

  // Verificar se há parâmetro refresh=true na URL
  const urlParams = new URLSearchParams(window.location.search);
  if (urlParams.get("refresh") === "true") {
    console.log("🔄 Parâmetro refresh=true detetado, atualizando...");
    refreshCapacity();
    const params = new URLSearchParams(window.location.search);
    params.delete("refresh");
    const newUrl =
      window.location.pathname +
      (params.toString() ? "?" + params.toString() : "");
    window.history.replaceState({}, "", newUrl);
  }

  function calculateDuration(startTime, endTime) {
    const [startHour, startMin] = startTime.split(":").map(Number);
    const [endHour, endMin] = endTime.split(":").map(Number);

    const startTotalMin = startHour * 60 + startMin;
    const endTotalMin = endHour * 60 + endMin;

    const durationMin = endTotalMin - startTotalMin;
    const hours = Math.floor(durationMin / 60);
    const minutes = durationMin % 60;

    if (hours > 0 && minutes > 0) {
      return `${hours}h${minutes}min`;
    } else if (hours > 0) {
      return `${hours}h`;
    } else {
      return `${minutes}min`;
    }
  }

  function getSimilarEvents(allEvents, currentEvent) {
    return allEvents
      .filter(
        (e) => e.category === currentEvent.category && e.slug !== currentEvent.slug
      )
      .slice(0, 3);
  }

  function renderSimilarEvents(similarEvents, allEvents) {
    const grid = document.getElementById("similar-events-grid");
    grid.innerHTML = "";

    function getCategoryColor(category) {
      const colors = {
        workshop: "#ff6c23",
        palestra: "#0a844f",
        congresso: "#002a32",
      };
      return colors[category] || "#00493a";
    }

    function calculateStatus(eventDate) {
      const today = new Date().toISOString().split("T")[0];
      return eventDate >= today ? "upcoming" : "past";
    }

    similarEvents.forEach((event) => {
      const categoryColor = getCategoryColor(event.category);
      const eventDate = formatDate(event.date);
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

      const card = document.createElement("article");
      card.className = "event-card";

      const spotsLeft = event.capacity - (event.registered || 0);

      card.innerHTML = `
<div class="event-card-header">
  <div class="event-card-date-box" style="background-color: ${categoryColor}">
    <div class="day">${day}</div>
    <div class="month">${month}</div>
  </div>
  <img src="${event.image}" alt="${event.title}" class="event-card-image">
</div>
<div class="event-card-content">
  <div class="event-card-meta-top">
    <span class="event-badge" style="background-color: ${categoryColor}20; color: ${categoryColor}">
      ${event.categoryLabel}
    </span>
    <span class="event-type-badge">${event.type === "online" ? "Online" : "Presencial"}</span>
  </div>

  <h3 class="event-card-title">${event.title}</h3>
  <p class="event-card-excerpt">${event.excerpt}</p>

  <div class="event-card-meta">
    <div class="event-meta-item">
      <span>${event.time} — ${event.endTime}</span>
    </div>
    <div class="event-meta-item">
      <span>${event.location}</span>
    </div>
    ${
      spotsLeft > 0
        ? `
      <div class="event-meta-item">
        <span>${spotsLeft} vagas disponíveis</span>
      </div>
    `
        : `
      <div class="event-meta-item">
        <span>Evento completo</span>
      </div>
    `
    }
  </div>

  <a href="evento.html?id=${event.slug}" class="event-card-cta">
    Mais Informações
  </a>
</div>
`;
      grid.appendChild(card);
    });
  }

  /**
   * Render speaker cards in the speakers section (below Inscrever-me)
   */
/**
 * Render speaker cards with "Show More" / "Show Less" controls
 * Mobile: shows 2 speakers initially
 * Desktop: shows 3 speakers initially
 */
function renderSpeakers(hosts, categoryColor) {
  const container = document.getElementById("speakers-container");
  const section = document.getElementById("speakers-section");
  if (!container || !section) return;

  // Normalize hosts to array
  const hostsArray = Array.isArray(hosts) ? hosts : hosts ? [hosts] : [];

  // Hide section if no hosts
  if (hostsArray.length === 0) {
    section.classList.add("hidden");
    return;
  }
  section.classList.remove("hidden");

  // Define limits: mobile (2) vs desktop (3)
  const isMobile = window.innerWidth < 768;
  const initialLimit = isMobile ? 2 : 3;
  const shouldShowButton = hostsArray.length > initialLimit;

  // Clear container
  container.innerHTML = "";

  // Render speaker cards
  hostsArray.forEach((host, index) => {
    const card = document.createElement("div");
    card.className = "speaker-card";
    
    // Hide cards beyond initial limit
    if (index >= initialLimit) {
      card.classList.add("speaker-card--hidden");
    }
    card.dataset.speakerIndex = index;

    const initials = host.name
      ? host.name
          .split(" ")
          .map((n) => n[0])
          .join("")
          .substring(0, 2)
          .toUpperCase()
      : "?";
    const color = categoryColor || "#0a844f";

    card.innerHTML =
      '<div class="speaker-card-avatar" style="background-color:' +
      color +
      '">' +
      initials +
      "</div>" +
      '<div class="speaker-card-name">' +
      (host.name || "") +
      "</div>" +
      (host.role
        ? '<div class="speaker-card-role">' + host.role + "</div>"
        : "") +
      (host.organization
        ? '<div class="speaker-card-organization">' +
          host.organization +
          "</div>"
        : "");

    container.appendChild(card);
  });

  // Create or remove "Show More" button
  const existingShowMore = container.querySelector(".speaker-show-more-btn");
  if (shouldShowButton && !existingShowMore) {
    const showMoreBtn = document.createElement("button");
    showMoreBtn.className = "speaker-show-more-btn";
    showMoreBtn.textContent = `Mostrar mais ${hostsArray.length - initialLimit} palestrantes`;
    showMoreBtn.dataset.action = "show-more";
    container.appendChild(showMoreBtn);
  } else if (!shouldShowButton && existingShowMore) {
    existingShowMore.remove();
  }

  // Add event listener for buttons
  container.addEventListener("click", handleSpeakerControls);
}

/**
 * Handle "Show More" / "Show Less" button clicks
 */
function handleSpeakerControls(event) {
  const target = event.target;
  const container = document.getElementById("speakers-container");
  if (!container) return;

  // Check if clicked "Show More"
  if (target.classList.contains("speaker-show-more-btn")) {
    const allCards = container.querySelectorAll(".speaker-card");
    allCards.forEach((card) => {
      card.classList.remove("speaker-card--hidden");
    });

    // Remove "Show More" button
    target.remove();

    // Add "Show Less" button
    const showLessBtn = document.createElement("button");
    showLessBtn.className = "speaker-show-less-btn";
    showLessBtn.textContent = "Ocultar palestrantes";
    showLessBtn.dataset.action = "show-less";
    container.appendChild(showLessBtn);
  }

  // Check if clicked "Show Less"
  if (target.classList.contains("speaker-show-less-btn")) {
    const isMobile = window.innerWidth < 768;
    const initialLimit = isMobile ? 2 : 3;

    const allCards = container.querySelectorAll(".speaker-card");
    allCards.forEach((card, index) => {
      if (index >= initialLimit) {
        card.classList.add("speaker-card--hidden");
      }
    });

    // Remove "Show Less" button
    target.remove();

    // Re-add "Show More" button
    const showMoreBtn = document.createElement("button");
    showMoreBtn.className = "speaker-show-more-btn";
    showMoreBtn.textContent = `Mostrar mais ${allCards.length - initialLimit} palestrantes`;
    showMoreBtn.dataset.action = "show-more";
    container.appendChild(showMoreBtn);
  }
}

});
