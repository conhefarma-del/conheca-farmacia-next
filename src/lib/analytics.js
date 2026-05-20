/**
 * Analytics - Page view tracking
 * Regista visitas no Supabase (fire-and-forget)
 */

import { supabaseClient } from '../config.js';

const DEBOUNCE_KEY = '_pv_last_path';
const DEBOUNCE_MS = 30000;

function getSessionId() {
  try {
    let sid = localStorage.getItem('_pv_session_id');
    if (!sid) {
      sid = crypto.randomUUID();
      localStorage.setItem('_pv_session_id', sid);
    }
    return sid;
  } catch {
    return crypto.randomUUID();
  }
}

export async function trackPageView() {
  const path = window.location.pathname;

  // Excluir páginas admin
  if (path.includes('/admin/')) return;

  // Debounce: evitar contagem duplicada em refreshes
  const lastPath = sessionStorage.getItem(DEBOUNCE_KEY);
  if (lastPath === path) return;
  sessionStorage.setItem(DEBOUNCE_KEY, path);
  setTimeout(() => sessionStorage.removeItem(DEBOUNCE_KEY), DEBOUNCE_MS);

  const sessionId = getSessionId();

  // Fire-and-forget: não bloqueia a página
  supabaseClient.from('page_views').insert({
    page_path: path,
    page_title: document.title,
    referrer: document.referrer || null,
    session_id: sessionId,
  }).then(() => {}).catch(() => {});
}

// Auto-executar
trackPageView();
