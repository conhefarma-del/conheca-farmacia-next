// src/lib/admin-gate.js
// Módulo para proteção de acesso ao painel admin com perguntas de segurança

import { supabaseClient } from '../config.js';

const BLOCK_KEY = 'admin_gate_block';
const BLOCK_DURATION = 5 * 60 * 1000; // 5 minutos em ms

/**
 * Verificar se o utilizador está bloqueado
 * @returns {boolean}
 */
export function isBlocked() {
  try {
    const blockData = localStorage.getItem(BLOCK_KEY);
    if (!blockData) return false;

    const { timestamp } = JSON.parse(blockData);
    const now = Date.now();

    if (now - timestamp < BLOCK_DURATION) {
      return true;
    }

    // Bloqueio expirou, limpar
    localStorage.removeItem(BLOCK_KEY);
    return false;
  } catch {
    return false;
  }
}

/**
 * Obter tempo restante de bloqueio em minutos
 * @returns {number}
 */
export function getBlockRemaining() {
  try {
    const blockData = localStorage.getItem(BLOCK_KEY);
    if (!blockData) return 0;

    const { timestamp } = JSON.parse(blockData);
    const remaining = BLOCK_DURATION - (Date.now() - timestamp);

    return Math.max(0, Math.ceil(remaining / 60000));
  } catch {
    return 0;
  }
}

/**
 * Ativar bloqueio temporário
 */
export function setBlock() {
  try {
    localStorage.setItem(BLOCK_KEY, JSON.stringify({
      timestamp: Date.now()
    }));
  } catch {
    // localStorage indisponível
  }
}

/**
 * Limpar bloqueio
 */
export function clearBlock() {
  try {
    localStorage.removeItem(BLOCK_KEY);
  } catch {
    // localStorage indisponível
  }
}

/**
 * Buscar perguntas de acesso do Supabase
 * @returns {Promise<{question_1: string, question_2: string} | null>}
 */
export async function fetchQuestions() {
  try {
    const { data, error } = await supabaseClient.rpc('get_access_questions');

    if (error) {
      if (import.meta.env.DEV) console.error('Erro ao buscar perguntas:', error);
      return null;
    }

    if (!data || data.length === 0) {
      return null;
    }

    return data[0];
  } catch {
    return null;
  }
}

/**
 * Verificar respostas via RPC
 * @param {string} answer1
 * @param {string} answer2
 * @returns {Promise<boolean>}
 */
export async function verifyAnswers(answer1, answer2) {
  try {
    const { data, error } = await supabaseClient.rpc('verify_access_answers', {
      answer_1: answer1,
      answer_2: answer2
    });

    if (error) {
      if (import.meta.env.DEV) console.error('Erro ao verificar respostas:', error);
      return false;
    }

    return data === true;
  } catch {
    return false;
  }
}

/**
 * Escapar HTML para prevenir XSS
 * @param {string} text
 * @returns {string}
 */
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}

/**
 * Inicializar o gate na página de login admin
 */
export async function initAdminGate() {
  const gateSection = document.getElementById('gate-section');
  const loginPage = document.getElementById('login-page');
  const gateForm = document.getElementById('gate-form');
  const gateError = document.getElementById('gate-error');

  if (!gateSection || !loginPage || !gateForm) return;

  // Verificar se está bloqueado
  if (isBlocked()) {
    const remaining = getBlockRemaining();
    showGateError(gateError, `Demasiadas tentativas. Tente novamente em ${remaining} minuto(s).`);
    disableGateForm(gateForm);
    return;
  }

  // Buscar perguntas
  const questions = await fetchQuestions();

  if (!questions) {
    // Se não há perguntas configuradas, mostrar login diretamente
    gateSection.style.display = 'none';
    loginPage.style.display = 'flex';
    return;
  }

  // Preencher labels das perguntas
  const q1Label = document.getElementById('gate-q1-label');
  const q2Label = document.getElementById('gate-q2-label');

  if (q1Label) q1Label.textContent = questions.question_1;
  if (q2Label) q2Label.textContent = questions.question_2;

  // Handler do formulário
  gateForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    const a1 = document.getElementById('gate-a1').value.trim();
    const a2 = document.getElementById('gate-a2').value.trim();

    if (!a1 || !a2) {
      showGateError(gateError, 'Responda a ambas as perguntas.');
      return;
    }

    // Verificar respostas
    const submitBtn = gateForm.querySelector('button[type="submit"]');
    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    const isValid = await verifyAnswers(a1, a2);

    submitBtn.classList.remove('loading');
    submitBtn.disabled = false;

    if (isValid) {
      // Sucesso — esconder gate, mostrar página de login
      gateSection.style.display = 'none';
      loginPage.style.display = 'flex';
      clearBlock();

      // Focar no campo de email
      const emailInput = document.getElementById('email');
      if (emailInput) emailInput.focus();
    } else {
      // Resposta errada — ativar bloqueio
      setBlock();
      showGateError(gateError, 'Respostas incorretas. A redirecionar...');

      // Redirecionar para homepage após 2 segundos
      setTimeout(() => {
        window.location.href = '/';
      }, 2000);
    }
  });
}

/**
 * Mostrar mensagem de erro no gate
 * @param {HTMLElement} errorDiv
 * @param {string} message
 */
function showGateError(errorDiv, message) {
  if (!errorDiv) return;
  errorDiv.textContent = message;
  errorDiv.classList.add('visible');
}

/**
 * Desativar formulário do gate (quando bloqueado)
 * @param {HTMLFormElement} form
 */
function disableGateForm(form) {
  if (!form) return;
  const inputs = form.querySelectorAll('input');
  const btn = form.querySelector('button[type="submit"]');

  inputs.forEach(input => input.disabled = true);
  if (btn) btn.disabled = true;
}
