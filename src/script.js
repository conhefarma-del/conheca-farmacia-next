// Floating Drawer Mobile Menu
const hamburger = document.querySelector(".hamburger");
const drawer = document.getElementById("mobile-drawer");
const drawerOverlay = document.getElementById("drawer-overlay");
const drawerClose = document.getElementById("drawer-close");
const drawerLinks = document.getElementById("drawer-links");

// Normalize hrefs/paths to section keys — handles Netlify Post Processing which
// rewrites href="artigos.html" → href='/artigos' at deploy time
function normalizeToSection(href) {
  return href
    .replace(/^\//, "")
    .replace(/[?#].*$/, "")
    .replace(/\.html$/, "");
}

const PAGE_SECTION_MAP = {
  // Homepage
  "index.html": "index.html",
  index: "index.html",
  "": "index.html",
  // Artigos section
  "artigos.html": "artigos.html",
  artigos: "artigos.html",
  "artigo.html": "artigos.html",
  artigo: "artigos.html",
  // Eventos section
  "eventos.html": "eventos.html",
  eventos: "eventos.html",
  "evento.html": "eventos.html",
  evento: "eventos.html",
  "inscricao.html": "eventos.html",
  inscricao: "eventos.html",
  // Lives section
  "lives-list.html": "lives-list.html",
  "lives-list": "lives-list.html",
  "lives.html": "lives-list.html",
  lives: "lives-list.html",
  // Sobre section
  "sobre.html": "sobre.html",
  sobre: "sobre.html",
};

// Active page detection for drawer + desktop nav-links
function setActiveNavLink() {
  const currentPath = window.location.pathname;
  const normalizedPath = normalizeToSection(currentPath);
  const activeHref = PAGE_SECTION_MAP[normalizedPath] || null;

  // Drawer links
  const drawerLinksEl = document.getElementById("drawer-links");
  if (drawerLinksEl) {
    drawerLinksEl.querySelectorAll("a").forEach((link) => {
      const linkHref = normalizeToSection(link.getAttribute("href"));
      const linkSection = PAGE_SECTION_MAP[linkHref] || linkHref;
      if (activeHref && linkSection === activeHref) {
        link.classList.add("drawer-link-active");
      } else {
        link.classList.remove("drawer-link-active");
      }
    });
  }

  // Desktop nav links
  const navLinksEl = document.querySelector(".nav-links");
  if (navLinksEl) {
    navLinksEl.querySelectorAll("a").forEach((link) => {
      const linkHref = normalizeToSection(link.getAttribute("href"));
      const linkSection = PAGE_SECTION_MAP[linkHref] || linkHref;
      if (activeHref && linkSection === activeHref) {
        link.classList.add("nav-link-active");
      } else {
        link.classList.remove("nav-link-active");
      }
    });
  }
}

// Open drawer
function openDrawer() {
  if (!drawer) return;
  drawer.classList.add("open");
  if (drawerOverlay) drawerOverlay.classList.add("active");
  document.body.classList.add("drawer-open");
}

// Close drawer
function closeDrawer() {
  if (!drawer) return;
  drawer.classList.remove("open");
  if (drawerOverlay) drawerOverlay.classList.remove("active");
  document.body.classList.remove("drawer-open");
}

// Hamburger: only opens
if (hamburger) {
  hamburger.addEventListener("click", (e) => {
    e.stopPropagation();
    openDrawer();
  });
}

// Close button
if (drawerClose) {
  drawerClose.addEventListener("click", () => {
    closeDrawer();
  });
}

// Overlay click closes drawer
if (drawerOverlay) {
  drawerOverlay.addEventListener("click", () => {
    closeDrawer();
  });
}

// Link click closes drawer
if (drawerLinks) {
  const links = drawerLinks.querySelectorAll("a");
  links.forEach((link) => {
    link.addEventListener("click", () => {
      closeDrawer();
    });
  });
}

// Escape key closes drawer
document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") {
    closeDrawer();
  }
});

