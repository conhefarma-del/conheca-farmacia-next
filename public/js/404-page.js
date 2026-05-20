// Dark Mode + Drawer for 404 page
const THEME_KEY = "theme";
const DARK_CLASS = "dark";
const LOGO_SELECTOR = ".logo img";
const LOGO_LIGHT = "/logo/logo-principal-verde.svg";
const LOGO_DARK = "/logo/logo-principal-branco.svg";

function getThemePreference() {
  try {
    const stored = localStorage.getItem(THEME_KEY);
    if (stored) return stored;
  } catch {}
  if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
    return "dark";
  }
  return "light";
}

function applyTheme(theme) {
  if (theme === "dark") {
    document.documentElement.classList.add(DARK_CLASS);
  } else {
    document.documentElement.classList.remove(DARK_CLASS);
  }
  const newSrc = theme === "dark" ? LOGO_DARK : LOGO_LIGHT;
  document.querySelectorAll(LOGO_SELECTOR + ", .drawer-logo img").forEach(function(img) {
    if (img.getAttribute("src") !== newSrc) {
      img.setAttribute("src", newSrc);
    }
  });
}

function setTheme(theme) {
  try { localStorage.setItem(THEME_KEY, theme); } catch {}
  applyTheme(theme);
}

function toggleTheme() {
  var current = getThemePreference();
  setTheme(current === "dark" ? "light" : "dark");
}

applyTheme(getThemePreference());

// Mobile Drawer
var hamburger = document.querySelector(".hamburger");
var drawer = document.getElementById("mobile-drawer");
var drawerOverlay = document.getElementById("drawer-overlay");
var drawerClose = document.getElementById("drawer-close");

function openDrawer() {
  if (!drawer) return;
  drawer.classList.add("open");
  if (drawerOverlay) drawerOverlay.classList.add("active");
  document.body.classList.add("drawer-open");
}

function closeDrawer() {
  if (!drawer) return;
  drawer.classList.remove("open");
  if (drawerOverlay) drawerOverlay.classList.remove("active");
  document.body.classList.remove("drawer-open");
}

if (hamburger) hamburger.addEventListener("click", function(e) { e.stopPropagation(); openDrawer(); });
if (drawerClose) drawerClose.addEventListener("click", closeDrawer);
if (drawerOverlay) drawerOverlay.addEventListener("click", closeDrawer);

document.querySelectorAll("#drawer-links a").forEach(function(link) {
  link.addEventListener("click", closeDrawer);
});

document.addEventListener("keydown", function(e) {
  if (e.key === "Escape") closeDrawer();
});

window.addEventListener("resize", function() {
  if (window.innerWidth > 768) closeDrawer();
});

if (drawer) drawer.addEventListener("click", function(e) { e.stopPropagation(); });
