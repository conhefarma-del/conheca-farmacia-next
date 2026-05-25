// Ponto de entrada principal para Vite
import "./src/input.css";

// Importar scripts existentes
import "./src/script.js";
import "./src/dark-mode.js";
import "./src/lib/analytics.js";

// i18n
import { initI18n } from "./src/i18n.js";
await initI18n();
