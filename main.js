// Vendor CSS
import "./src/input.css";

// Vendor JS
import "./src/script.js";
import "./src/dark-mode.js";

// Analytics
import "./src/lib/analytics.js";

// i18n — non-blocking: translations apply when ready, HTML PT text is fallback
import { i18nReady } from "./src/i18n.js";
i18nReady;

// Homepage modules (side-effect imports — register DOMContentLoaded listeners)
import "./src/home-articles-logic.js";
import "./src/home-events-logic.js";
import "./src/hero-animated.js";
