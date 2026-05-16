# CMS Admin Próprio - Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar painel admin próprio (/admin) com autenticação Supabase Auth, workflow Rascunho/Publicado, e migração de JSON para Supabase.

**Architecture:** 
- Site público lê apenas conteúdo com `status='published'` do Supabase
- Painel admin em `/admin/` com CSS independente e autenticação
- JSONs tornam-se fallback (backup read-only)
- Todas as ações gravadas em `audit_logs` para rastreabilidade

**Tech Stack:** Vite, Tailwind CSS, Supabase (Auth, Database, Storage), Vanilla JavaScript

---

## File Structure

### Novos Ficheiros a Criar
```
src/
├── admin/
│   ├── index.html              # Login page
│   ├── dashboard.html          # Dashboard após login
│   ├── artigos/
│   │   ├── index.html          # Lista de artigos
│   │   ├── new.html            # Criar artigo
│   │   └── edit.html           # Editar artigo
│   ├── eventos/
│   │   ├── index.html
│   │   ├── new.html
│   │   └── edit.html
│   ├── lives/
│   │   ├── index.html
│   │   ├── new.html
│   │   └── edit.html
│   ├── styles/
│   │   └── admin.css           # CSS exclusivo do admin
│   ├── lib/
│   │   ├── auth.js             # Autenticação Supabase Auth
│   │   ├── image-compressor.js # Compressão de imagens
│   │   └── audit-logger.js     # Logging de ações
│   ├── admin-articles.js       # CRUD artigos
│   ├── admin-events.js         # CRUD eventos
│   └── admin-lives.js          # CRUD lives
├── lib/
│   ├── api.js                  # Cliente API Supabase (site público)
│   └── fallback-data.js        # Fallback para JSON local
└── migrations/
    ├── 001-create-tables.sql       # Tabelas principais
    ├── 002-create-audit-logs.sql   # Tabela audit_logs
    └── 003-create-rls-policies.sql # Políticas RLS
```

### Ficheiros a Modificar
```
src/
├── articles-logic.js           # Adicionar filtro status='published'
├── event-detail.js             # Adicionar filtro status='published'
├── live-detail.js              # Adicionar filtro status='published'
├── content/
│   ├── articles-catalog.json   # Manter como fallback
│   ├── events-catalog.json     # Manter como fallback
│   └── lives-catalog.json      # Manter como fallback
└── config.js                   # Exportar funções partilhadas
```

---

## Task 1: Configuração da Database Supabase

### Task 1.1: Criar Tabelas Principais

**Files:**
- Create: `src/migrations/001-create-tables.sql`
- Modify: N/A (executar via Supabase SQL Editor ou CLI)

- [ ] **Step 1: Criar ficheiro de migration**

```sql
-- src/migrations/001-create-tables.sql
-- Migration: Create main content tables
-- Date: 2026-05-14

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Table: articles
CREATE TABLE IF NOT EXISTS articles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    excerpt TEXT,
    category TEXT NOT NULL,
    category_label TEXT NOT NULL,
    content TEXT NOT NULL,
    author_name TEXT,
    author_role TEXT,
    author_bio TEXT,
    author_avatar TEXT,
    author_avatar_bg TEXT,
    published_date DATE,
    read_time INTEGER,
    image_url TEXT,
    references TEXT[],
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: events
CREATE TABLE IF NOT EXISTS events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    excerpt TEXT,
    category TEXT NOT NULL,
    category_label TEXT NOT NULL,
    date DATE NOT NULL,
    time TIME,
    end_time TIME,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    location TEXT,
    type TEXT,
    capacity INTEGER,
    hosts JSONB,
    image_url TEXT,
    registration_link TEXT,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: lives
CREATE TABLE IF NOT EXISTS lives (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    slug TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    excerpt TEXT,
    category TEXT NOT NULL,
    category_label TEXT NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    end_time TIME,
    status TEXT DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
    platform TEXT,
    access_link TEXT,
    meeting_id TEXT,
    password TEXT,
    materials JSONB,
    host_name TEXT,
    host_role TEXT,
    host_organization TEXT,
    image_url TEXT,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table: admin_users
CREATE TABLE IF NOT EXISTS admin_users (
    user_id UUID REFERENCES auth.users(id) PRIMARY KEY,
    role TEXT DEFAULT 'editor',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS articles_status_idx ON articles(status);
CREATE INDEX IF NOT EXISTS articles_category_idx ON articles(category);
CREATE INDEX IF NOT EXISTS articles_published_date_idx ON articles(published_date);

CREATE INDEX IF NOT EXISTS events_status_idx ON events(status);
CREATE INDEX IF NOT EXISTS events_date_idx ON events(date);

CREATE INDEX IF NOT EXISTS lives_status_idx ON lives(status);
CREATE INDEX IF NOT EXISTS lives_date_idx ON lives(date);
```

- [ ] **Step 2: Executar migration no Supabase**

```bash
# Via Supabase CLI (se disponível)
supabase db push --db-url "postgresql://postgres:[PASSWORD]@db.[PROJECT_REF].supabase.co/postgres"

# OU via Supabase Dashboard:
# 1. Aceder a https://app.supabase.com/project/[PROJECT_ID]/editor
# 2. SQL Editor → New Query
# 3. Colar conteúdo de 001-create-tables.sql
# 4. Run
```

