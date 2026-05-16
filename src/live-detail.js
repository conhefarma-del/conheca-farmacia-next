import { getLives, getLiveBySlug } from './lib/api.js';
import { renderBreadcrumb } from "./breadcrumb.js";

/**
 * Formata uma data no formato YYYY-MM-DD para formato por extenso em PT
 */
function formatDate(dateStr) {
  const date = new Date(dateStr + "T00:00:00");
  const options = { year: "numeric", month: "long", day: "numeric" };
  return date.toLocaleDateString("pt-PT", options);
}

/**
 * Formata uma data no formato YYYY-MM-DD para formato simples (dia/mês/ano)
 */
function formatDateSimple(dateStr) {
  const date = new Date(dateStr + "T00:00:00");
  const options = { day: "2-digit", month: "2-digit", year: "numeric" };
  return date.toLocaleDateString("pt-PT", options);
}

/**
 * Formata hora e duração
 */
function formatTimeDuration(startTime, endTime) {
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

/**
 * Obtém a cor da categoria
 */
function getCategoryColor(category) {
  const colors = {
    live: "#006171",
    webinar: "#7c3aed",
    entrevista: "#ff6c23",
  };
  return colors[category] || "#00493a";
}

/**
 * Calcula a hora de término com base na duração
 */
function getEndTime(live) {
  // Se já tiver hora de término, usa ela
  if (live.hora_termino) {
    return live.hora_termino;
  }
  // Caso contrário, calcula com base no duration ou assume 1h
  const [startHour, startMin] = live.hora.split(":").map(Number);
  const durationMinutes = 60; // Assume 1 hora por padrão
  const endTotalMin = startHour * 60 + startMin + durationMinutes;
  const endHour = Math.floor(endTotalMin / 60) % 24;
  const endMinute = endTotalMin % 60;
  return `${String(endHour).padStart(2, "0")}:${String(endMinute).padStart(2, "0")}`;
}

/**
 * Renderiza os detalhes da live
 */
function renderLiveDetail(live) {
  // Category Badge
  const categoryBadge = document.getElementById("live-category");
  const categoryColor = getCategoryColor(live.categoria);
  categoryBadge.textContent = live.categoriaLabel;
  categoryBadge.style.backgroundColor = categoryColor + "20";
  categoryBadge.style.color = categoryColor;

  // Title
  document.getElementById("live-title").textContent = live.titulo;

  // Featured Image
  const featuredImage = document.getElementById("live-featured-image");
  featuredImage.src = live.imagem;
  featuredImage.alt = live.titulo;

  // Meta Bar
  document.getElementById("live-platform-meta").textContent = live.plataforma;
  document.getElementById("live-platform-meta").style.backgroundColor =
    categoryColor + "20";
  document.getElementById("live-platform-meta").style.color = categoryColor;

  document.getElementById("live-date-meta").textContent = formatDate(live.data);
  document.getElementById("live-time-meta").textContent =
    `${live.hora} — ${formatTimeDuration(live.hora, getEndTime(live))}`;

  // Description
  document.getElementById("live-description").textContent = live.resumo;

  // Quick Access Button
  const accessBtn = document.getElementById("live-access-btn");
  accessBtn.href = live.link_acesso;

  // Meeting credentials (ID e Senha)
  const credentialsDiv = document.getElementById("live-credentials");
  const meetingIdEl = document.getElementById("meeting-id");
  const meetingPasswordEl = document.getElementById("meeting-password");
  const meetingIdContainer = document.getElementById("meeting-id-container");
  const meetingPasswordContainer = document.getElementById(
    "meeting-password-container"
  );

  // Mostrar apenas se houver informações de reunião
  if (live.id_reuniao && live.id_reuniao.trim() !== "") {
    meetingIdEl.textContent = live.id_reuniao;
  } else {
    meetingIdContainer.style.display = "none";
  }

  if (live.senha && live.senha.trim() !== "") {
    meetingPasswordEl.textContent = live.senha;
  } else {
    meetingPasswordContainer.style.display = "none";
  }

  // Se não houver informações de credenciais, esconder o card
  if (!live.id_reuniao && !live.senha) {
    credentialsDiv.style.display = "none";
  }

  // Materials Section
  const materialsSection = document.getElementById("materials-section");
  const materialsList = document.getElementById("materials-list");

  if (live.materiais_apoio && live.materiais_apoio.length > 0) {
    materialsList.innerHTML = "";
    live.materiais_apoio.forEach((material, index) => {
      const li = document.createElement("li");
      li.innerHTML = `
				<a href="${material}" target="_blank" rel="noopener noreferrer" class="material-link" style="color: ${categoryColor}; text-decoration: none; font-weight: 500;">
					→ Material ${index + 1}
				</a>
			`;
      materialsList.appendChild(li);
    });
    materialsSection.style.display = "block";
  } else {
    materialsSection.style.display = "none";
  }

  // Host Card
  const hostInitials = live.anfitriao.nome
    .split(" ")
    .map((word) => word[0])
    .join("")
    .toUpperCase()
    .slice(0, 2);

  const hostAvatar = document.getElementById("host-avatar");
  hostAvatar.textContent = hostInitials;
  hostAvatar.style.backgroundColor = categoryColor;

  document.getElementById("host-role").textContent = live.anfitriao.cargo;
  document.getElementById("host-name").textContent = live.anfitriao.nome;
  document.getElementById("host-organization").textContent =
    live.anfitriao.organizacao;

  // Update Page Title
  document.title = `${live.titulo} - Conheça Farmácia`;
}

/**
 * Show a loading skeleton while data is being fetched
 */
function showLoading() {
  const heroSection = document.querySelector(".event-hero");
  const contentSection = document.querySelector(".event-content-section");
  const sections = [heroSection, contentSection].filter(Boolean);

  sections.forEach((section) => {
    section.style.opacity = "0.4";
    section.style.pointerEvents = "none";
  });

  // Add a loading indicator after breadcrumb
  const breadcrumb = document.getElementById("breadcrumb");
  if (breadcrumb) {
    const loader = document.createElement("div");
    loader.id = "live-loading";
    loader.className = "flex items-center justify-center py-8";
    loader.innerHTML = `
      <div class="inline-flex items-center gap-3 text-brand-deep/60">
        <svg class="animate-spin h-5 w-5" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"></path>
        </svg>
        <span class="text-sm font-medium">A carregar live...</span>
      </div>
    `;
    breadcrumb.after(loader);
  }
}

/**
 * Remove loading skeleton after data is loaded
 */
function hideLoading() {
  const heroSection = document.querySelector(".event-hero");
  const contentSection = document.querySelector(".event-content-section");
  const sections = [heroSection, contentSection].filter(Boolean);

  sections.forEach((section) => {
    section.style.opacity = "";
    section.style.pointerEvents = "";
  });

  const loader = document.getElementById("live-loading");
  if (loader) loader.remove();
}

// Main execution
document.addEventListener("DOMContentLoaded", async () => {
  const params = new URLSearchParams(window.location.search);
  const liveId = params.get("id");

  const liveNotFound = document.getElementById("live-not-found");

  if (!liveId) {
    liveNotFound.classList.remove("hidden");
    return;
  }

  showLoading();

  try {
    // Fetch live from Supabase via API layer
    const live = await getLiveBySlug(liveId);

    if (!live) {
      console.error(`Live com ID/slug ${liveId} não encontrada`);
      hideLoading();
      liveNotFound.classList.remove("hidden");
      return;
    }

    console.log("Live encontrada:", live);

    // Breadcrumb
    renderBreadcrumb([
      { label: "Início", href: "/" },
      { label: "Lives", href: "/lives-list.html" },
      { label: live.titulo },
    ]);
    renderLiveDetail(live);
    hideLoading();
  } catch (error) {
    console.error("Erro ao carregar detalhe da live:", error);
    hideLoading();
    liveNotFound.classList.remove("hidden");
  }
});
