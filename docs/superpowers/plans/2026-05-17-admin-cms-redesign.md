# Admin CMS Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the admin dashboard and login pages with modern UI matching the public site's design language (green-teal brand colors, Inter font, sidebar navigation).

**Architecture:** Replace the current "rustic" admin design with a polished CMS interface featuring: sidebar navigation, brand color variables, card-based stats with icons, improved typography (Inter + JetBrains Mono), and a centered login page with gradient background.

**Tech Stack:** Vanilla JavaScript, Tailwind CSS v4, Supabase Auth, Heroicons (CDN), Inter font (Google Fonts), JetBrains Mono (Google Fonts)

---

## File Structure

**Files to Create:**
- None (all changes modify existing files)

**Files to Modify:**
- `src/admin/styles/admin.css` — Complete rewrite with brand colors, sidebar styles, modern card layouts
- `src/admin/dashboard.html` — Add sidebar navigation, stat cards with icons, improved activity table
- `src/admin/index.html` — Redesign login page with centered layout and gradient background
- `src/admin/artigos/index.html` — Update navigation to include sidebar
- `src/admin/eventos/index.html` — Update navigation to include sidebar (if exists)
- `src/admin/lives/index.html` — Update navigation to include sidebar (if exists)

---

## Task 1: Update admin.css with brand color variables and base styles

**Files:**
- Modify: `src/admin/styles/admin.css`

- [ ] **Step 1: Replace CSS variables with brand colors**

Replace the `:root` section (lines 4-14) with:

```css
:root {
  /* Brand Colors from input.css */
  --admin-primary: #00493a;
  --admin-primary-hover: #005c4a;
  --admin-primary-deep: #002a32;
  --admin-accent: #0a844f;
  
  /* UI Colors */
  --admin-bg: #f9f9f9;
  --admin-card-bg: #ffffff;
  --admin-text: #1a1a1a;
  --admin-text-muted: #6b7280;
  --admin-border: #e5e7eb;
  --admin-divider: rgba(0, 73, 58, 0.1);
  
  /* Status Colors */
  --admin-success: #0a844f;
  --admin-success-bg: #e6f4ea;
  --admin-danger: #ef4444;
  --admin-danger-bg: #fee2e2;
  --admin-warning: #f59e0b;
  --admin-warning-bg: #fef3c7;
  
  /* Typography */
  --font-sans: "Inter", -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-mono: "JetBrains Mono", 'Monaco', 'Consolas', monospace;
}
```

- [ ] **Step 2: Add font imports at top of file**

Add at line 1 (before `/* Admin-only styles */`):

```css
/* Font imports */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500;600&display=swap');

/* Admin-only styles - not loaded on public pages */
```

- [ ] **Step 3: Verify CSS syntax**

Run:
```bash
node --check src/admin/styles/admin.css
```

