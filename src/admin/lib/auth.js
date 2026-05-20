// src/admin/lib/auth.js
import { supabaseClient } from '../../config.js';

// Helper: funciona em dev (/src/admin/) e produção (/admin/)
function isAdminLogin() {
  return window.location.pathname.endsWith('admin/index.html');
}

function isAdminPath() {
  return window.location.pathname.includes('/admin/');
}

/**
 * Verifica se o utilizador precisa de completar 2FA
 */
export async function needsMFA() {
  try {
    const { data, error } = await supabaseClient.auth.mfa.getAuthenticatorAssuranceLevel();
    if (error) return false;
    return data.nextLevel === 'aal2' && data.currentLevel !== 'aal2';
  } catch {
    return false;
  }
}

/**
 * Verifica código TOTP durante login
 */
export async function verifyTOTP(factorId, code) {
  const { data: factors } = await supabaseClient.auth.mfa.listFactors();
  const totpFactor = factors?.totp?.find(f => f.id === factorId);
  if (!totpFactor) throw new Error('Fator 2FA não encontrado.');

  const challenge = await supabaseClient.auth.mfa.challenge({ factorId });
  if (challenge.error) throw new Error(challenge.error.message);

  const verify = await supabaseClient.auth.mfa.verify({
    factorId,
    challengeId: challenge.data.id,
    code,
  });
  if (verify.error) throw new Error('Código inválido ou expirado.');

  return true;
}

/**
 * Lista fatores TOTP do utilizador atual
 */
export async function listMFAFactors() {
  const { data, error } = await supabaseClient.auth.mfa.listFactors();
  if (error) return [];
  return data.totp || [];
}

/**
 * Inicia o setup de 2FA — retorna QR code e factorId
 */
export async function enrollMFA() {
  const { data, error } = await supabaseClient.auth.mfa.enroll({
    factorType: 'totp',
  });
  if (error) throw new Error(error.message);
  return {
    factorId: data.id,
    qrCode: data.totp.qr_code,
    secret: data.totp.secret,
    uri: data.totp.uri,
  };
}

/**
 * Verifica código TOTP durante setup
 */
export async function verifyMFAEnrollment(factorId, code) {
  const challenge = await supabaseClient.auth.mfa.challenge({ factorId });
  if (challenge.error) throw new Error(challenge.error.message);

  const verify = await supabaseClient.auth.mfa.verify({
    factorId,
    challengeId: challenge.data.id,
    code,
  });
  if (verify.error) throw new Error('Código inválido. Tente novamente.');

  return true;
}

/**
 * Desativa 2FA para o utilizador
 */
export async function unenrollMFA(factorId) {
  const { error } = await supabaseClient.auth.mfa.unenroll({ factorId });
  if (error) throw new Error(error.message);
  return true;
}

/**
 * Obtém o perfil do admin atual (nome, email, role, recovery_email)
 */
export async function getAdminProfile() {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) return null;

  const { data, error } = await supabaseClient
    .from('admin_users')
    .select('*')
    .eq('user_id', session.user.id)
    .single();

  if (error) return null;

  return {
    userId: session.user.id,
    email: session.user.email,
    name: data.name || '',
    role: data.role || 'editor',
    recoveryEmail: data.recovery_email || '',
  };
}

/**
 * Atualiza o perfil do admin (nome e email de recuperação)
 */
export async function updateAdminProfile(name, recoveryEmail) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Sessão não encontrada.');

  const { error } = await supabaseClient
    .from('admin_users')
    .update({
      name: name.trim(),
      recovery_email: recoveryEmail.trim() || null,
    })
    .eq('user_id', session.user.id);

  if (error) throw new Error('Erro ao atualizar perfil.');
  return true;
}

/**
 * Altera a password do utilizador atual
 */
export async function changePassword(newPassword) {
  const { error } = await supabaseClient.auth.updateUser({
    password: newPassword,
  });
  if (error) throw new Error(error.message);
  return true;
}

/**
 * Atualiza o Top Bar com dados do perfil
 */