- [ ] **Step 3: Verificar tabelas criadas**

```bash
# No Supabase Dashboard → Table Editor
# Confirmar existência de: articles, events, lives, admin_users
```

---

### Task 1.2: Criar Tabela audit_logs

**Files:**
- Create: `src/migrations/002-create-audit-logs.sql`

- [ ] **Step 1: Criar ficheiro de migration**

```sql
-- src/migrations/002-create-audit-logs.sql
-- Migration: Create audit_logs table for tracking user actions
-- Date: 2026-05-14

-- Table: audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    user_email TEXT,
    action TEXT NOT NULL CHECK (action IN ('CREATE', 'UPDATE', 'DELETE', 'PUBLISH', 'UNPUBLISH')),
    table_name TEXT NOT NULL CHECK (table_name IN ('articles', 'events', 'lives')),
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS audit_logs_user_id_idx ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS audit_logs_created_at_idx ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS audit_logs_table_name_idx ON audit_logs(table_name);
CREATE INDEX IF NOT EXISTS audit_logs_record_id_idx ON audit_logs(record_id);

-- Function to log audit events
CREATE OR REPLACE FUNCTION log_audit_action(
    p_user_id UUID,
    p_user_email TEXT,
    p_action TEXT,
    p_table_name TEXT,
    p_record_id UUID,
    p_old_values JSONB,
    p_new_values JSONB
) RETURNS VOID AS $$
BEGIN
    INSERT INTO audit_logs (user_id, user_email, action, table_name, record_id, old_values, new_values)
    VALUES (p_user_id, p_user_email, p_action, p_table_name, p_record_id, p_old_values, p_new_values);
END;
$$ LANGUAGE plpgsql;
```

- [ ] **Step 2: Executar migration** (mesmo processo do Task 1.1)

---

### Task 1.3: Criar Políticas RLS (Row Level Security)

**Files:**
- Create: `src/migrations/003-create-rls-policies.sql`

- [ ] **Step 1: Criar ficheiro de migration**

```sql
-- src/migrations/003-create-rls-policies.sql
-- Migration: Create RLS policies for security
-- Date: 2026-05-14

-- Enable RLS on all tables
ALTER TABLE articles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE lives ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Articles Policies
-- ============================================

-- Public can read published articles
CREATE POLICY "Public can read published articles"
ON articles FOR SELECT
USING (status = 'published');

-- Admin users can read all articles
CREATE POLICY "Admin users can read all articles"
ON articles FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- Admin users can insert articles
CREATE POLICY "Admin users can insert articles"
ON articles FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- Admin users can update articles
CREATE POLICY "Admin users can update articles"
ON articles FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- Admin users can delete articles
CREATE POLICY "Admin users can delete articles"
ON articles FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- ============================================
-- Events Policies
-- ============================================

CREATE POLICY "Public can read published events"
ON events FOR SELECT
USING (status = 'published');

CREATE POLICY "Admin users can read all events"
ON events FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Admin users can insert events"
ON events FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Admin users can update events"
ON events FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Admin users can delete events"
ON events FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- ============================================
-- Lives Policies
-- ============================================

CREATE POLICY "Public can read published lives"
ON lives FOR SELECT
USING (status = 'published');

CREATE POLICY "Admin users can read all lives"
ON lives FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Admin users can insert lives"
ON lives FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Admin users can update lives"
ON lives FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

CREATE POLICY "Admin users can delete lives"
ON lives FOR DELETE
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- ============================================
-- Audit Logs Policies
-- ============================================

-- Users can read their own audit logs
CREATE POLICY "Users can read own audit logs"
ON audit_logs FOR SELECT
USING (user_id = auth.uid());

-- Insert audit logs (for admins)
CREATE POLICY "Admins can insert audit logs"
ON audit_logs FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);

-- ============================================
-- Admin Users Policies
-- ============================================

-- Public cannot read admin_users
-- Admin users can read admin_users
CREATE POLICY "Admin users can read admin_users"
ON admin_users FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM admin_users WHERE user_id = auth.uid()
    )
);
```

- [ ] **Step 2: Executar migration** (mesmo processo)

- [ ] **Step 3: Verificar políticas RLS**

```sql
-- No Supabase Dashboard → Authentication → Policies
-- Confirmar políticas criadas para todas as tabelas
```

---

## Task 2: Criar Estrutura do Admin

### Task 2.1: Criar Página de Login

**Files:**
- Create: `src/admin/index.html`
- Create: `src/admin/styles/admin.css`
- Create: `src/admin/lib/auth.js`

- [ ] **Step 1: Criar página de login**

```html
<!-- src/admin/index.html -->
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login - Conheça Farmácia</title>
    <link rel="stylesheet" href="/src/admin/styles/admin.css">
</head>
<body class="admin-login-page">
    <div class="admin-login-container">
        <div class="admin-login-box">
            <div class="admin-login-header">
                <img src="/logo.png" alt="Conheça Farmácia" class="admin-login-logo">
                <h1>Admin Login</h1>
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
                    <label for="password">Password</label>
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
        </div>
    </div>
    
    <script type="module" src="/src/admin/lib/auth.js"></script>
</body>
</html>
```

