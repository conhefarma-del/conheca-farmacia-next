// src/unsubscribe.js
import { unsubscribeByToken } from './lib/newsletter.js';

document.addEventListener('DOMContentLoaded', async () => {
  const params = new URLSearchParams(window.location.search);
  const token = params.get('token');

  const loading = document.getElementById('loading');
  const success = document.getElementById('success');
  const error = document.getElementById('error');
  const errorMessage = document.getElementById('error-message');

  function showState(state) {
    loading.classList.remove('active');
    success.classList.remove('active');
    error.classList.remove('active');
    state.classList.add('active');
  }

  if (!token) {
    showState(error);
    errorMessage.textContent = 'Token não fornecido. Verifique se utilizou o link completo do email.';
    return;
  }

  const result = await unsubscribeByToken(token);

  if (result.success) {
    showState(success);
  } else {
    showState(error);
    errorMessage.textContent = result.error || 'O link de cancelamento é inválido ou já foi utilizado.';
  }
});
