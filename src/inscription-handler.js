// Script para capturar cliques em botões "Inscrever-me" com data-event-slug
// Redireciona para inscricao.html?evento={slug}
import { logger } from "./lib/logger.js";

document.addEventListener("DOMContentLoaded", () => {
  // Capturar todos os botões com data-event-slug
  const inscricaoButtons = document.querySelectorAll("[data-event-slug]");

  inscricaoButtons.forEach((button) => {
    button.addEventListener("click", (e) => {
      e.preventDefault();

      const eventSlug = button.getAttribute("data-event-slug");

      // Validar se o slug foi encontrado
      if (!eventSlug || eventSlug.trim() === "") {
        console.error("❌ data-event-slug não foi encontrado no botão");
        alert(
          "Erro: Não foi possível identificar o evento. Por favor, tente novamente."
        );
        return;
      }

      logger.log("✓ Redirecionando para inscrição:", eventSlug);

      // Redirecionar para página de inscrição com o evento como parâmetro
      window.location.href = `inscricao.html?evento=${encodeURIComponent(eventSlug)}`;
    });
  });

  logger.log(
    `✓ ${inscricaoButtons.length} botão(ões) de inscrição configurado(s)`
  );
});