- [ ] **Step 2: Criar CSS do admin**

```css
/* src/admin/styles/admin.css */
/* Admin-only styles - not loaded on public pages */

:root {
    --admin-primary: #006171;
    --admin-primary-hover: #00493a;
    --admin-success: #0a844f;
    --admin-danger: #ff4d4d;
    --admin-warning: #ff6c23;
    --admin-bg: #f5f5f5;
    --admin-card-bg: #ffffff;
    --admin-text: #1a1a1a;
    --admin-border: #e0e0e0;
}

/* Login Page Layout */
.admin-login-page {
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, var(--admin-primary) 0%, var(--admin-primary-hover) 100%);
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

.admin-login-container {
    width: 100%;
    max-width: 400px;
    padding: 20px;
}

.admin-login-box {
    background: var(--admin-card-bg);
    border-radius: 12px;
    padding: 40px;
    box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
}

.admin-login-header {
    text-align: center;
    margin-bottom: 30px;
}

.admin-login-logo {
    width: 80px;
    height: 80px;
    margin-bottom: 20px;
}

.admin-login-header h1 {
    margin: 0;
    font-size: 24px;
    color: var(--admin-text);
}

.admin-form-group {
    margin-bottom: 20px;
}

.admin-form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 500;
    color: var(--admin-text);
}

.admin-input {
    width: 100%;
    padding: 12px 16px;
    border: 2px solid var(--admin-border);
    border-radius: 8px;
    font-size: 16px;
    transition: border-color 0.2s;
}

.admin-input:focus {
    outline: none;
    border-color: var(--admin-primary);
}

.admin-btn {
    width: 100%;
    padding: 14px 20px;
    border: none;
    border-radius: 8px;
    font-size: 16px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}

.admin-btn-primary {
    background: var(--admin-primary);
    color: white;
}

.admin-btn-primary:hover {
    background: var(--admin-primary-hover);
}

.admin-error-message {
    background: #fee;
    color: var(--admin-danger);
    padding: 12px 16px;
    border-radius: 8px;
    margin-bottom: 20px;
    border: 1px solid var(--admin-danger);
}

/* Dashboard Layout */
.admin-dashboard {
    min-height: 100vh;
    background: var(--admin-bg);
}

.admin-header {
    background: var(--admin-card-bg);
    padding: 20px 40px;
    border-bottom: 1px solid var(--admin-border);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.admin-nav {
    display: flex;
    gap: 20px;
}

.admin-nav a {
    color: var(--admin-text);
    text-decoration: none;
    font-weight: 500;
    padding: 8px 16px;
    border-radius: 6px;
    transition: background 0.2s;
}

.admin-nav a:hover,
.admin-nav a.active {
    background: var(--admin-bg);
}

.admin-content {
    max-width: 1400px;
    margin: 0 auto;
    padding: 40px 20px;
}

.admin-card {
    background: var(--admin-card-bg);
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
    margin-bottom: 24px;
}

.admin-card h2 {
    margin: 0 0 20px 0;
    font-size: 20px;
    color: var(--admin-text);
}

/* Table Styles */
.admin-table {
    width: 100%;
    border-collapse: collapse;
}

.admin-table th,
.admin-table td {
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid var(--admin-border);
}

.admin-table th {
    font-weight: 600;
    color: var(--admin-text);
    background: var(--admin-bg);
}

.admin-table tr:hover {
    background: var(--admin-bg);
}

/* Status Badges */
.admin-badge {
    display: inline-flex;
    align-items: center;
    padding: 4px 12px;
    border-radius: 999px;
    font-size: 14px;
    font-weight: 500;
}

.admin-badge-published {
    background: #e6f4ea;
    color: var(--admin-success);
}

.admin-badge-draft {
    background: #fff3e0;
    color: var(--admin-warning);
}

/* Buttons */
.admin-btn-sm {
    padding: 6px 12px;
    font-size: 14px;
}

.admin-btn-danger {
    background: var(--admin-danger);
    color: white;
}

.admin-btn-danger:hover {
    background: #ff3333;
}

/* Form Styles */
.admin-form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 20px;
    margin-bottom: 20px;
}

.admin-form-group--full {
    grid-column: 1 / -1;
}

.admin-textarea {
    width: 100%;
    min-height: 300px;
    padding: 12px 16px;
    border: 2px solid var(--admin-border);
    border-radius: 8px;
    font-family: 'Monaco', 'Consolas', monospace;
    font-size: 14px;
    resize: vertical;
}

.admin-textarea:focus {
    outline: none;
    border-color: var(--admin-primary);
}

/* Image Upload */
.admin-image-upload {
    border: 2px dashed var(--admin-border);
    border-radius: 8px;
    padding: 40px;
    text-align: center;
    cursor: pointer;
    transition: all 0.2s;
}

.admin-image-upload:hover {
    border-color: var(--admin-primary);
    background: var(--admin-bg);
}

.admin-image-preview {
    max-width: 100%;
    max-height: 300px;
    margin-top: 20px;
    border-radius: 8px;
}
```

- [ ] **Step 3: Criar módulo de autenticação**

