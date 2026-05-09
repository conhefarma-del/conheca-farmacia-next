// Floating Drawer Mobile Menu
const hamburger = document.querySelector(".hamburger");
const drawer = document.getElementById("mobile-drawer");
const drawerOverlay = document.getElementById("drawer-overlay");
const drawerClose = document.getElementById("drawer-close");
const drawerLinks = document.getElementById("drawer-links");

// Active page detection
function setActiveDrawerLink() {
  if (!drawerLinks) return;
  const currentPath = window.location.pathname;
  const links = drawerLinks.querySelectorAll("a");
  links.forEach((link) => {
    const linkHref = link.getAttribute("href");
    // Normalize: strip leading slash and hash for comparison
    const normalizedLink = linkHref.replace(/^\//, "").replace(/#.*$/, "");
    const normalizedPath = currentPath.replace(/^\//, "").replace(/#.*$/, "");
    // Match if path ends with link href, or if both are root
    const isMatch =
      normalizedPath === normalizedLink ||
      normalizedPath.endsWith(normalizedLink) ||
      (normalizedLink === "index.html" &&
        (normalizedPath === "" || normalizedPath === "index.html"));
    if (isMatch) {
      link.classList.add("drawer-link-active");
    } else {
      link.classList.remove("drawer-link-active");
    }
  });
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
setActiveDrawerLink();

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