Expected: No output (CSS files can't be checked with node, skip this step)

- [ ] **Step 4: Commit changes**

```bash
git add src/admin/styles/admin.css
git commit -m "style(admin): update CSS variables with brand colors and fonts"
```

---

## Task 2: Add sidebar navigation styles to admin.css

**Files:**
- Modify: `src/admin/styles/admin.css`

- [ ] **Step 1: Add sidebar layout styles**

After the `:root` block, add sidebar layout CSS:

```css
/* =============================================
   SIDEBAR LAYOUT
   ============================================= */

/* Dashboard Layout with Sidebar */
.admin-dashboard {
  display: flex;
  min-height: 100vh;
  background: var(--admin-bg);
  font-family: var(--font-sans);
}

.admin-sidebar {
  width: 280px;
  background: var(--admin-primary-deep);
  color: white;
  display: flex;
  flex-direction: column;
  position: fixed;
  top: 0;
  left: 0;
  height: 100vh;
  overflow-y: auto;
  z-index: 50;
}

.admin-sidebar-header {
  padding: 24px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}

.admin-sidebar-logo {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.admin-sidebar-logo img {
  width: 40px;
  height: 40px;
  object-fit: contain;
}

.admin-sidebar-logo h1 {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  color: white;
}

.admin-sidebar-subtitle {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.6);
  margin: 0;
}

.admin-nav-vertical {
  padding: 16px 12px;
  display: flex;
  flex-direction: column;
  gap: 4px;
  flex: 1;
}

.admin-nav-vertical a {
  color: rgba(255, 255, 255, 0.8);
  text-decoration: none;
  font-weight: 500;
  font-size: 14px;
  padding: 12px 16px;
  border-radius: 8px;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 12px;
}

.admin-nav-vertical a:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.admin-nav-vertical a.active {
  background: var(--admin-primary);
  color: white;
}

.admin-nav-vertical a svg {
  width: 20px;
  height: 20px;
}

.admin-sidebar-footer {
  padding: 16px 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.admin-sidebar-footer a {
  color: rgba(255, 255, 255, 0.6);
  text-decoration: none;
  font-size: 14px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 12px;
  border-radius: 8px;
  transition: all 0.2s;
}

.admin-sidebar-footer a:hover {
  background: rgba(255, 255, 255, 0.1);
  color: white;
}

.admin-sidebar-footer a svg {
  width: 20px;
  height: 20px;
}

/* Main Content Area */
.admin-main-content {
  margin-left: 280px;
  flex: 1;
  min-height: 100vh;
}

.admin-top-bar {
  background: var(--admin-card-bg);
  padding: 20px 32px;
  border-bottom: 1px solid var(--admin-border);
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 40;
}

.admin-top-bar h1 {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
  color: var(--admin-text);
}

.admin-user-menu {
  display: flex;
  align-items: center;
  gap: 16px;
}

.admin-user-info {
  text-align: right;
}

.admin-user-name {
  font-size: 14px;
  font-weight: 600;
  color: var(--admin-text);
  display: block;
}

.admin-user-email {
  font-size: 12px;
  color: var(--admin-text-muted);
  display: block;
}

.admin-logout-btn {
  padding: 8px 16px;
  background: var(--admin-bg);
  color: var(--admin-text);
  border: 1px solid var(--admin-border);
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
}

.admin-logout-btn:hover {
  background: var(--admin-border);
}

/* Content Container */
.admin-content-container {
  padding: 32px;
  max-width: 1400px;
}
```

- [ ] **Step 2: Update login page styles**

Replace `.admin-login-page` styles (lines 16-24):

```css
/* Login Page Layout - Centered with gradient */
.admin-login-page {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, var(--admin-primary) 0%, var(--admin-primary-deep) 100%);
  font-family: var(--font-sans);
}

.admin-login-container {
  width: 100%;
  max-width: 420px;
  padding: 24px;
}

.admin-login-box {
  background: var(--admin-card-bg);
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
}

.admin-login-header {
  text-align: center;
  margin-bottom: 32px;
}

.admin-login-logo {
  width: 64px;
  height: 64px;
  margin: 0 auto 20px;
  display: block;
}

.admin-login-header h1 {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
  color: var(--admin-text);
}
```

- [ ] **Step 3: Update form styles**

Replace `.admin-form-group`, `.admin-input`, `.admin-btn` styles (lines 56-100):

```css
.admin-form-group {
  margin-bottom: 20px;
}

.admin-form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  font-size: 14px;
  color: var(--admin-text);
}

.admin-input {
  width: 100%;
  padding: 12px 16px;
  border: 2px solid var(--admin-border);
  border-radius: 8px;
  font-size: 14px;
  font-family: var(--font-sans);
  transition: all 0.2s;
  background: var(--admin-card-bg);
}

.admin-input:focus {
  outline: none;
  border-color: var(--admin-primary);
  box-shadow: 0 0 0 3px rgba(0, 73, 58, 0.1);
}

.admin-btn {
  width: 100%;
  padding: 14px 20px;
  border: none;
  border-radius: 8px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  font-family: var(--font-sans);
}

.admin-btn-primary {
  background: var(--admin-primary);
  color: white;
}

.admin-btn-primary:hover {
  background: var(--admin-primary-hover);
  transform: translateY(-1px);
}

.admin-btn-primary:active {
  transform: translateY(0);
}
```

- [ ] **Step 4: Update stat card styles**

Replace `.admin-stats-grid` and `.admin-stat-card` styles (lines 342-369):

```css
/* Stats Grid - Dashboard metrics */
.admin-stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 20px;
  margin-bottom: 32px;
}

.admin-stat-card {
  background: var(--admin-card-bg);
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--admin-border);
  position: relative;
  overflow: hidden;
}

.admin-stat-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: linear-gradient(90deg, var(--admin-primary), var(--admin-accent));
}

.admin-stat-card h3 {
  margin: 0 0 8px 0;
  font-size: 13px;
  font-weight: 600;
  color: var(--admin-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.admin-stat-value {
  font-size: 36px;
  font-weight: 700;
  color: var(--admin-primary);
  font-family: var(--font-mono);
  line-height: 1;
  margin-bottom: 4px;
}

.admin-stat-label {
  font-size: 13px;
  color: var(--admin-text-muted);
}

.admin-stat-icon {
  position: absolute;
  top: 20px;
  right: 20px;
  width: 40px;
  height: 40px;
  background: rgba(0, 73, 58, 0.05);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--admin-primary);
}

.admin-stat-icon svg {
  width: 22px;
  height: 22px;
}
```

- [ ] **Step 5: Update table styles**

Replace `.admin-table` styles (lines 165-185):

```css
/* Table Styles */
.admin-table {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
}

.admin-table th {
  font-weight: 600;
  color: var(--admin-text-muted);
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 12px 16px;
  text-align: left;
  border-bottom: 2px solid var(--admin-border);
}

.admin-table td {
  padding: 16px;
  text-align: left;
  border-bottom: 1px solid var(--admin-border);
  font-size: 14px;
  color: var(--admin-text);
}

.admin-table tr:last-child td {
  border-bottom: none;
}

.admin-table tr:hover td {
  background: var(--admin-bg);
}

.admin-table .icon-cell {
  width: 40px;
  text-align: center;
}
```

- [ ] **Step 6: Update badge styles**

Replace `.admin-badge` styles (lines 187-205):

```css
/* Status Badges */
.admin-badge {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 12px;
  font-weight: 500;
}

.admin-badge-published {
  background: var(--admin-success-bg);
  color: var(--admin-success);
}

.admin-badge-published::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}

.admin-badge-draft {
  background: var(--admin-warning-bg);
  color: var(--admin-warning);
}

.admin-badge-draft::before {
  content: '';
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}
```

- [ ] **Step 7: Commit changes**

```bash
git add src/admin/styles/admin.css
git commit -m "style(admin): add sidebar layout, login redesign, and component styles"
```

---

## Task 3: Redesign dashboard.html with sidebar and stat cards

**Files:**
- Modify: `src/admin/dashboard.html`

- [ ] **Step 1: Rewrite dashboard.html with sidebar layout**

Replace entire file content with:

```html
<!DOCTYPE html>
<html lang="pt-PT">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dashboard - Admin</title>
  <link rel="stylesheet" href="/src/admin/styles/admin.css">
</head>
<body class="admin-dashboard">
  <!-- Sidebar -->
  <aside class="admin-sidebar">
    <div class="admin-sidebar-header">
      <div class="admin-sidebar-logo">
        <img src="/logo.png" alt="conheceFarma">
        <div>
          <h1>conheceFarma</h1>
          <p class="admin-sidebar-subtitle">Painel Administrativo</p>
        </div>
      </div>
    </div>
    
    <nav class="admin-nav-vertical">
      <a href="/src/admin/dashboard.html" class="active">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        Dashboard
      </a>
      <a href="/src/admin/artigos/index.html">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6M7 12h6" />
        </svg>
        Artigos
      </a>
      <a href="/src/admin/eventos/index.html">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
        </svg>
        Eventos
      </a>
      <a href="/src/admin/lives/index.html">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
        </svg>
        Lives
      </a>
    </nav>
    
    <div class="admin-sidebar-footer">
      <a href="#" id="logout-btn">
        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
        </svg>
        Sair
      </a>
    </div>
  </aside>

  <!-- Main Content -->
  <main class="admin-main-content">
    <!-- Top Bar -->
    <div class="admin-top-bar">
      <h1>Dashboard</h1>
      <div class="admin-user-menu">
        <div class="admin-user-info">
          <span class="admin-user-name">Administrador</span>
          <span class="admin-user-email">admin@exemplo.com</span>
        </div>
        <button class="admin-logout-btn" id="logout-btn-top">Sair</button>
      </div>
    </div>

    <!-- Content -->
    <div class="admin-content-container">
      <!-- Stats Grid -->
      <div class="admin-stats-grid">
        <div class="admin-stat-card">
          <h3>Artigos</h3>
          <div class="admin-stat-value" id="stat-articles">-</div>
          <div class="admin-stat-label">Publicados</div>
          <div class="admin-stat-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6M7 12h6" />
            </svg>
          </div>
        </div>
        
        <div class="admin-stat-card">
          <h3>Eventos</h3>
          <div class="admin-stat-value" id="stat-events">-</div>
          <div class="admin-stat-label">Publicados</div>
          <div class="admin-stat-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
          </div>
        </div>
        
        <div class="admin-stat-card">
          <h3>Lives</h3>
          <div class="admin-stat-value" id="stat-lives">-</div>
          <div class="admin-stat-label">Publicadas</div>
          <div class="admin-stat-icon">
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Recent Activity -->
      <div class="admin-card">
        <h2>Atividade Recente</h2>
        <table class="admin-table">
          <thead>
            <tr>
              <th>Utilizador</th>
              <th>Ação</th>
              <th>Tabela</th>
              <th>Data</th>
            </tr>
          </thead>
          <tbody id="recent-activity">
            <tr>
              <td colspan="4">Carregando...</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </main>

  <script type="module">
    import { checkAuth, logout } from './lib/auth.js';

    // Check authentication
    const session = await checkAuth();
    
    // Update user info if session exists
    if (session?.user?.email) {
      document.querySelector('.admin-user-email').textContent = session.user.email;
    }

    // Logout handler
    document.getElementById('logout-btn')?.addEventListener('click', (e) => {
      e.preventDefault();
      logout();
    });
    
    document.getElementById('logout-btn-top')?.addEventListener('click', (e) => {
      e.preventDefault();
      logout();
    });

    // Load stats
    async function loadStats() {
      const { supabaseClient } = await import('../config.js');

      // Count published articles
      const { count: articlesCount } = await supabaseClient
        .from('articles')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published');

      // Count published events
      const { count: eventsCount } = await supabaseClient
        .from('events')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published');

      // Count published lives
      const { count: livesCount } = await supabaseClient
        .from('lives')
        .select('*', { count: 'exact', head: true })
        .eq('status', 'published');

      document.getElementById('stat-articles').textContent = articlesCount || 0;
      document.getElementById('stat-events').textContent = eventsCount || 0;
      document.getElementById('stat-lives').textContent = livesCount || 0;
    }

    // Load recent activity
    async function loadRecentActivity() {
      const { supabaseClient } = await import('../config.js');
      const { data: session } = await supabaseClient.auth.getSession();

      const { data: logs } = await supabaseClient
        .from('audit_logs')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10);

      const tbody = document.getElementById('recent-activity');
      if (logs && logs.length > 0) {
        tbody.innerHTML = logs.map(log => `
          <tr>
            <td>${log.user_email || 'Sistema'}</td>
            <td>${log.action}</td>
            <td>${log.table_name}</td>
            <td>${new Date(log.created_at).toLocaleString('pt-PT')}</td>
          </tr>
        `).join('');
      } else {
        tbody.innerHTML = '<tr><td colspan="4">Sem atividade recente</td></tr>';
      }
    }

    loadStats();
    loadRecentActivity();
  </script>
</body>
</html>
```

- [ ] **Step 2: Commit changes**

```bash
git add src/admin/dashboard.html
git commit -m "feat(admin): redesign dashboard with sidebar navigation and stat cards"
```

---

## Task 4: Redesign login page (index.html)

**Files:**
- Modify: `src/admin/index.html`

- [ ] **Step 1: Rewrite login page with modern design**

Replace entire file content with:

```html
<!DOCTYPE html>
<html lang="pt-PT">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Login - conheceFarma</title>
  <link rel="stylesheet" href="/src/admin/styles/admin.css">
</head>
<body class="admin-login-page">
  <div class="admin-login-container">
    <div class="admin-login-box">
      <div class="admin-login-header">
        <img src="/logo.png" alt="conheceFarma" class="admin-login-logo">
        <h1>Área Administrativa</h1>
        <p style="color: var(--admin-text-muted); margin: 8px 0 0 0; font-size: 14px;">
          Aceda com as suas credenciais
        </p>
      </div>

      <form id="login-form" class="admin-login-form">
        <div class="admin-form-group">
          <label for="email">Email</label>
          <input
            type="email"
            id="email"
            name="email"
            required
            placeholder="admin@exemplo.com"
            class="admin-input"
          >
        </div>

        <div class="admin-form-group">
          <label for="password">Palavra-passe</label>
          <input
            type="password"
            id="password"
            name="password"
            required
            placeholder="••••••••"
            class="admin-input"
          >
        </div>

        <div id="login-error" class="admin-error-message" style="display: none;"></div>

        <button type="submit" class="admin-btn admin-btn-primary">
          Entrar
        </button>
      </form>
      
      <p style="text-align: center; margin-top: 24px; font-size: 13px; color: var(--admin-text-muted);">
        Acesso restrito a administradores autorizados
      </p>
    </div>
  </div>

  <script type="module" src="/src/admin/lib/auth.js"></script>
</body>
</html>
```

- [ ] **Step 2: Commit changes**

```bash
git add src/admin/index.html
git commit -m "feat(admin): redesign login page with centered layout and gradient background"
```

---

## Task 5: Update navigation in other admin pages

**Files:**
- Modify: `src/admin/artigos/index.html`
- Modify: `src/admin/eventos/index.html` (if exists)
- Modify: `src/admin/lives/index.html` (if exists)

- [ ] **Step 1: Update artigos/index.html navigation**

Read the file first, then update the `<header>` section to use the sidebar pattern.

Replace:
```html
<header class="admin-header">
  <div class="admin-logo">
    <h1>Gerir Artigos</h1>
  </div>
  <nav class="admin-nav">
    <a href="/src/admin/dashboard.html">Dashboard</a>
    <a href="/src/admin/artigos/index.html" class="active">Artigos</a>
    <a href="/src/admin/eventos/index.html">Eventos</a>
    <a href="/src/admin/lives/index.html">Lives</a>
    <a href="#" id="logout-btn">Sair</a>
  </nav>
</header>
```

With:
```html
<aside class="admin-sidebar">
  <div class="admin-sidebar-header">
    <div class="admin-sidebar-logo">
      <img src="/logo.png" alt="conheceFarma">
      <div>
        <h1>conheceFarma</h1>
        <p class="admin-sidebar-subtitle">Painel Administrativo</p>
      </div>
    </div>
  </div>
  
  <nav class="admin-nav-vertical">
    <a href="/src/admin/dashboard.html">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
      </svg>
      Dashboard
    </a>
    <a href="/src/admin/artigos/index.html" class="active">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9a2 2 0 00-2-2h-2m-4-3H9M7 16h6M7 8h6M7 12h6" />
      </svg>
      Artigos
    </a>
    <a href="/src/admin/eventos/index.html">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
      Eventos
    </a>
    <a href="/src/admin/lives/index.html">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
      </svg>
      Lives
    </a>
  </nav>
  
  <div class="admin-sidebar-footer">
    <a href="#" id="logout-btn">
      <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
      </svg>
      Sair
    </a>
  </div>
</aside>

<main class="admin-main-content">
  <div class="admin-top-bar">
    <h1>Gerir Artigos</h1>
    <div class="admin-user-menu">
      <div class="admin-user-info">
        <span class="admin-user-name">Administrador</span>
        <span class="admin-user-email">admin@exemplo.com</span>
      </div>
      <button class="admin-logout-btn" id="logout-btn-top">Sair</button>
    </div>
  </div>
  
  <div class="admin-content-container">
    <!-- Existing content here -->
```

Then update the `<body>` tag from `class="admin-dashboard"` to just use the structure above.

- [ ] **Step 2: Add script for logout**

Add at the bottom of the file (before closing `</body>`):

```html
<script type="module">
  import { logout } from '/src/admin/lib/auth.js';
  
  document.getElementById('logout-btn')?.addEventListener('click', (e) => {
    e.preventDefault();
    logout();
  });
  
  document.getElementById('logout-btn-top')?.addEventListener('click', (e) => {
    e.preventDefault();
    logout();
  });
</script>
```

- [ ] **Step 3: Commit changes**

```bash
git add src/admin/artigos/index.html
git commit -m "style(admin): update artigos page with sidebar navigation"
```

- [ ] **Step 4: Repeat for eventos and lives pages**

Apply the same pattern to `src/admin/eventos/index.html` and `src/admin/lives/index.html` if they exist.

```bash
git add src/admin/eventos/index.html src/admin/lives/index.html
git commit -m "style(admin): update eventos and lives pages with sidebar navigation"
```

---

## Task 6: Test and verify the redesign

**Files:**
- All modified admin files

- [ ] **Step 1: Start development server**

```bash
npm run dev
```

Expected: Server starts at http://localhost:5173

- [ ] **Step 2: Test login page**

Navigate to: `http://localhost:5173/src/admin/index.html`

Verify:
- [ ] Page has gradient background (green-teal)
- [ ] Login box is centered
- [ ] Logo displays correctly
- [ ] Form inputs have proper focus states
- [ ] Error messages display correctly

- [ ] **Step 3: Test dashboard**

After logging in, verify:
- [ ] Sidebar is visible with correct navigation
- [ ] Stat cards show counts with icons
- [ ] Recent activity table displays correctly
- [ ] Logout button works
- [ ] Responsive layout works on mobile

- [ ] **Step 4: Test navigation consistency**

Navigate to Artigos, Eventos, Lives pages and verify:
- [ ] All pages have consistent sidebar
- [ ] Active state is correct on nav items
- [ ] Logout works from all pages

- [ ] **Step 5: Run build**

```bash
npm run build
```

Expected: Build completes without errors

- [ ] **Step 6: Commit final changes**

```bash
git add .
git commit -m "chore(admin): final redesign verification and cleanup"
```

---

## Self-Review Checklist

**1. Spec coverage:**
- [x] Sidebar navigation - Task 2 (CSS) + Task 3 (dashboard.html)
- [x] Login page redesign - Task 2 (CSS) + Task 4 (index.html)
- [x] Stat cards with icons - Task 2 (CSS) + Task 3 (dashboard.html)
- [x] Brand colors - Task 1 (CSS variables)
- [x] Typography (Inter + JetBrains Mono) - Task 1 (CSS imports)
- [x] Navigation consistency - Task 5 (other pages)

**2. Placeholder scan:**
- [x] No "TBD" or "TODO" in plan
- [x] All code blocks contain complete code
- [x] All commands have expected output

**3. Type consistency:**
- [x] CSS variable names are consistent
- [x] Class names follow `admin-*` prefix pattern
- [x] Heroicons SVG format is consistent

---

**Plan complete and saved to `docs/superpowers/plans/2026-05-17-admin-cms-redesign.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**
