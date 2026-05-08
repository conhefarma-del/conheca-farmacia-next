// Navigation and mobile menu functionality
// Note: No need for DOMContentLoaded - ES modules are deferred by default

const hamburger = document.querySelector(".hamburger");
const navLinks = document.querySelector(".nav-links");
const navOverlay = document.querySelector(".nav-overlay");
const header = document.querySelector(".header");

// Toggle mobile menu function
function toggleMenu() {
  if (navLinks && hamburger) {
    navLinks.classList.toggle("mobile-active");
    hamburger.classList.toggle("is-active");

    // Toggle overlay
    if (navOverlay) {
      navOverlay.classList.toggle("active");
    }
  }
}

// Close mobile menu function
function closeMenu() {
  if (navLinks && hamburger) {
    navLinks.classList.remove("mobile-active");
    hamburger.classList.remove("is-active");

    // Hide overlay
    if (navOverlay) {
      navOverlay.classList.remove("active");
    }
  }
}

if (hamburger && navLinks) {
  // Open/close menu on hamburger click
  hamburger.addEventListener("click", (e) => {
    e.stopPropagation(); // Prevent event bubbling
    toggleMenu();
  });

  // Close menu when clicking on overlay
  if (navOverlay) {
    navOverlay.addEventListener("click", () => {
      closeMenu();
    });
  }

  // Close menu when a link is clicked (important for single-page navigation)
  const links = document.querySelectorAll(".nav-links a");
  links.forEach((link) => {
    link.addEventListener("click", () => {
      closeMenu();
    });
  });
}

// Prevent clicks inside nav-links from closing the menu
if (navLinks) {
  navLinks.addEventListener("click", (e) => {
    e.stopPropagation();
  });
}

// Export for use in other modules if needed
export function initNavigation() {
  // Navigation already initialized above
  return { hamburger, navLinks, header, navOverlay, toggleMenu, closeMenu };
}
