/**
 * Dark Mode Theme Manager
 * Handles theme toggling, localStorage persistence, and system preference detection
 */

const THEME_KEY = 'theme';
const DARK_CLASS = 'dark';

/**
 * Get current theme preference
 * @returns {'dark' | 'light'}
 */
function getThemePreference() {
  // Check localStorage first
  if (typeof window !== 'undefined' && window.localStorage) {
    const stored = localStorage.getItem(THEME_KEY);
    if (stored) {
      return stored;
    }

    // Check system preference
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      return 'dark';
    }
  }

  return 'light';
}

/**
 * Apply theme to document
 * @param {'dark' | 'light'} theme
 */
function applyTheme(theme) {
  if (typeof document !== 'undefined') {
    if (theme === 'dark') {
      document.documentElement.classList.add(DARK_CLASS);
    } else {
      document.documentElement.classList.remove(DARK_CLASS);
    }
  }
}

/**
 * Set and persist theme preference
 * @param {'dark' | 'light'} theme
 */
function setTheme(theme) {
  if (typeof window !== 'undefined' && window.localStorage) {
    localStorage.setItem(THEME_KEY, theme);
  }
  applyTheme(theme);
}

/**
 * Toggle between dark and light themes
 */
function toggleTheme() {
  const current = getThemePreference();
  const next = current === 'dark' ? 'light' : 'dark';
  setTheme(next);
  return next;
}

/**
 * Initialize theme on page load
 */
function initTheme() {
  if (typeof document !== 'undefined') {
    const theme = getThemePreference();
    applyTheme(theme);
  }
}

// Initialize immediately to prevent FOUC (Flash of Unstyled Content)
initTheme();

// Expose toggleTheme to global scope for onclick handler
if (typeof window !== 'undefined') {
  window.toggleTheme = toggleTheme;
}

// Export for use in other modules
export { initTheme, toggleTheme, getThemePreference };
