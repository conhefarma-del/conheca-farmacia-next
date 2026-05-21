// src/admin/definicoes.js
import { supabaseClient } from '../config.js';
import { checkAuth, logout, initIdleTimeout, getAdminProfile, updateAdminProfile, changePassword, updateTopBar, listMFAFactors, enrollMFA, verifyMFAEnrollment, unenrollMFA } from './lib/auth.js';

let currentFactorId = null;

// Inicializar
document.addEventListener('DOMContentLoaded', async () => {
  await checkAuth();
  initIdleTimeout();

  // Lucide icons (handled by inline script)

  // Logout
  document.getElementById('logout-btn')?.addEventListener('click', async (e) => {
    e.preventDefault();
    await logout();
  });

  // Carregar perfil do admin
  const profile = await getAdminProfile();
  if (profile) {
    updateTopBar(profile);
    loadProfileForm(profile);
  }

  // Carregar estado 2FA
  await loadMFAStatus();
});

async function loadMFAStatus() {
  const statusDiv = document.getElementById('mfa-status');
  const enableBtn = document.getElementById('mfa-enable-btn');
  const disableBtn = document.getElementById('mfa-disable-btn');
  const setupDiv = document.getElementById('mfa-setup');

  try {
    const factors = await listMFAFactors();
    const hasMFA = factors.length > 0;

    if (hasMFA) {
      statusDiv.className = 'settings-2fa-status enabled';
      statusDiv.innerHTML = '<i data-lucide="shield-check" width="20" height="20"></i><span>2FA está ativado</span>';
      enableBtn.style.display = 'none';
      disableBtn.style.display = 'inline-flex';
      setupDiv.style.display = 'none';
      currentFactorId = factors[0].id;
    } else {
      statusDiv.className = 'settings-2fa-status disabled';
      statusDiv.innerHTML = '<i data-lucide="shield-off" width="20" height="20"></i><span>2FA está desativado</span>';
      enableBtn.style.display = 'inline-flex';
      disableBtn.style.display = 'none';
      setupDiv.style.display = 'none';
    }

    if (window.lucide) lucide.createIcons();
  } catch (error) {
    if (import.meta.env.DEV) console.error('Erro ao carregar estado 2FA:', error);
  }
}

function loadProfileForm(profile) {
  document.getElementById('profile-name').value = profile.name || '';
  document.getElementById('profile-email').value = profile.email || '';
  document.getElementById('profile-recovery-email').value = profile.recoveryEmail || '';
}

// Botões de editar nos campos de perfil
document.querySelectorAll('.settings-edit-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const targetId = btn.dataset.target;
    const input = document.getElementById(targetId);
    if (!input) return;

    input.disabled = false;
    input.focus();
    btn.style.display = 'none';
    document.getElementById('profile-actions').style.display = 'flex';
  });
});

// Botão Cancelar edição de perfil
document.getElementById('profile-cancel')?.addEventListener('click', async () => {
  const profile = await getAdminProfile();
  if (profile) loadProfileForm(profile);

  document.querySelectorAll('#profile-name, #profile-recovery-email').forEach(input => {
    input.disabled = true;
  });
  document.querySelectorAll('.settings-edit-btn').forEach(btn => {
    btn.style.display = '';
  });
  document.getElementById('profile-actions').style.display = 'none';
  document.getElementById('profile-success').style.display = 'none';
  document.getElementById('profile-error').style.display = 'none';
});

// Formulário de Perfil
document.getElementById('profile-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const name = document.getElementById('profile-name').value;
  const recoveryEmail = document.getElementById('profile-recovery-email').value;
  const successDiv = document.getElementById('profile-success');
  const errorDiv = document.getElementById('profile-error');

  successDiv.style.display = 'none';
  errorDiv.style.display = 'none';

  try {
    await updateAdminProfile(name, recoveryEmail);
    const profile = await getAdminProfile();
    if (profile) updateTopBar(profile);

    // Desativar campos após guardar
    document.querySelectorAll('#profile-name, #profile-recovery-email').forEach(input => {
      input.disabled = true;
    });
    document.querySelectorAll('.settings-edit-btn').forEach(btn => {
      btn.style.display = '';
    });
    document.getElementById('profile-actions').style.display = 'none';

    successDiv.textContent = 'Perfil atualizado com sucesso.';
    successDiv.style.display = 'block';
  } catch (error) {
    errorDiv.textContent = error.message;
    errorDiv.style.display = 'block';
  }
});