```javascript
// src/admin/lib/auth.js
import { supabaseClient } from '../../config.js';

// Check if user is authenticated
export async function checkAuth() {
    const { data: { session } } = await supabaseClient.auth.getSession();
    
    if (!session) {
        // Redirect to login if not authenticated
        if (window.location.pathname !== '/src/admin/index.html') {
            window.location.href = '/src/admin/index.html';
        }
        return null;
    }
    
    // Check if user is admin
    const { data: adminUser } = await supabaseClient
        .from('admin_users')
        .select('*')
        .eq('user_id', session.user.id)
        .single();
    
    if (!adminUser) {
        // User is not an admin
        await supabaseClient.auth.signOut();
        alert('Acesso não autorizado. Utilizador não é admin.');
        window.location.href = '/src/admin/index.html';
        return null;
    }
    
    return session;
}

// Login handler
export async function login(email, password) {
    const { data, error } = await supabaseClient.auth.signInWithPassword({
        email,
        password,
    });
    
    if (error) {
        throw error;
    }
    
    // Verify user is admin
    const { data: adminUser } = await supabaseClient
        .from('admin_users')
        .select('*')
        .eq('user_id', data.user.id)
        .single();
    
    if (!adminUser) {
        await supabaseClient.auth.signOut();
        throw new Error('Utilizador não é admin');
    }
    
    return data;
}

// Logout handler
export async function logout() {
    await supabaseClient.auth.signOut();
    window.location.href = '/src/admin/index.html';
}

// Initialize login form
if (window.location.pathname === '/src/admin/index.html') {
    document.addEventListener('DOMContentLoaded', () => {
        const loginForm = document.getElementById('login-form');
        const errorDiv = document.getElementById('login-error');
        
        if (loginForm) {
            loginForm.addEventListener('submit', async (e) => {
                e.preventDefault();
                errorDiv.style.display = 'none';
                
                const email = document.getElementById('email').value;
                const password = document.getElementById('password').value;
                
                try {
                    await login(email, password);
                    window.location.href = '/src/admin/dashboard.html';
                } catch (error) {
                    errorDiv.textContent = error.message;
                    errorDiv.style.display = 'block';
                }
            });
        }
    });
}
```

- [ ] **Step 4: Commit**

```bash
git add src/admin/index.html src/admin/styles/admin.css src/admin/lib/auth.js
git commit -m "feat: add admin login page with Supabase Auth"
```

---

## Task 3: Criar Dashboard Admin

### Task 3.1: Dashboard com Stats e Navegação

**Files:**
- Create: `src/admin/dashboard.html`
- Modify: N/A

