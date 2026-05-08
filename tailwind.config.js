/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./*.html",
    "./src/**/*.{js,ts,jsx,tsx}",
    "./content/**/*.{md,html}",
  ],
  theme: {
    extend: {
      colors: {
        "brand-primary": "#00493a",
        "brand-accent": "#0a844f",
        "brand-deep": "#002a32",
      },
    },
  },
  plugins: [],
};