// Formulário de Password
document.getElementById('password-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();
  const currentPassword = document.getElementById('current-password').value;
  const newPassword = document.getElementById('new-password').value;
  const confirmPassword = document.getElementById('confirm-password').value;
  const successDiv = document.getElementById('password-success');
  const errorDiv = document.getElementById('password-error');

  successDiv.style.display = 'none';
  errorDiv.style.display = 'none';

  if (!currentPassword) {
    errorDiv.textContent = 'Introduza a password atual.';
    errorDiv.style.display = 'block';
    return;
  }

  if (newPassword !== confirmPassword) {
    errorDiv.textContent = 'As passwords não coincidem.';
    errorDiv.style.display = 'block';
    return;
  }

  if (newPassword.length < 6) {
    errorDiv.textContent = 'A password deve ter pelo menos 6 caracteres.';
    errorDiv.style.display = 'block';
    return;
  }

  try {
    // Verificar password atual fazendo login
    const { data: { session } } = await supabaseClient.auth.getSession();
    if (!session) throw new Error('Sessão não encontrada.');

    const { error: signInError } = await supabaseClient.auth.signInWithPassword({
      email: session.user.email,
      password: currentPassword,
    });

    if (signInError) {
      errorDiv.textContent = 'Password atual incorreta.';
      errorDiv.style.display = 'block';
      return;
    }

    await changePassword(newPassword);
    document.getElementById('current-password').value = '';
    document.getElementById('new-password').value = '';
    document.getElementById('confirm-password').value = '';
    successDiv.textContent = 'Password alterada com sucesso.';
    successDiv.style.display = 'block';
  } catch (error) {
    errorDiv.textContent = error.message;
    errorDiv.style.display = 'block';
  }
});

// Botão Ativar 2FA
document.getElementById('mfa-enable-btn')?.addEventListener('click', async () => {
  const setupDiv = document.getElementById('mfa-setup');
  const errorDiv = document.getElementById('mfa-verify-error');
  errorDiv.textContent = '';
  errorDiv.classList.remove('visible');

  try {
    const enrollment = await enrollMFA();
    currentFactorId = enrollment.factorId;

    document.getElementById('mfa-qr-img').src = enrollment.qrCode;
    document.getElementById('mfa-secret').textContent = enrollment.secret;
    setupDiv.style.display = 'block';
    document.getElementById('mfa-verify-code').focus();
  } catch (error) {
    errorDiv.textContent = error.message;
    errorDiv.classList.add('visible');
  }
});

// Botão Confirmar e Ativar
document.getElementById('mfa-verify-btn')?.addEventListener('click', async () => {
  const code = document.getElementById('mfa-verify-code').value.trim();
  const errorDiv = document.getElementById('mfa-verify-error');
  errorDiv.textContent = '';
  errorDiv.classList.remove('visible');

  if (!code || code.length !== 6) {
    errorDiv.textContent = 'Introduza um código de 6 dígitos.';
    errorDiv.classList.add('visible');
    return;
  }

  try {
    await verifyMFAEnrollment(currentFactorId, code);
    document.getElementById('mfa-verify-code').value = '';
    await loadMFAStatus();
  } catch (error) {
    errorDiv.textContent = error.message;
    errorDiv.classList.add('visible');
  }
});

// Botão Desativar 2FA — mostra modal de confirmação
document.getElementById('mfa-disable-btn')?.addEventListener('click', () => {
  if (!currentFactorId) return;
  showConfirmModal();
});

function showConfirmModal() {
  const modal = document.getElementById('confirm-modal');
  if (!modal) return;
  modal.style.display = 'flex';
  if (window.lucide) lucide.createIcons();
}

function hideConfirmModal() {
  const modal = document.getElementById('confirm-modal');
  if (modal) modal.style.display = 'none';
}

document.getElementById('confirm-cancel')?.addEventListener('click', hideConfirmModal);

document.getElementById('confirm-modal')?.addEventListener('click', (e) => {
  if (e.target === e.currentTarget) hideConfirmModal();
});

