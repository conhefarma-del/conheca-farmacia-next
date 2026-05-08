# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📋 Common Development Commands

### Development Server

```bash
# Start development server with hot-reload
npm run dev
# Opens at http://localhost:5173
```

### Production Build

```bash
# Build for production
npm run build
# Preview production build
npm run preview
```

### Code Formatting

```bash
# Format code with Prettier
npm run format
```

### Dependencies

```bash
# Install dependencies
npm install
```

## 🏗️ Project Architecture & Structure

### Core Technologies

- **Framework**: Vite (ES modules, hot module replacement)
- **Styling**: Tailwind CSS v4 (via `@tailwindcss/vite` plugin)
- **Backend**: Supabase (database, auth, edge functions)
- **State Management**: Vanilla JavaScript (no framework)

### Key Directories & Files

```
├── index.html           # Main HTML entry (CSS/JS injected by Vite)
├── main.js              # Vite entry point (imports CSS and script.js)
├── vite.config.js       # Vite configuration (Tailwind plugin)
├── src/
│   ├── input.css        # Tailwind CSS directives
│   ├── script.js        # Global navigation and DOM utilities
│   ├── config.js        # Supabase client initialization
│   └── content/         # JSON data catalogs (articles, events, lives)
├── public/              # Static assets (images, logos)
└── dist/                # Production build output
```

### Data Flow

1. **Content Sources**: JSON files in `src/content/` serve as the primary data source
2. **Rendering**: Vanilla JS fetches JSON and renders HTML templates
3. **Styling**: Tailwind utility classes applied directly in HTML
4. **Interactivity**: Event listeners in `script.js` handle navigation and UI interactions

### Supabase Integration

- **Configuration**: `src/config.js` initializes Supabase client
- **Edge Functions**: Used for secure operations (email, data validation)
- **Database**: Stores event registrations and user interactions

### Important Notes

- **Development**: Must use `npm run dev` - direct file:// opening fails due to ES modules
- **CSS Injection**: Tailwind CSS is injected via JavaScript during Vite dev/server
- **Routing**: Client-side routing handled via hash/fragment identifiers and programmatic navigation
- **Security**: DOMPurify used for HTML sanitization when rendering Markdown content