// Resize to desktop closes drawer
window.addEventListener("resize", () => {
  if (window.innerWidth > 768) {
    closeDrawer();
  }
});

// Prevent clicks inside drawer from closing it
if (drawer) {
  drawer.addEventListener("click", (e) => {
    e.stopPropagation();
  });
}

// Set active link on load
setActiveNavLink();

// Utility Bar — Search input (Enter → pesquisa.html)
const utilitySearchInput = document.getElementById('utility-search-input');
const isSearchPage = window.location.pathname.includes('pesquisa');

if (utilitySearchInput) {
  utilitySearchInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      const q = utilitySearchInput.value.trim();
      if (q) {
        window.location.href = `pesquisa.html?q=${encodeURIComponent(q)}`;
      }
    }
  });
}

// Utility Bar — Search icon click (mobile → redirect to pesquisa.html)
const utilitySearchIcon = document.querySelector('.utility-search-icon');
if (utilitySearchIcon) {
  utilitySearchIcon.addEventListener('click', () => {
    if (isSearchPage) {
      // On the search page, focus the search input
      const searchInput = document.getElementById('search-input');
      if (searchInput) searchInput.focus();
    } else {
      // On other pages, redirect to search page
      window.location.href = 'pesquisa.html';
    }
  });
}

// Utility Bar — Language dropdown
const langToggle = document.getElementById('lang-toggle');
const langDropdown = document.getElementById('lang-dropdown');
const langCurrent = document.getElementById('lang-current');

if (langToggle && langDropdown) {
  langToggle.addEventListener('click', (e) => {
    e.stopPropagation();
    const isOpen = langDropdown.classList.toggle('open');
    langToggle.setAttribute('aria-expanded', String(isOpen));
  });

  // Close dropdown when clicking outside
  document.addEventListener('click', (e) => {
    if (!langDropdown.contains(e.target) && !langToggle.contains(e.target)) {
      langDropdown.classList.remove('open');
      langToggle.setAttribute('aria-expanded', 'false');
    }
  });

  // Language option click
  langDropdown.querySelectorAll('.lang-option').forEach(option => {
    option.addEventListener('click', async (e) => {
      e.stopPropagation();
      const lang = option.getAttribute('data-lang');
      if (!lang) return;

      // Update active state
      langDropdown.querySelectorAll('.lang-option').forEach(o => o.classList.remove('active'));
      option.classList.add('active');

      // Update toggle label
      if (langCurrent) langCurrent.textContent = lang.toUpperCase();

      // Close dropdown
      langDropdown.classList.remove('open');
      langToggle.setAttribute('aria-expanded', 'false');

      // Apply language
      try {
        const { setLanguage } = await import('./i18n.js');
        await setLanguage(lang);
      } catch (_err) {
        // i18n module not available on this page
      }
    });
  });

  // Sync active state from stored language on load
  try {
    const stored = localStorage.getItem('conheca-farmacia-lang');
    if (stored && langCurrent) {
      langCurrent.textContent = stored.toUpperCase();
      langDropdown.querySelectorAll('.lang-option').forEach(o => {
        o.classList.toggle('active', o.getAttribute('data-lang') === stored);
      });
    }
  } catch (_err) {}
}

// Footer Admin Gate Button — redirect to admin (which has gate questions)
const adminGateBtn = document.getElementById('admin-gate-btn');
if (adminGateBtn) {
  adminGateBtn.addEventListener('click', () => {
    const adminPath = import.meta.env.DEV ? '/src/admin/index.html' : '/admin/index.html';
    window.location.href = adminPath;
  });
}

// Export for use in other modules if needed
export function initNavigation() {
  return {
    hamburger,
    drawer,
    drawerOverlay,
    drawerClose,
    drawerLinks,
    openDrawer,
    closeDrawer,
  };
}
