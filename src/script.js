// Floating Drawer Mobile Menu
const hamburger = document.querySelector(".hamburger");
const drawer = document.getElementById("mobile-drawer");
const drawerOverlay = document.getElementById("drawer-overlay");
const drawerClose = document.getElementById("drawer-close");
const drawerLinks = document.getElementById("drawer-links");

// Map page paths (both with and without .html) to their parent section link href
// Netlify serves clean URLs (e.g. /artigos instead of /artigos.html)
const PAGE_SECTION_MAP = {
  "index.html": "index.html",
  "": "index.html",
  "artigos.html": "artigos.html",
  "artigos": "artigos.html",
  "artigo.html": "artigos.html",
  "artigo": "artigos.html",
  "eventos.html": "eventos.html",
  "eventos": "eventos.html",
  "evento.html": "eventos.html",
  "evento": "eventos.html",
  "inscricao.html": "eventos.html",
  "inscricao": "eventos.html",
  "lives-list.html": "lives-list.html",
  "lives-list": "lives-list.html",
  "lives.html": "lives-list.html",
  "lives": "lives-list.html",
  "sobre.html": "sobre.html",
  "sobre": "sobre.html",
};

// Active page detection for drawer + desktop nav-links
function setActiveNavLink() {
  const currentPath = window.location.pathname;
  const normalizedPath = currentPath.replace(/^\//, "").replace(/#.*$/, "");
  const activeHref = PAGE_SECTION_MAP[normalizedPath] || null;

  // Drawer links
  const drawerLinksEl = document.getElementById("drawer-links");
  if (drawerLinksEl) {
    drawerLinksEl.querySelectorAll("a").forEach((link) => {
      const linkHref = link
        .getAttribute("href")
        .replace(/^\//, "")
        .replace(/#.*$/, "");
      if (activeHref && linkHref === activeHref) {
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
      const linkHref = link
        .getAttribute("href")
        .replace(/^\//, "")
        .replace(/#.*$/, "");
      if (activeHref && linkHref === activeHref) {
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
