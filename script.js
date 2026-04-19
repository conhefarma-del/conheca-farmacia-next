document.addEventListener('DOMContentLoaded', () => {
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');
    const header = document.querySelector('.header');

    if (hamburger && navLinks) {
        hamburger.addEventListener('click', () => {
            // Toggle the visibility of the nav-links on mobile
            // We'll use a class 'is-active' to handle the mobile menu state
            navLinks.classList.toggle('mobile-active');

            // Toggle hamburger animation
            hamburger.classList.toggle('is-active');
        });

        // Close menu when a link is clicked (important for single-page navigation)
        const links = document.querySelectorAll('.nav-links a');
        links.forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('mobile-active');
                hamburger.classList.remove('is-active');
            });
        });
    }
});
