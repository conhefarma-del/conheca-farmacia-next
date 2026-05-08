/**
 * @typedef {'INFO' | 'WARN' | 'ERROR' | 'CRITICAL'} Severity
 * @typedef {'PAGE' | 'CONTAINER' | 'TOAST' | 'LOG'} DeliveryMode
 */

/**
 * ErrorHandler Singleton
 * Centralizes error catching, logging, and UI display.
 */
class ErrorHandler {
  constructor() {
    this._toastContainer = null;
    this._debugContainer = null;
  }

  /**
   * Primary entry point for error handling.
   * @param {Error|string} error - The error object or message.
   * @param {Object} options
   * @param {Severity} [options.severity='ERROR']
   * @param {DeliveryMode} [options.mode='TOAST']
   * @param {string} [options.containerId] - Required if mode is 'CONTAINER'.
   * @param {Function} [options.retryCallback] - Required if mode is 'PAGE'.
   */
  handle(error, options = {}) {
    const message = error instanceof Error ? error.message : error;
    const {
      severity = "ERROR",
      mode = "TOAST",
      containerId,
      retryCallback,
    } = options;

    // Ensure DOMPurify is available for sanitization
    const sanitizedMessage =
      typeof DOMPurify !== "undefined"
        ? DOMPurify.sanitize(message, { ALLOWED_TAGS: [], ALLOWED_ATTR: [] })
        : message;

    switch (mode) {
      case "PAGE":
        this.showPageError(sanitizedMessage, retryCallback);
        break;
      case "CONTAINER":
        this.showInContainer(containerId, sanitizedMessage, severity);
        break;
      case "LOG":
        this.logToDebug(sanitizedMessage, severity);
        break;
      case "TOAST":
      default:
        this.showToast(sanitizedMessage, severity);
        break;
    }
  }

  /**
   * Displays a floating notification.
   */
  showToast(message, severity) {
    this._ensureToastContainer();
    const toast = document.createElement("div");

    const severityClasses = {
      INFO: "bg-blue-50 text-blue-700 border-blue-200",
      WARN: "bg-amber-50 text-amber-700 border-amber-200",
      ERROR: "bg-red-50 text-red-700 border-red-200",
      CRITICAL: "bg-red-900 text-white border-red-950",
    };

    toast.className = `eh-toast show ${severityClasses[severity] || severityClasses.ERROR}`;
    toast.innerHTML = `
            <div class="flex items-center gap-2">
                <span class="font-bold">${this._getIcon(severity)}</span>
                <span>${message}</span>
            </div>
        `;

    this._toastContainer.appendChild(toast);

    setTimeout(() => {
      toast.classList.remove("show");
      setTimeout(() => toast.remove(), 300);
    }, 5000);
  }

  /**
   * Updates a specific DOM element with an error message.
   */
  showInContainer(containerId, message, severity) {
    const container = document.getElementById(containerId);
    if (!container) {
      console.error(`ErrorHandler: Container #${containerId} not found.`);
      return;
    }

    const severityClasses = {
      INFO: "bg-blue-50 text-blue-700 border-blue-200",
      WARN: "bg-amber-50 text-amber-700 border-amber-200",
      ERROR: "bg-red-50 text-red-700 border-red-200",
      CRITICAL: "bg-red-900 text-white border-red-950",
    };

    container.innerHTML = `
            <div class="eh-container-error ${severityClasses[severity] || severityClasses.ERROR}">
                <div class="flex items-center gap-2">
                    <span class="font-bold">${this._getIcon(severity)}</span>
                    <span>${message}</span>
                </div>
            </div>
        `;
    container.classList.remove("hidden");
  }

  /**
   * Replaces page content with a fatal error view.
   */
  showPageError(message, retryCallback) {
    const container = document.querySelector("main") || document.body;

    let retryButtonHtml = "";
    if (typeof retryCallback === "function") {
      retryButtonHtml = `
                <button onclick="window.location.reload()" class="eh-retry-btn">
                    Tentar novamente
                </button>
            `;
    }

    container.innerHTML = `
            <div class="eh-page-error">
                <div class="eh-page-error-icon">${this._getIcon("CRITICAL")}</div>
                <h1 class="eh-page-error-title">Ocorreu um erro inesperado</h1>
                <p class="eh-page-error-message">${message}</p>
                ${retryButtonHtml}
            </div>
        `;

    // If we want a custom callback instead of just reload
    if (typeof retryCallback === "function") {
      const btn = container.querySelector(".eh-retry-btn");
      btn.onclick = (e) => {
        e.preventDefault();
        retryCallback();
      };
    }
  }

  /**
   * Appends to a debug log area (for testing).
   */
  logToDebug(message, severity) {
    if (!this._debugContainer) {
      this._debugContainer =
        document.getElementById("log") || document.getElementById("debug-log");
    }

    if (this._debugContainer) {
      const entry = document.createElement("div");
      const severityClasses = {
        INFO: "text-blue-600",
        WARN: "text-amber-600",
        ERROR: "text-red-600",
        CRITICAL: "text-red-900 font-bold",
      };
      entry.className = `eh-debug-entry ${severityClasses[severity] || ""}`;
      entry.textContent = `[${new Date().toLocaleTimeString()}] [${severity}] ${message}`;
      this._debugContainer.appendChild(entry);
      this._debugContainer.scrollTop = this._debugContainer.scrollHeight;
    } else {
      console.log(`[${severity}] ${message}`);
    }
  }

  _ensureToastContainer() {
    if (!this._toastContainer) {
      this._toastContainer = document.createElement("div");
      this._toastContainer.id = "eh-toast-container";
      this._toastContainer.className =
        "fixed top-5 right-5 z-[100] flex flex-col gap-2 pointer-events-none";
      document.body.appendChild(this._toastContainer);
    }
  }

  _getIcon(severity) {
    const icons = {
      INFO: "ℹ️",
      WARN: "⚠️",
      ERROR: "❌",
      CRITICAL: "🚨",
    };
    return icons[severity] || "⚠️";
  }
}

export const errorHandler = new ErrorHandler();
