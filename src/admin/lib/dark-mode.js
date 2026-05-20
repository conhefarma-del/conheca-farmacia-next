/**
 * Dark Mode Toggle for Admin Panel
 * Persists preference in localStorage
 * Syncs with html.dark class
 */

const STORAGE_KEY = 'admin-dark-mode';

function isDarkMode() {
  return document.documentElement.classList.contains('dark');
}

function setDarkMode(enabled) {
  document.documentElement.classList.toggle('dark', enabled);
  try {
    localStorage.setItem(STORAGE_KEY, enabled ? 'true' : 'false');
  } catch {
    // localStorage indisponível
  }
  updateToggleIcon();
}

function toggleDarkMode() {
  setDarkMode(!isDarkMode());
}

function updateToggleIcon() {
  const toggleBtn = document.getElementById('dark-mode-toggle');
  if (!toggleBtn) return;

  const sunIcon = toggleBtn.querySelector('.sun-icon');
  const moonIcon = toggleBtn.querySelector('.moon-icon');

  if (isDarkMode()) {
    sunIcon.style.display = 'none';
    moonIcon.style.display = 'block';
  } else {
    sunIcon.style.display = 'block';
    moonIcon.style.display = 'none';
  }
}

function initDarkMode() {
  const stored = localStorage.getItem(STORAGE_KEY);
  if (stored === 'true') {
    document.documentElement.classList.add('dark');
  }
  updateToggleIcon();
}

export { initDarkMode, toggleDarkMode, isDarkMode };