document.getElementById('confirm-accept')?.addEventListener('click', async () => {
  hideConfirmModal();
  if (!currentFactorId) return;

  try {
    await unenrollMFA(currentFactorId);
    currentFactorId = null;
    await loadMFAStatus();
  } catch (error) {
    if (import.meta.env.DEV) console.error('Erro ao desativar 2FA:', error);
  }
});

// =============================================
// SECÇÃO PERGUNTAS DE ACESSO
// =============================================

// Carregar perguntas existentes
async function loadGateQuestions() {
  try {
    const { data, error } = await supabaseClient.rpc('get_access_questions');
    if (error) throw error;

    if (data && data.length > 0) {
      document.getElementById('gate-question-1').value = data[0].question_1 || '';
      document.getElementById('gate-question-2').value = data[0].question_2 || '';
    }
  } catch (error) {
    if (import.meta.env.DEV) console.error('Erro ao carregar perguntas:', error);
  }
}

// Carregar perguntas ao inicializar
loadGateQuestions();

// Botões de editar nas perguntas
document.querySelectorAll('#gate-questions-form .settings-edit-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    const targetId = btn.dataset.target;
    const input = document.getElementById(targetId);
    if (!input) return;

    input.disabled = false;
    input.focus();
    btn.style.display = 'none';
    document.getElementById('gate-actions').style.display = 'flex';
  });
});

// Botão Cancelar edição de perguntas
document.getElementById('gate-cancel')?.addEventListener('click', async () => {
  await loadGateQuestions();

  document.querySelectorAll('#gate-question-1, #gate-question-2').forEach(input => {
    input.disabled = true;
  });
  document.querySelectorAll('#gate-questions-form .settings-edit-btn').forEach(btn => {
    btn.style.display = '';
  });
  document.getElementById('gate-actions').style.display = 'none';
  document.getElementById('gate-success').style.display = 'none';
  document.getElementById('gate-error-msg').style.display = 'none';
});

// Formulário de Perguntas de Acesso
document.getElementById('gate-questions-form')?.addEventListener('submit', async (e) => {
  e.preventDefault();

  const q1 = document.getElementById('gate-question-1').value.trim();
  const a1 = document.getElementById('gate-answer-1').value.trim();
  const q2 = document.getElementById('gate-question-2').value.trim();
  const a2 = document.getElementById('gate-answer-2').value.trim();
  const successDiv = document.getElementById('gate-success');
  const errorDiv = document.getElementById('gate-error-msg');

  successDiv.style.display = 'none';
  errorDiv.style.display = 'none';

  // Validar
  if (q1.length < 3) {
    errorDiv.textContent = 'A pergunta 1 deve ter pelo menos 3 caracteres.';
    errorDiv.style.display = 'block';
    return;
  }

  if (a1.length < 1) {
    errorDiv.textContent = 'Introduza a resposta 1.';
    errorDiv.style.display = 'block';
    return;
  }

  if (q2.length < 3) {
    errorDiv.textContent = 'A pergunta 2 deve ter pelo menos 3 caracteres.';
    errorDiv.style.display = 'block';
    return;
  }

  if (a2.length < 1) {
    errorDiv.textContent = 'Introduza a resposta 2.';
    errorDiv.style.display = 'block';
    return;
  }

  try {
    const { error } = await supabaseClient.rpc('save_access_questions', {
      q1: q1,
      a1: a1,
      q2: q2,
      a2: a2
    });

    if (error) throw error;

    // Limpar campos de resposta
    document.getElementById('gate-answer-1').value = '';
    document.getElementById('gate-answer-2').value = '';

    // Desativar campos
    document.querySelectorAll('#gate-question-1, #gate-question-2').forEach(input => {
      input.disabled = true;
    });
    document.querySelectorAll('#gate-questions-form .settings-edit-btn').forEach(btn => {
      btn.style.display = '';
    });
    document.getElementById('gate-actions').style.display = 'none';

    successDiv.textContent = 'Perguntas de acesso guardadas com sucesso.';
    successDiv.style.display = 'block';
  } catch (error) {
    errorDiv.textContent = error.message || 'Erro ao guardar perguntas.';
    errorDiv.style.display = 'block';
  }
});