export function updateTopBar(profile) {
  if (!profile) return;

  const nameEl = document.querySelector('.admin-user-name');
  const emailEl = document.querySelector('.admin-user-email');
  const avatarEl = document.querySelector('.admin-user-avatar');

  if (nameEl) nameEl.textContent = profile.name || 'Administrador';
  if (emailEl) emailEl.textContent = profile.email || '';
  if (avatarEl) avatarEl.textContent = (profile.name || 'A').charAt(0).toUpperCase();
}

/**
 * Verifica a sessão atual e protege as rotas do Admin
 */
export async function checkAuth() {
  const currentPath = window.location.pathname;

  const { data: { session } } = await supabaseClient.auth.getSession();

  if (!session) {
    if (!isAdminLogin()) {
      window.location.href = isAdminPath() ? './index.html' : '/admin/index.html';
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
    if (!isAdminLogin()) {
      window.location.href = isAdminPath() ? './index.html' : '/admin/index.html';
    }
    return null;
  }

  // Se admin está na página de login com sessão válida, envia para o dashboard
  if (isAdminLogin()) {
    window.location.href = isAdminPath() ? './dashboard.html' : '/admin/dashboard.html';
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
  window.location.href = isAdminPath() ? './index.html' : '/admin/index.html';
}

// MED-08: Idle timeout - logout após 30 minutos de inatividade
const IDLE_TIMEOUT = 30 * 60 * 1000;
let idleTimer = null;

function resetIdleTimer() {
  clearTimeout(idleTimer);
  idleTimer = setTimeout(async () => {
    await logout();
  }, IDLE_TIMEOUT);
}

export function initIdleTimeout() {
  ['click', 'keydown', 'mousemove', 'scroll', 'touchstart'].forEach(evt =>
    document.addEventListener(evt, resetIdleTimer, { passive: true })
  );
  resetIdleTimer();
}

// Initialize login form
if (isAdminLogin()) {
  document.addEventListener('DOMContentLoaded', () => {
    const loginForm = document.getElementById('login-form');
    const errorDiv = document.getElementById('login-error');

    if (loginForm) {
      loginForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        errorDiv.classList.remove('visible');
        errorDiv.textContent = '';

        const btn = document.getElementById('login-btn');
        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;

        btn.classList.add('loading');

        try {
          await login(email, password);

          // Verificar se precisa de 2FA
          const mfaRequired = await needsMFA();
          if (mfaRequired) {
            const loginSection = document.getElementById('login-section');
            const mfaSection = document.getElementById('mfa-section');
            if (loginSection) loginSection.style.display = 'none';
            if (mfaSection) mfaSection.style.display = 'block';
            document.getElementById('totp-code')?.focus();
          } else {
            window.location.href = isAdminPath() ? './dashboard.html' : '/admin/dashboard.html';
          }
        } catch (error) {
          errorDiv.textContent = error.message;
          errorDiv.classList.add('visible');
          btn.classList.remove('loading');
        }
      });
    }

    // Handler para formulário TOTP (2FA)
    const mfaForm = document.getElementById('mfa-form');
    const mfaError = document.getElementById('mfa-error');

    if (mfaForm) {
      mfaForm.addEventListener('submit', async (e) => {
        e.preventDefault();
        const code = document.getElementById('totp-code')?.value?.trim();
        const submitBtn = mfaForm.querySelector('button[type="submit"]');

        if (mfaError) {
          mfaError.textContent = '';
          mfaError.classList.remove('visible');
        }

        if (!code || code.length !== 6) {
          if (mfaError) {
            mfaError.textContent = 'Introduza um código de 6 dígitos.';
            mfaError.classList.add('visible');
          }
          return;
        }

        if (submitBtn) {
          submitBtn.classList.add('loading');
          submitBtn.disabled = true;
        }

        try {
          const factors = await listMFAFactors();
          if (factors.length === 0) {
            throw new Error('Nenhum fator 2FA encontrado.');
          }
          await verifyTOTP(factors[0].id, code);
          window.location.href = isAdminPath() ? './dashboard.html' : '/admin/dashboard.html';
        } catch (error) {
          if (mfaError) {
            mfaError.textContent = error.message;
            mfaError.classList.add('visible');
          }
        } finally {
          if (submitBtn) {
            submitBtn.classList.remove('loading');
            submitBtn.disabled = false;
          }
        }
      });
    }
  });
}
