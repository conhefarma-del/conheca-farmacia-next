const STORAGE_KEY = 'conheca-farmacia-lang';
const SUPPORTED_LANGS = ['pt', 'en'];
const DEFAULT_LANG = 'pt';

let currentLang = DEFAULT_LANG;
let translations = {};

/**
 * Load translations for a given language
 * @param {string} lang
 */
async function loadTranslations(lang) {
  try {
    const response = await fetch(`/i18n/${lang}.json`);
    if (!response.ok) throw new Error(`Failed to load ${lang}.json`);
    translations = await response.json();
  } catch (error) {
    console.error('i18n: Error loading translations:', error);
    if (lang !== DEFAULT_LANG) {
      await loadTranslations(DEFAULT_LANG);
    }
  }
}

/**
 * Get a nested translation value by key path
 * @param {string} keyPath - e.g. "nav.inicio" or "search.placeholder"
 * @returns {string}
 */
export function t(keyPath) {
  const keys = keyPath.split('.');
  let value = translations;
  for (const key of keys) {
    if (value && typeof value === 'object' && key in value) {
      value = value[key];
    } else {
      return keyPath; // Return key if translation not found
    }
  }
  return typeof value === 'string' ? value : keyPath;
}

/**
 * Apply translations to all elements with data-i18n attribute
 */
export function applyTranslations() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    const translation = t(key);
    if (el.tagName === 'INPUT' && el.hasAttribute('placeholder')) {
      el.setAttribute('placeholder', translation);
    } else {
      el.textContent = translation;
    }
  });

  // Update lang attribute on html
  document.documentElement.setAttribute('lang', currentLang);
}

/**
 * Get current language
 * @returns {string}
 */
export function getCurrentLang() {
  return currentLang;
}

/**
 * Set language, save to localStorage, reload translations
 * @param {string} lang
 */
export async function setLanguage(lang) {
  if (!SUPPORTED_LANGS.includes(lang)) return;
  currentLang = lang;
  localStorage.setItem(STORAGE_KEY, lang);
  await loadTranslations(lang);
  applyTranslations();
}

/**
 * Toggle between PT and EN
 */
export async function toggleLanguage() {
  const newLang = currentLang === 'pt' ? 'en' : 'pt';
  await setLanguage(newLang);
}

/**
 * Initialize i18n module
 */
export async function initI18n() {
  // Load saved language or default
  const savedLang = localStorage.getItem(STORAGE_KEY);
  currentLang = SUPPORTED_LANGS.includes(savedLang) ? savedLang : DEFAULT_LANG;

  await loadTranslations(currentLang);
  applyTranslations();

  // Update language toggle buttons
  updateLangButtons();
}

/**
 * Update language toggle button states
 */
function updateLangButtons() {
  document.querySelectorAll('[data-lang]').forEach(btn => {
    const lang = btn.getAttribute('data-lang');
    if (lang === currentLang) {
      btn.classList.add('lang-active');
    } else {
      btn.classList.remove('lang-active');
    }
  });
}

/**
 * Get all translations for the current language (for dynamic content)
 * @returns {object}
 */
export function getTranslations() {
  return translations;
}

/**
 * Ready promise — modules can `await i18nReady` before using t()
 */
export const i18nReady = initI18n().catch(console.error);