- [ ] **Step 1: Criar dashboard**

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
    <header class="admin-header">
        <div class="admin-logo">
            <h1>Admin Dashboard</h1>
        </div>
        <nav class="admin-nav">
            <a href="/src/admin/artigos/index.html">Artigos</a>
            <a href="/src/admin/eventos/index.html">Eventos</a>
            <a href="/src/admin/lives/index.html">Lives</a>
            <a href="#" id="logout-btn">Sair</a>
        </nav>
    </header>
    
    <main class="admin-content">
        <div class="admin-stats-grid">
            <div class="admin-card admin-stat-card">
                <h3>Artigos</h3>
                <div class="admin-stat-number" id="stat-articles">-</div>
                <div class="admin-stat-label">Publicados</div>
            </div>
            <div class="admin-card admin-stat-card">
                <h3>Eventos</h3>
                <div class="admin-stat-number" id="stat-events">-</div>
                <div class="admin-stat-label">Publicados</div>
            </div>
            <div class="admin-card admin-stat-card">
                <h3>Lives</h3>
                <div class="admin-stat-number" id="stat-lives">-</div>
                <div class="admin-stat-label">Publicadas</div>
            </div>
        </div>
        
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
    </main>
    
    <script type="module">
        import { checkAuth, logout } from './lib/auth.js';
        
        // Check authentication
        const session = await checkAuth();
        
        // Logout handler
        document.getElementById('logout-btn')?.addEventListener('click', (e) => {
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

- [ ] **Step 2: Commit**

```bash
git add src/admin/dashboard.html
git commit -m "feat: add admin dashboard with stats and activity"
```

---

## Task 4: CRUD de Artigos

### Task 4.1: Lista de Artigos

**Files:**
- Create: `src/admin/artigos/index.html`
- Create: `src/admin/admin-articles.js`

- [ ] **Step 1: Criar página de lista de artigos**

```html
<!-- src/admin/artigos/index.html -->
<!DOCTYPE html>
<html lang="pt-PT">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Artigos - Admin</title>
    <link rel="stylesheet" href="/src/admin/styles/admin.css">
</head>
<body class="admin-dashboard">
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
    
    <main class="admin-content">
        <div class="admin-card">
            <div class="admin-card-header">
                <h2>Lista de Artigos</h2>
                <a href="/src/admin/artigos/new.html" class="admin-btn admin-btn-primary">
                    + Novo Artigo
                </a>
            </div>
            
            <div class="admin-filters">
                <select id="filter-status" class="admin-input">
                    <option value="all">Todos Status</option>
                    <option value="published">Publicados</option>
                    <option value="draft">Rascunho</option>
                </select>
                <select id="filter-category" class="admin-input">
                    <option value="all">Todas Categorias</option>
                    <option value="profissionais">Para Profissionais</option>
                    <option value="voce-sabia">Você Sabia?</option>
                    <option value="conheca-medicamento">Conheça o Medicamento</option>
                    <option value="curiosidades">Curiosidades</option>
                    <option value="saude">Saúde</option>
                </select>
            </div>
            
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Título</th>
                        <th>Categoria</th>
                        <th>Status</th>
                        <th>Data</th>
                        <th>Autor</th>
                        <th>Ações</th>
                    </tr>
                </thead>
                <tbody id="articles-table">
                    <tr>
                        <td colspan="6">Carregando...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </main>
    
    <script type="module" src="/src/admin/admin-articles.js"></script>
</body>
</html>
```

- [ ] **Step 2: Criar lógica de listagem**

```javascript
// src/admin/admin-articles.js
import { supabaseClient } from '../config.js';
import { checkAuth } from './lib/auth.js';

// Check authentication
await checkAuth();

// Load articles
async function loadArticles() {
    const { data: articles, error } = await supabaseClient
        .from('articles')
        .select('*')
        .order('created_at', { ascending: false });
    
    if (error) {
        console.error('Erro ao carregar artigos:', error);
        return;
    }
    
    renderArticles(articles);
}

// Render articles table
function renderArticles(articles) {
    const tbody = document.getElementById('articles-table');
    
    if (!articles || articles.length === 0) {
        tbody.innerHTML = '<tr><td colspan="6">Nenhum artigo encontrado</td></tr>';
        return;
    }
    
    tbody.innerHTML = articles.map(article => `
        <tr>
            <td>${escapeHtml(article.title)}</td>
            <td>${article.category_label}</td>
            <td>
                <span class="admin-badge admin-badge-${article.status}">
                    ${article.status === 'published' ? 'Publicado' : 'Rascunho'}
                </span>
            </td>
            <td>${formatDate(article.published_date)}</td>
            <td>${escapeHtml(article.author_name || '-')}</td>
            <td>
                <a href="/src/admin/artigos/edit.html?id=${article.id}" class="admin-btn admin-btn-sm">
                    Editar
                </a>
                <button onclick="deleteArticle('${article.id}')" class="admin-btn admin-btn-sm admin-btn-danger">
                    Excluir
                </button>
            </td>
        </tr>
    `).join('');
}

// Helper functions
function escapeHtml(text) {
    if (!text) return '';
    return text.replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function formatDate(dateStr) {
    if (!dateStr) return '-';
    const date = new Date(dateStr);
    return date.toLocaleDateString('pt-PT');
}

// Delete article
window.deleteArticle = async function(id) {
    if (!confirm('Tem certeza que deseja excluir este artigo?')) return;
    
    const { error } = await supabaseClient
        .from('articles')
        .delete()
        .eq('id', id);
    
    if (error) {
        alert('Erro ao excluir: ' + error.message);
    } else {
        loadArticles();
    }
};

// Initialize
loadArticles();
```

- [ ] **Step 3: Commit**

```bash
git add src/admin/artigos/index.html src/admin/admin-articles.js
git commit -m "feat: add articles list page with CRUD operations"
```

---

## Task 5: Criar/Editar Artigos

### Task 5.1: Formulário de Criação/Edição

**Files:**
- Create: `src/admin/artigos/new.html`
- Create: `src/admin/artigos/edit.html`
- Create: `src/admin/lib/image-compressor.js`

- [ ] **Step 1: Criar compressor de imagens**

```javascript
// src/admin/lib/image-compressor.js

/**
 * Compress image before upload
 * @param {File} file - Image file to compress
 * @param {number} maxWidth - Maximum width (default: 1200px)
 * @param {number} quality - JPEG quality 0-1 (default: 0.8)
 * @returns {Promise<Blob>} Compressed image blob
 */
export async function compressImage(file, maxWidth = 1200, quality = 0.8) {
    return new Promise((resolve) => {
        const img = new Image();
        img.src = URL.createObjectURL(file);
        
        img.onload = () => {
            const canvas = document.createElement('canvas');
            let width = img.width;
            let height = img.height;
            
            // Resize if width > maxWidth
            if (width > maxWidth) {
                height = (maxWidth / width) * height;
                width = maxWidth;
            }
            
            canvas.width = width;
            canvas.height = height;
            
            const ctx = canvas.getContext('2d');
            ctx.drawImage(img, 0, 0, width, height);
            
            canvas.toBlob(
                (blob) => {
                    URL.revokeObjectURL(img.src);
                    resolve(blob);
                },
                file.type,
                quality
            );
        };
        
        img.onerror = () => {
            URL.revokeObjectURL(img.src);
            resolve(file); // Return original if compression fails
        };
    });
}

/**
 * Upload image to Supabase Storage
 * @param {Blob} file - Image blob
 * @param {string} bucket - Storage bucket name
 * @param {string} fileName - File name
 * @returns {Promise<{url: string, error?: string}>}
 */
export async function uploadImage(file, bucket, fileName) {
    const { supabaseClient } = await import('../../config.js');
    
    const { data, error } = await supabaseClient.storage
        .from(bucket)
        .upload(fileName, file, {
            cacheControl: '3600',
            upsert: true,
        });
    
    if (error) {
        return { url: null, error: error.message };
    }
    
    // Get public URL
    const { data: { publicUrl } } = supabaseClient.storage
        .from(bucket)
        .getPublicUrl(fileName);
    
    return { url: publicUrl, error: null };
}
```

- [ ] **Step 2: Criar logger de auditoria**

```javascript
// src/admin/lib/audit-logger.js
import { supabaseClient } from '../../config.js';

/**
 * Log an audit event
 * @param {string} action - CREATE | UPDATE | DELETE | PUBLISH | UNPUBLISH
 * @param {string} tableName - articles | events | lives
 * @param {string} recordId - UUID of the record
 * @param {object} oldValues - Previous values (for UPDATE/DELETE)
 * @param {object} newValues - New values (for CREATE/UPDATE)
 */
export async function logAudit(action, tableName, recordId, oldValues = null, newValues = null) {
    try {
        const { data: { session } } = await supabaseClient.auth.getSession();
        
        if (!session?.user) {
            console.warn('No session for audit log');
            return;
        }
        
        // Insert audit log
        await supabaseClient
            .from('audit_logs')
            .insert({
                user_id: session.user.id,
                user_email: session.user.email,
                action,
                table_name: tableName,
                record_id: recordId,
                old_values: oldValues ? JSON.parse(JSON.stringify(oldValues)) : null,
                new_values: newValues ? JSON.parse(JSON.stringify(newValues)) : null,
            });
    } catch (error) {
        console.error('Failed to log audit:', error);
        // Don't throw - audit logging failure shouldn't break main operation
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add src/admin/lib/image-compressor.js src/admin/lib/audit-logger.js
git commit -m "feat: add image compression and audit logging utilities"
```

---

## Task 6: Migração de Dados JSON → Supabase

### Task 6.1: Script de Migração

**Files:**
- Create: `src/migrations/migrate-json-to-supabase.js`
- Create: `src/migrations/backup-articles.json`
- Create: `src/migrations/backup-events.json`
- Create: `src/migrations/backup-lives.json`

- [ ] **Step 1: Criar script de migração**

```javascript
// src/migrations/migrate-json-to-supabase.js
/**
 * Migration Script: JSON → Supabase
 * 
 * INSTRUCTIONS:
 * 1. Run in browser console on admin page
 * 2. Or run with Node.js (requires @supabase/supabase-js)
 * 
 * This script will:
 * 1. Backup current JSON data
 * 2. Migrate to Supabase with status='published'
 * 3. Verify migration
 */

import articlesData from '../content/articles-catalog.json' assert { type: 'json' };
import eventsData from '../content/events-catalog.json' assert { type: 'json' };
import livesData from '../content/lives-catalog.json' assert { type: 'json' };
import { supabaseClient } from '../config.js';

// Migrate articles
async function migrateArticles() {
    console.log('Migrating articles...');
    
    for (const article of articlesData.articles) {
        const { error } = await supabaseClient.from('articles').insert({
            slug: article.slug,
            title: article.title,
            excerpt: article.excerpt,
            category: article.category,
            category_label: article.categoryLabel,
            content: article.content,
            author_name: article.author?.name,
            author_role: article.author?.role,
            author_bio: article.author?.bio,
            author_avatar: article.author?.avatar,
            author_avatar_bg: article.author?.avatarBg,
            published_date: article.date,
            read_time: article.readTime,
            image_url: article.image,
            references: article.references || [],
            status: 'published', // All existing articles published
            published_at: new Date().toISOString(),
        });
        
        if (error) {
            console.error(`Error migrating article ${article.slug}:`, error);
        } else {
            console.log(`✓ Migrated: ${article.slug}`);
        }
    }
}

// Migrate events
async function migrateEvents() {
    console.log('Migrating events...');
    
    for (const event of eventsData.events) {
        const { error } = await supabaseClient.from('events').insert({
            slug: event.slug,
            title: event.title,
            excerpt: event.excerpt,
            category: event.category,
            category_label: event.categoryLabel,
            date: event.date,
            time: event.time,
            end_time: event.end_time,
            location: event.location,
            type: event.type,
            capacity: event.capacity,
            hosts: event.hosts || [],
            image_url: event.image,
            registration_link: event.registrationLink,
            status: 'published',
            published_at: new Date().toISOString(),
        });
        
        if (error) {
            console.error(`Error migrating event ${event.slug}:`, error);
        } else {
            console.log(`✓ Migrated: ${event.slug}`);
        }
    }
}

// Migrate lives
async function migrateLives() {
    console.log('Migrating lives...');
    
    for (const live of livesData.events) {
        const { error } = await supabaseClient.from('lives').insert({
            slug: live.slug,
            title: live.title,
            excerpt: live.resumo,
            category: live.categoria,
            category_label: live.categoriaLabel,
            date: live.data,
            time: live.hora,
            platform: live.plataforma,
            access_link: live.link_acesso,
            meeting_id: live.id_reuniao,
            password: live.senha,
            materials: live.materiais_apoio,
            host_name: live.anfitriao?.nome,
            host_role: live.anfitriao?.cargo,
            host_organization: live.anfitriao?.organizacao,
            image_url: live.imagem,
            status: 'published',
            published_at: new Date().toISOString(),
        });
        
        if (error) {
            console.error(`Error migrating live ${live.slug}:`, error);
        } else {
            console.log(`✓ Migrated: ${live.slug}`);
        }
    }
}

// Run migration
async function runMigration() {
    console.log('🚀 Starting migration...');
    
    await migrateArticles();
    await migrateEvents();
    await migrateLives();
    
    console.log('✅ Migration complete!');
}

// Export for use
export { runMigration };

// Auto-run if in browser
if (typeof window !== 'undefined') {
    runMigration();
}
```

- [ ] **Step 2: Backup JSON files**

```bash
# Copy current JSON to backup
cp src/content/articles-catalog.json src/migrations/backup-articles.json
cp src/content/events-catalog.json src/migrations/backup-events.json
cp src/content/lives-catalog.json src/migrations/backup-lives.json

# Commit backups
git add src/migrations/backup-*.json
git commit -m "chore: backup JSON data before migration"
```

- [ ] **Step 3: Run migration**

```bash
# Option A: Run in browser console on admin page
# Open /src/admin/dashboard.html in browser
# Then run:
import { runMigration } from './migrate-json-to-supabase.js';
runMigration();

# Option B: Run with Node.js
node src/migrations/migrate-json-to-supabase.js
```

- [ ] **Step 4: Verify migration**

```sql
-- In Supabase Dashboard → SQL Editor
SELECT COUNT(*) as total, status FROM articles GROUP BY status;
SELECT COUNT(*) as total, status FROM events GROUP BY status;
SELECT COUNT(*) as total, status FROM lives GROUP BY status;
```

- [ ] **Step 5: Commit migration**

```bash
git add src/migrations/migrate-json-to-supabase.js
git commit -m "feat: add JSON to Supabase migration script"
```

---

## Task 7: Atualizar Site Público

### Task 7.1: Atualizar articles-logic.js

**Files:**
- Modify: `src/articles-logic.js`
- Create: `src/lib/api.js`
- Create: `src/lib/fallback-data.js`

- [ ] **Step 1: Criar API client**

```javascript
// src/lib/api.js
import { supabaseClient } from '../config.js';

/**
 * Fetch published articles from Supabase
 * @returns {Promise<Array>}
 */
export async function getArticles() {
    try {
        const { data, error } = await supabaseClient
            .from('articles')
            .select('*')
            .eq('status', 'published')
            .order('published_date', { ascending: false });
        
        if (error) throw error;
        return data || [];
    } catch (error) {
        console.error('Error fetching articles:', error);
        // Fallback to local JSON
        const { getFallbackArticles } = await import('./fallback-data.js');
        return getFallbackArticles();
    }
}

/**
 * Fetch single article by slug
 * @param {string} slug
 * @returns {Promise<Object|null>}
 */
export async function getArticleBySlug(slug) {
    try {
        const { data, error } = await supabaseClient
            .from('articles')
            .select('*')
            .eq('slug', slug)
            .eq('status', 'published')
            .single();
        
        if (error) throw error;
        return data;
    } catch (error) {
        console.error('Error fetching article:', error);
        // Fallback to local JSON
        const { getFallbackArticleBySlug } = await import('./fallback-data.js');
        return getFallbackArticleBySlug(slug);
    }
}
```

- [ ] **Step 2: Criar fallback data module**

```javascript
// src/lib/fallback-data.js
import articlesData from '../content/articles-catalog.json';
import eventsData from '../content/events-catalog.json';
import livesData from '../content/lives-catalog.json';

/**
 * Get articles from local JSON (fallback)
 */
export function getFallbackArticles() {
    return articlesData.articles || [];
}

/**
 * Get single article from local JSON
 */
export function getFallbackArticleBySlug(slug) {
    return (articlesData.articles || []).find(a => a.slug === slug) || null;
}

/**
 * Get events from local JSON (fallback)
 */
export function getFallbackEvents() {
    return eventsData.events || [];
}

/**
 * Get lives from local JSON (fallback)
 */
export function getFallbackLives() {
    return livesData.events || [];
}
```

- [ ] **Step 3: Atualizar articles-logic.js**

```javascript
// src/articles-logic.js
// Replace import:
// import articlesData from "./content/articles-catalog.json";

// With:
import { getArticles } from './lib/api.js';

// Change initialization:
let articles = [];
let currentFilter = "all";
let searchTerm = "";

document.addEventListener("DOMContentLoaded", async () => {
    const grid = document.getElementById("articles-grid");
    const noResults = document.getElementById("no-results");
    const searchInput = document.getElementById("search-input");
    const filterButtons = document.querySelectorAll(".filter-btn");
    
    // Fetch articles from Supabase
    articles = await getArticles();
    
    // Rest of the code remains the same...
    renderArticles();
});
```

- [ ] **Step 4: Commit**

```bash
git add src/lib/api.js src/lib/fallback-data.js src/articles-logic.js
git commit -m "feat: update site to read from Supabase with JSON fallback"
```

---

## Task 8: Configurar Supabase Auth

### Task 8.1: Criar Utilizadores Admin

**Files:**
- N/A (configuração manual no Supabase Dashboard)

- [ ] **Step 1: Aceder ao Supabase Dashboard**

```
1. Aceder a https://app.supabase.com
2. Selecionar projeto
3. Authentication → Users
```

- [ ] **Step 2: Criar utilizadores admin**

```
1. Click "Add user"
2. Preencher email e password
3. Confirm email (se necessário)
4. Copiar User ID
```

- [ ] **Step 3: Adicionar à tabela admin_users**

```sql
-- No SQL Editor do Supabase
INSERT INTO admin_users (user_id, role)
VALUES 
    ('UUID-DO-UTILIZADOR-1', 'admin'),
    ('UUID-DO-UTILIZADOR-2', 'editor');
```

- [ ] **Step 4: Testar login**

```
1. Aceder a /src/admin/index.html
2. Fazer login com credenciais
3. Confirmar redirect para dashboard
```

---

## Task 9: Testes e Validação

### Task 9.1: Testes Manuais

**Files:**
- Create: `docs/test-checklist.md`

- [ ] **Step 1: Criar checklist de testes**

```markdown
# Test Checklist - CMS Admin

## Authentication
- [ ] Login com email/password funciona
- [ ] Utilizador não-admin é rejeitado
- [ ] Logout funciona
- [ ] Sessão expira corretamente

## Artigos
- [ ] Listar artigos (todos, publicados, rascunho)
- [ ] Criar novo artigo
- [ ] Editar artigo existente
- [ ] Publicar/Despublicar artigo
- [ ] Excluir artigo
- [ ] Upload de imagem com compressão
- [ ] Preencher referências (array)
- [ ] Histórico de auditoria gravado

## Eventos
- [ ] Listar eventos
- [ ] Criar novo evento
- [ ] Editar evento
- [ ] Publicar/Despublicar evento
- [ ] Excluir evento

## Lives
- [ ] Listar lives
- [ ] Criar nova live
- [ ] Editar live
- [ ] Publicar/Despublicar live
- [ ] Excluir live

## Site Público
- [ ] Artigos.html mostra apenas publicados
- [ ] Artigo.html carrega conteúdo correto
- [ ] Eventos.html mostra apenas publicados
- [ ] Lives.html mostra apenas publicadas
- [ ] Fallback para JSON funciona se Supabase falhar

## Audit Logs
- [ ] Todas ações gravadas na tabela audit_logs
- [ ] Dashboard mostra atividade recente
- [ ] Utilizador correto registado
```

- [ ] **Step 2: Executar testes**

```bash
# Testar em ambiente local
npm run dev

# Abrir browser
# http://localhost:5173/src/admin/index.html
# http://localhost:5173/artigos.html
```

- [ ] **Step 3: Commit**

```bash
git add docs/test-checklist.md
git commit -m "docs: add test checklist for CMS admin"
```

---

## Task 10: Documentação Final

### Task 10.1: README do Admin

**Files:**
- Create: `src/admin/README.md`

- [ ] **Step 1: Criar documentação**

```markdown
# Admin CMS - Conheça Farmácia

## Visão Geral

Painel administrativo para gerir conteúdo do site (artigos, eventos, lives).

## Acesso

- URL: `/src/admin/index.html`
- Autenticação: Supabase Auth
- Apenas utilizadores na tabela `admin_users` podem aceder

## Funcionalidades

### Artigos
- Criar, editar, publicar, excluir artigos
- Upload de imagens com compressão automática
- Workflow Rascunho → Publicado
- Referências bibliográficas

### Eventos
- Gerir eventos futuros
- Capacidade e inscrições
- Múltiplos anfitriões

### Lives
- Gerir transmissões ao vivo
- Links de acesso
- Materiais de apoio

## Audit Logs

Todas as ações são registadas na tabela `audit_logs`:
- CREATE, UPDATE, DELETE, PUBLISH, UNPUBLISH
- Utilizador, data/hora, valores anteriores e novos

## Migração de Dados

Para migrar de/para JSON:
```bash
# Backup
cp src/content/articles-catalog.json src/migrations/backup-articles.json

# Restaurar (se necessário)
# Ver script de migration
```

## Segurança

- RLS (Row Level Security) ativo em todas as tabelas
- Apenas admins podem criar/editar conteúdo
- Público lê apenas conteúdo publicado
```

- [ ] **Step 2: Commit final**

```bash
git add src/admin/README.md
git commit -m "docs: add admin documentation"
```

---

## Testing

- [ ] **Step 1: Test all CRUD operations**
- [ ] **Step 2: Test image upload and compression**
- [ ] **Step 3: Test audit logging**
- [ ] **Step 4: Test RLS policies**
- [ ] **Step 5: Test fallback to JSON**

---

## Deployment Checklist

- [ ] Environment variables configured
- [ ] Database migrations applied
- [ ] Admin users created
- [ ] Storage buckets configured
- [ ] RLS policies verified
- [ ] Backup strategy in place

---

## Self-Review Checklist

- [ ] All file paths are explicit
- [ ] No placeholders (TBD, TODO)
- [ ] Code examples are complete
- [ ] Test steps are actionable
- [ ] Migration steps are clear
- [ ] Security considerations addressed

