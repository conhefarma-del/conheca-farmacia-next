/**
 * Módulo de polling reutilizável com cleanup automático e deteção de visibilidade
 * @param {Function} fn - Função a ser executada no polling
 * @param {Object} options - Opções de configuração
 * @returns {Object} - Interface com stop() e setupCleanup()
 */
export function createPolling(fn, options = {}) {
  const {
    initialInterval = 30000,
    maxInterval = 300000,
    maxRetries = 5,
    useBackoff = true,
  } = options;

  let intervalId = null;
  let retryCount = 0;
  let currentInterval = initialInterval;
  let isPaused = false;

  // Detetar visibilidade da página
  const handleVisibilityChange = () => {
    if (document.hidden) {
      // Página invisível: pausar polling
      isPaused = true;
      if (intervalId) {
        clearInterval(intervalId);
        intervalId = null;
      }
    } else {
      // Página visível: retomar polling
      isPaused = false;
      start();
    }
  };

  document.addEventListener('visibilitychange', handleVisibilityChange);

  const execute = async () => {
    if (isPaused) return;

    try {
      await fn();
      retryCount = 0;
      currentInterval = initialInterval;
    } catch (error) {
      retryCount++;
      if (retryCount >= maxRetries) {
        stop();
        console.error('Máximo de tentativas atingido. Polling encerrado.');
        return;
      }

      if (useBackoff) {
        currentInterval = Math.min(currentInterval * 2, maxInterval);
      }
    }
  };

  const start = () => {
    if (intervalId || isPaused) return;
    intervalId = setInterval(execute, currentInterval);
  };

  const stop = () => {
    if (intervalId) {
      clearInterval(intervalId);
      intervalId = null;
    }
    document.removeEventListener('visibilitychange', handleVisibilityChange);
  };

  // Cleanup automático quando elemento for removido
  const setupCleanup = (element) => {
    if (!element) return null;

    const observer = new MutationObserver((mutations) => {
      for (const mutation of mutations) {
        for (const node of mutation.removedNodes) {
          if (node === element || node.contains?.(element)) {
            stop();
            observer.disconnect();
          }
        }
      }
    });

    observer.observe(document.body, { childList: true, subtree: true });
    return observer;
  };

  // Iniciar polling
  start();

  return { stop, setupCleanup };
}
