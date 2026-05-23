import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from 'jsr:@supabase/supabase-js@2';

// Configuração de CORS
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const RATE_LIMIT_WINDOW = 60000; // 60 segundos
const RATE_LIMIT_MAX_REQUESTS = 5;
const rateLimitStore = new Map<string, { count: number; resetTime: number }>();

const VALID_PROFISSOES = [
  'farmaceutico', 'enfermeiro', 'medico', 'estudante-saude',
  'tecnico-medio-saude', 'tecnico-radiologia', 'tecnico-analises-clinicas',
  'medico-dentista', 'biologo-analista', 'psicologo',
  'nutricionista', 'fisioterapeuta', 'outro'
];
const VALID_ORIGENS = [
  'instagram', 'whatsapp', 'facebook', 'tiktok',
  'linkedin', 'amigo-indicacao', 'outro'
];

const PHONE_REGEX = /^(?:\+?244|0)?9\d{8}$|^\+\d{1,3}\d{4,14}$/;
const EMAIL_REGEX = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
const SLUG_REGEX = /^[a-zA-Z0-9\-_]+$/;

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    if (req.method !== 'POST') {
      return new Response(JSON.stringify({ error: 'Method not allowed' }), {
        status: 405,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    const clientIp = req.headers.get('x-forwarded-for')?.split(',')[0].trim() ||
      req.headers.get('cf-connecting-ip') ||
      'unknown';

    // RATE LIMITING
    const now = Date.now();
    const ipRateLimit = rateLimitStore.get(clientIp);

    if (ipRateLimit) {
      if (now < ipRateLimit.resetTime) {
        if (ipRateLimit.count >= RATE_LIMIT_MAX_REQUESTS) {
          console.warn(`🚨 Rate limit excedido para IP: ${clientIp}`);
          return new Response(JSON.stringify({
            error: 'Muitas tentativas. Aguarde um momento antes de tentar novamente.'
          }), {
            status: 429,
            headers: { ...corsHeaders, 'Content-Type': 'application/json' }
          });
        }
        ipRateLimit.count++;
      } else {
        rateLimitStore.set(clientIp, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
      }
    } else {
      rateLimitStore.set(clientIp, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
    }

    const body = await req.json();
    const { nome, email, telefone, profissao, origem_evento, evento_slug, honeypot } = body;

    // HONEYPOT VALIDATION
    if (honeypot && honeypot.trim() !== '') {
      console.warn(`🚨 Bot detectado via honeypot. IP: ${clientIp}`);
      return new Response(JSON.stringify({
        success: true,
        message: 'Inscrição processada com sucesso'
      }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // VALIDAÇÃO ROBUSTA
    const errors: string[] = [];

    if (!nome || typeof nome !== 'string' || nome.trim().length < 3 || nome.length > 255) {
      errors.push('Nome inválido (3-255 caracteres)');
    }
    if (/<|>|script|onerror|onclick|javascript/i.test(nome)) {
      errors.push('Nome contém caracteres não permitidos');
    }

    if (!email || !EMAIL_REGEX.test(email) || email.length > 255) {
      errors.push('Email inválido');
    }

    const phoneClean = telefone?.replace(/[\s\-()]/g, '');
    if (!phoneClean || !PHONE_REGEX.test(phoneClean) || telefone.length > 20) {
      errors.push('Telefone inválido');
    }

    if (!profissao || !VALID_PROFISSOES.includes(profissao)) {
      errors.push('Profissão inválida');
    }

    if (!origem_evento || !VALID_ORIGENS.includes(origem_evento)) {
      errors.push('Origem inválida');
    }

    if (!evento_slug || !SLUG_REGEX.test(evento_slug) || evento_slug.length > 255) {
      errors.push('Slug do evento inválido');
    }

    if (errors.length > 0) {
      console.warn(`❌ Validação falhou para IP ${clientIp}:`, errors);
      return new Response(JSON.stringify({
        error: 'Validação falhou',
        details: errors
      }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // CONECTAR AO SUPABASE
    const supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');

    if (!supabaseUrl || !supabaseServiceKey) {
      console.error('❌ Supabase não configurado');
      throw new Error('Erro ao conectar ao servidor');
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // VERIFICAR CAPACIDADE DO EVENTO
    console.log(`📊 Verificando capacidade do evento: ${evento_slug}`);

    const { data: eventData, error: eventError } = await supabase
      .from('events')
      .select('capacity')
      .eq('slug', evento_slug)
      .single();

    if (eventError || !eventData) {
      console.warn(`⚠️ Evento não encontrado: ${evento_slug}`);
      return new Response(JSON.stringify({
        error: 'Evento não encontrado'
      }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    const capacity = eventData.capacity;

    // CONTAR INSCRIÇÕES ATUAIS
    const { count: currentCount, error: countError } = await supabase
      .from('inscricoes')
      .select('*', { count: 'exact', head: true })
      .eq('evento_slug', evento_slug);

    if (countError) {
      console.error('❌ Erro ao contar inscrições:', countError);
      throw new Error('Erro ao verificar vagas');
    }

    const inscriptionCount = currentCount || 0;
    const spotsLeft = capacity - inscriptionCount;

    console.log(`📈 Evento ${evento_slug}: Capacidade=${capacity}, Inscrições=${inscriptionCount}, Vagas=${spotsLeft}`);

    // VERIFICAR SE EVENTO ESTÁ CHEIO
    if (spotsLeft <= 0) {
      console.warn(`🚫 Evento completo: ${evento_slug} (IP: ${clientIp})`);
      return new Response(JSON.stringify({
        error: 'Evento completo. Sem vagas disponíveis.'
      }), {
        status: 409,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // VERIFICAR DUPLICATAS
    const { data: existingInscriptions, error: queryError } = await supabase
      .from('inscricoes')
      .select('id')
      .eq('email', email)
      .eq('evento_slug', evento_slug)
      .limit(1);

    if (!queryError && existingInscriptions && existingInscriptions.length > 0) {
      console.warn(`⚠️ Inscrição duplicada detectada: ${email} no evento ${evento_slug}`);
      return new Response(JSON.stringify({
        error: 'Já está registado neste evento com este email'
      }), {
        status: 409,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    // SUCESSO
    console.log(`✅ Inscrição validada com sucesso para ${email} no evento ${evento_slug}`);
    return new Response(JSON.stringify({
      success: true,
      message: 'Validação concluída. Inscrição pode ser processada.'
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });

  } catch (error) {
    console.error('❌ Erro na Edge Function:', error);
    return new Response(JSON.stringify({
      error: 'Erro ao processar validação',
      message: error.message
    }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });
  }
});
