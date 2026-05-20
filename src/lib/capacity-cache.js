/**
 * Cache conservador para capacidade/vagas de eventos
 * Duração curta (15s) para evitar requests duplicados
 * enquanto mantém dados quase em tempo real
 */
import { logger } from './logger.js';

const CAPACITY_CACHE_PREFIX = "capacity_cache";
const CAPACITY_CACHE_DURATION = 15000; // 15 segundos

/**
 * Obter dados do cache
 * @param {string} eventId - ID do evento
 * @returns {Promise<Object|null>} Dados do cache ou null se expirado/inválido
 */
export async function getCachedCapacity(eventId) {
  try {
    const cached = localStorage.getItem(`${CAPACITY_CACHE_PREFIX}_${eventId}`);
    if (cached) {
      const { data, timestamp } = JSON.parse(cached);
      if (Date.now() - timestamp < CAPACITY_CACHE_DURATION) {
        return data; // Cache válido
      }
    }
    return null; // Cache expirado ou inválido
  } catch (error) {
    logger.warn("Erro ao ler cache de capacidade:", error);
    return null;
  }
}

/**
 * Guardar dados no cache
 * @param {string} eventId - ID do evento
 * @param {Object} data - Dados a guardar
 */
export async function setCapacityCache(eventId, data) {
  try {
    localStorage.setItem(
      `${CAPACITY_CACHE_PREFIX}_${eventId}`,
      JSON.stringify({
        data,
        timestamp: Date.now(),
      })
    );
  } catch (error) {
    logger.warn("Erro ao guardar cache de capacidade:", error);
  }
}

/**
 * Limpar cache de um evento específico
 * @param {string} eventId - ID do evento
 */
export function clearCapacityCache(eventId) {
  try {
    localStorage.removeItem(`${CAPACITY_CACHE_PREFIX}_${eventId}`);
  } catch (error) {
    logger.warn("Erro ao limpar cache de capacidade:", error);
  }
}

/**
 * Limpar todo o cache de capacidade
 */
export function clearAllCapacityCache() {
  try {
    const keysToRemove = Object.keys(localStorage).filter((key) =>
      key.startsWith(CAPACITY_CACHE_PREFIX)
    );

    keysToRemove.forEach((key) => localStorage.removeItem(key));
  } catch (error) {
    logger.warn("Erro ao limpar cache de capacidade:", error);
  }
}
