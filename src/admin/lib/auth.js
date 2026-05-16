// src/admin/lib/auth.js
import { supabaseClient } from '../../config.js';

/**
 * Verifica a sessão atual e protege as rotas do Admin
 */
export async function checkAuth() {
  const currentPath = window.location.pathname;

  const { data: { session } } = await supabaseClient.auth.getSession();

  if (!session) {
    if (!currentPath.includes('/src/admin/index.html')) {
      window.location.href = '/src/admin/index.html';
    }
    return null;
  }

  // Verifica se o utilizador é admin
  const { data: adminUsers, error: adminError } = await supabaseClient
    .from('admin_users')
    .select('*')
    .eq('user_id', session.user.id);

  if (adminError || !adminUsers || adminUsers.length === 0) {
    await supabaseClient.auth.signOut();
    if (!currentPath.includes('/src/admin/index.html')) {
      window.location.href = '/src/admin/index.html';
    }
    return null;
  }

  // Se admin está na página de login com sessão válida, envia para o dashboard
  if (currentPath.includes('/src/admin/index.html')) {
    window.location.href = '/src/admin/dashboard.html';
  }

  return session;
}

/**
 * Login handler
 */
export async function login(email, password) {
  const { data, error } = await supabaseClient.auth.signInWithPassword({
    email,
    password,
  });

  if (error) {
    throw new Error('Email ou palavra-passe incorretos.');
  }

  // Verifica se o utilizador é admin
  const { data: adminUsers, error: adminError } = await supabaseClient
    .from('admin_users')
    .select('*')
    .eq('user_id', data.user.id);

  if (adminError || !adminUsers || adminUsers.length === 0) {
    await supabaseClient.auth.signOut();
    throw new Error('Acesso negado: Este utilizador não é administrador.');
  }

  return data;
}

/**
 * Logout handler
 */
export async function logout() {
  await supabaseClient.auth.signOut();
  window.location.href = '/src/admin/index.html';
}

// Initialize login form
if (window.location.pathname.includes('/src/admin/index.html')) {
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
