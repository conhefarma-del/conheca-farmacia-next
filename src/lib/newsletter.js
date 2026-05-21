// src/lib/newsletter.js
import { supabaseClient } from '../config.js';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;

/**
 * Subscrever à newsletter — usa RPC SECURITY DEFINER (SEC-SQL-01/04)
 * Verificação de email existente + inserção acontecem no servidor.
 */
export async function subscribeToNewsletter(email, honeypot) {
  // Honeypot check
  if (honeypot) {
    return { success: false, error: 'Spam detected' };
  }

  // Validate email (client-side, duplicado no servidor via RPC)
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { success: false, error: 'Email inválido' };
  }

  // Chamar RPC subscribe_newsletter (faz SELECT + INSERT/UPDATE no servidor)
  const { data, error } = await supabaseClient
    .rpc('subscribe_newsletter', { p_email: email.toLowerCase().trim() });

  if (error) {
    return { success: false, error: 'Erro ao subscrever.' };
  }

  // Se inscrito com sucesso, enviar email de boas-vindas
  if (data.success) {
    await sendWelcomeEmail(email);
  }

  return data;
}

/**
 * Enviar email de boas-vindas via Edge Function
 */
async function sendWelcomeEmail(email) {
  try {
    await fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
      },
      body: JSON.stringify({
        type: 'welcome',
        email: email,
      }),
    });
  } catch (error) {
    console.error('Error sending welcome email:', error);
  }
}

/**
 * Listar subscritores (admin) — SEC-API-03: select explícito sem colunas sensíveis
 */
export async function getNewsletterSubscribers() {
  const { data, error } = await supabaseClient
    .from('newsletter')
    .select('id, email, status, created_at, updated_at')
    .order('created_at', { ascending: false });

  if (error) return [];
  return data || [];
}

/**
 * Enviar alerta de conteúdo (admin)
 * @param {Array} targetEmails — se fornecido, envia apenas para estes emails em vez de todos os ativos
 */
export async function sendContentAlert(type, content, targetEmails = null) {
  let subscribers;

  if (targetEmails && targetEmails.length > 0) {
    // Enviar apenas para emails específicos
    const { data } = await supabaseClient
      .from('newsletter')
      .select('email, unsubscribe_token')
      .in('email', targetEmails)
      .eq('status', 'active');
    subscribers = data || [];
  } else {
    // Enviar para todos os ativos
    const { data } = await supabaseClient
      .from('newsletter')
      .select('email, unsubscribe_token')
      .eq('status', 'active');
    subscribers = data || [];
  }

  if (!subscribers || subscribers.length === 0) {
    return { success: false, error: 'Nenhum subscritor ativo selecionado.' };
  }

  const results = [];
  for (const subscriber of subscribers) {
    try {
      const response = await fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${import.meta.env.VITE_SUPABASE_ANON_KEY}`,
        },
        body: JSON.stringify({
          type,
          email: subscriber.email,
          contentTitle: content.title,
          contentUrl: content.url,
          contentDescription: content.description,
          contentDate: content.date,
          contentPlatform: content.platform,
          contentLocation: content.location,
          unsubscribeToken: subscriber.unsubscribe_token,
        }),
      });
      results.push({ email: subscriber.email, success: response.ok });
    } catch {
      results.push({ email: subscriber.email, success: false });
    }
  }

  const successful = results.filter(r => r.success).length;
  return { success: true, sent: successful, total: subscribers.length };
}

/**
 * Cancelar inscrição de subscritor por ID (soft delete — admin)
 */
export async function unsubscribeById(id) {
  const { error } = await supabaseClient
    .from('newsletter')
    .update({ status: 'unsubscribed', updated_at: new Date().toISOString() })
    .eq('id', id);

  return { success: !error, error: error?.message };
}

/**
 * Apagar subscritor permanentemente (hard delete — admin)
 */
export async function deleteSubscriber(id) {
  const { error } = await supabaseClient
    .from('newsletter')
    .delete()
    .eq('id', id);

  return { success: !error, error: error?.message };
}

/**
 * Unsubscribe via token — usa RPC SECURITY DEFINER (SEC-SQL-01)
 * Token nunca é exposto ao frontend; verificação acontece no servidor.
 */
export async function unsubscribeByToken(token) {
  const { data, error } = await supabaseClient
    .rpc('unsubscribe_newsletter', { p_token: token });

  if (error) {
    return { success: false, error: 'Erro ao processar pedido.' };
  }

  return data;
}

/**
 * Reativar subscrição cancelada (admin)
 */
export async function reactivateSubscriber(id) {
  const { error } = await supabaseClient
    .from('newsletter')
    .update({ status: 'active', updated_at: new Date().toISOString() })
    .eq('id', id);

  return { success: !error, error: error?.message };
}
