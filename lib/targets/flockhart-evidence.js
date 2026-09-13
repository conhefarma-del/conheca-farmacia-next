// lib/targets/flockhart-evidence.js
// Mapa de evidência Flockhart Table™ por alvo CYP e papel.
// Chave: nome EN do fármaco (normalizado minúsculas) → 'strong' | 'moderate'.
// Gerado de _temp/_flockhart_consolidated.json (ver _temp/_gen_migration250.mjs).
// Usado pela página de detalhe /alvos/[slug] para colorir os chips:
//   forte → var(--alvo-ev-strong) (#ff6c23) / moderada → var(--alvo-ev-moderate) (#006171).
import data from './flockhart-evidence.json';

const norm = (s) =>
  (s || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/\s+/g, ' ')
    .trim();

/**
 * Devolve 'strong' | 'moderate' | null para um nome de fármaco num alvo/papel.
 * Aceita o texto tal como aparece na lista (notas "(3A5)"/"(oral)" ignoradas).
 * Alvos não-CYP e indutores não têm evidência por fármaco → null.
 */
export function getFlockhartEvidence(targetSlug, role, drugName) {
  const entry = data[targetSlug];
  if (!entry) return null;
  const roleMap = entry[role];
  if (!roleMap) return null;
  const core = norm(String(drugName).replace(/\([^)]*\)/g, ' '));
  return roleMap[core] || roleMap[norm(drugName)] || null;
}
