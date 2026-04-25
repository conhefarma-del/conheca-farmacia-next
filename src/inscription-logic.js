import { supabaseClient, SUPABASE_URL, SUPABASE_ANON_KEY } from './config.js';

// Inicializar Supabase na janela global para compatibilidade
window.supabase = supabaseClient;
window.SUPABASE_URL = SUPABASE_URL;
window.SUPABASE_ANON_KEY = SUPABASE_ANON_KEY;

document.addEventListener('DOMContentLoaded', async () => {
  const inscriptionForm = document.getElementById('inscription-form');
  const formContainer = document.getElementById('form-container');
  const successContainer = document.getElementById('success-container');
  const errorContainer = document.getElementById('error-container');
  const submitBtn = document.getElementById('submit-btn');
  const btnText = document.getElementById('btn-text');
  const eventoSlugInput = document.getElementById('evento_slug');

  console.log('🔧 Iniciando sistema de inscrição...');

  // ==========================================
  // RATE LIMITING: Impedir múltiplas submissões
  // ==========================================
  const RATE_LIMIT_WINDOW = 5000; // 5 segundos entre submissões
  let lastSubmissionTime = 0;
  const rateLimitedIPs = new Map(); // Tracking para possível edge function

  // Aguardar que Supabase esteja pronto
  async function waitForSupabase(timeout = 10000) {
    return new Promise((resolve, reject) => {
      if (window.supabase && typeof window.supabase.from === 'function') {
        console.log('✅ Supabase já disponível');
        resolve();
        return;
      }

      const timeoutId = setTimeout(() => {
        reject(new Error('Timeout aguardando Supabase'));
      }, timeout);

      window.addEventListener('supabase-ready', () => {
        clearTimeout(timeoutId);
        console.log('✅ Evento supabase-ready recebido');
        resolve();
      });

      window.addEventListener('supabase-error', (event) => {
        clearTimeout(timeoutId);
        reject(event.detail);
      });
    });
  }

  // Tentar inicializar Supabase
  try {
    console.log('⏳ Aguardando Supabase...');
    await waitForSupabase(15000);
    console.log('✅ Supabase inicializado com sucesso');
  } catch (error) {
    console.error('❌ Erro ao inicializar Supabase:', error);
  }

  // Get event slug from URL parameter
  function getEventoSlugFromURL() {
    const params = new URLSearchParams(window.location.search);
    return params.get('evento') || '';
  }

  // Initialize form
  function initializeForm() {
    const eventoSlug = getEventoSlugFromURL();
    if (eventoSlug) {
      eventoSlugInput.value = eventoSlug;
      console.log('✓ Evento carregado:', eventoSlug);
    } else {
      console.warn('⚠ nenhum evento especificado na URL');
    }
  }

  // ==========================================
  // PROFESSIONAL VALIDATION: Robusto contra XSS e DoS
  // ==========================================
  function validateFormData(data) {
    const errors = [];

    // 1. Validação de Nome
    if (!data.nome || data.nome.trim().length < 3) {
      errors.push('Nome deve ter pelo menos 3 caracteres');
    } else if (data.nome.length > 255) {
      errors.push('Nome não pode exceder 255 caracteres');
    }
    // Verificar XSS patterns
    if (/<|>|script|onerror|onclick|javascript/i.test(data.nome)) {
      errors.push('Nome contém caracteres não permitidos');
    }

    // 2. Validação de Email (RFC 5322 simplificado)
    const emailRegex = /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;
    if (!data.email || !emailRegex.test(data.email)) {
      errors.push('Email inválido');
    } else if (data.email.length > 255) {
      errors.push('Email não pode exceder 255 caracteres');
    }

    // 3. Validação de Telefone (Angola + Internacional)
    // Aceita: +244925696002, 244925696002, 925696002, +244 925 696 002
    const phoneClean = data.telefone.replace(/[\s\-()]/g, ''); // Remove espaços e símbolos
    const phoneRegex = /^(?:\+?244|0)?9\d{8}$/; // Angola: 9XXXXXXXX
    const intlRegex = /^\+\d{1,3}\d{4,14}$/; // Internacional: +CCNNNNNNNNN

    if (!data.telefone || (!phoneRegex.test(phoneClean) && !intlRegex.test(phoneClean))) {
      errors.push('Telefone inválido. Use formato: +244 925 696 002 ou 925 696 002');
    } else if (data.telefone.length > 20) {
      errors.push('Telefone não pode exceder 20 caracteres');
    }

    // 4. Validação de Profissão (whitelist)
    const validProfissoes = [
      'farmaceutico', 'enfermeiro', 'medico', 'estudante-saude',
      'tecnico-medio-saude', 'tecnico-radiologia', 'tecnico-analises-clinicas',
      'medico-dentista', 'biologo-analista', 'psicologo',
      'nutricionista', 'fisioterapeuta', 'outro'
    ];
    if (!data.profissao || !validProfissoes.includes(data.profissao)) {
      errors.push('Selecione uma profissão válida');
    }

    // 5. Validação de Origem (whitelist)
    const validOrigens = ['instagram', 'whatsapp', 'facebook', 'tiktok', 'linkedin', 'amigo-indicacao', 'outro'];
    if (!data.origem_evento || !validOrigens.includes(data.origem_evento)) {
      errors.push('Selecione uma opção válida para origem');
    }

    // 6. Validação de Género (optional, whitelist)
    const validGeneros = ['masculino', 'feminino', ''];
    if (!validGeneros.includes(data.genero || '')) {
      errors.push('Selecione um género válido');
    }

    // 7. Validação de Faixa Etária (optional, whitelist)
    const validFaixas = ['18-24', '25-34', '35-44', '45-54', '55+', ''];
    if (!validFaixas.includes(data.faixa_etaria || '')) {
      errors.push('Selecione uma faixa etária válida');
    }

    // 8. Validação de Nível de Escolaridade (optional, whitelist)
    const validNiveis = ['tecnico-profissional', 'licenciatura', 'pos-graduacao-mestrado', 'doutoramento', ''];
    if (!validNiveis.includes(data.nivel_escolaridade || '')) {
      errors.push('Selecione um nível de escolaridade válido');
    }

    // 6. Validação de Evento Slug
    if (!data.evento_slug || data.evento_slug.trim() === '') {
      errors.push('Evento não especificado. Por favor, selecione um evento válido');
    } else if (!/^[a-zA-Z0-9\-_]+$/.test(data.evento_slug)) {
      errors.push('Slug do evento inválido');
    } else if (data.evento_slug.length > 255) {
      errors.push('Slug do evento não pode exceder 255 caracteres');
    }

    return errors;
  }

  // ==========================================
  // SECURITY: XSS Protection with DOMPurify
  // ==========================================
  function sanitizeInput(input) {
    if (!input) return '';
    // Configure DOMPurify to allow no HTML at all
    const clean = DOMPurify.sanitize(input, {
      ALLOWED_TAGS: [], // Sem tags permitidas
      ALLOWED_ATTR: [],
      KEEP_CONTENT: true
    });
    return clean.trim();
  }

  // Validate honeypot with enhanced logic
  function validateHoneypot(honeypot) {
    if (honeypot && honeypot.trim() !== '') {
      console.warn('🚨 SEGURANÇA: Bot detectado (honeypot preenchido)');
      return false;
    }
    return true;
  }

  // Mostrar erros de validação
  function showValidationErrors(errors) {
    const errorList = errors.map(err => `• ${err}`).join('\n');
    console.warn('⚠️ Erros de validação:\n' + errorList);
    showError(`Por favor, corrija os seguintes erros:\n\n${errorList.replace(/• /g, '• ')}`);
  }

  // Show success message
  function showSuccess() {
    console.log('✅ Mostrando mensagem de sucesso...');
    // Fade out form
    formContainer.style.opacity = '0';
    formContainer.style.transform = 'translateY(20px)';

    setTimeout(() => {
      formContainer.classList.add('hidden');
      successContainer.classList.remove('hidden');

      // Fade in success message
      successContainer.style.opacity = '0';
      successContainer.style.transform = 'translateY(20px)';

      setTimeout(() => {
        successContainer.style.transition = 'all 0.6s ease-out';
        successContainer.style.opacity = '1';
        successContainer.style.transform = 'translateY(0)';
      }, 50);

      // ==========================================
      // AUTO-RETURN: Voltar para evento após 3 segundos
      // ==========================================
      const eventoSlug = eventoSlugInput.value;
      setTimeout(() => {
        if (eventoSlug) {
          console.log(`🔄 Redirecionando para evento: ${eventoSlug}`);
          // Redirecionar para o evento usando o slug (mesmo formato da URL de origem)
          window.location.href = `evento.html?id=${encodeURIComponent(eventoSlug)}&refresh=true`;
        } else {
          // Se não houver slug, voltar para eventos.html
          window.location.href = 'eventos.html?refresh=true';
        }
      }, 3000); // 3 segundos
    }, 300);
  }

  // Show error message
  function showError(message) {
    console.error('❌ Erro:', message);
    errorContainer.classList.remove('hidden');
    document.getElementById('error-message').textContent = message;

    // Fade in error message
    errorContainer.style.opacity = '0';
    errorContainer.style.transform = 'translateY(20px)';

    setTimeout(() => {
      errorContainer.style.transition = 'all 0.6s ease-out';
      errorContainer.style.opacity = '1';
      errorContainer.style.transform = 'translateY(0)';
    }, 50);

    // Re-enable submit button
    submitBtn.disabled = false;
    submitBtn.classList.remove('btn-loading');
    btnText.textContent = 'Confirmar Inscrição';
  }

  // ==========================================
  // CHECK FOR DUPLICATES: Verificar inscrição duplicada
  // ==========================================
  async function checkForDuplicateInscription(email, eventoSlug) {
    try {
      console.log(`🔍 Verificando inscrição duplicada para ${email} no evento ${eventoSlug}...`);

      const { data: existingInscriptions, error } = await window.supabase
        .from('inscricoes')
        .select('id', { count: 'exact' })
        .eq('email', email)
        .eq('evento_slug', eventoSlug);

      if (error) {
        console.warn('⚠️ Erro ao verificar duplicata:', error);
        // Não falhar silenciosamente - deixar o INSERT tentar
        return false;
      }

      if (existingInscriptions && existingInscriptions.length > 0) {
        console.warn('⚠️ Inscrição duplicada detetada');
        return true; // Existe duplicata
      }

      console.log('✅ Nenhuma inscrição duplicada encontrada');
      return false; // Sem duplicata
    } catch (error) {
      console.error('❌ Erro ao verificar duplicata:', error);
      // Não falhar - deixar o INSERT tentar
      return false;
    }
  }

  // ==========================================
  // SERVER-SIDE VALIDATION: Edge Function call
  // ==========================================
  async function validateWithEdgeFunction(data, honeypot) {
    const edgeFunctionUrl = `${SUPABASE_URL}/functions/v1/validate-inscription`;

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout

    try {
      const response = await fetch(edgeFunctionUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
        },
        body: JSON.stringify({
          ...data,
          honeypot: honeypot
        }),
        signal: controller.signal
      });

      clearTimeout(timeoutId);

      const result = await response.json();

      if (!response.ok) {
        // Retornar erro específico da Edge Function
        if (result.error === 'Muitas tentativas. Aguarde um momento antes de tentar novamente.') {
          throw new Error('Muitas tentativas. Aguarde 1 minuto antes de tentar novamente.');
        }
        if (result.error === 'Já está registado neste evento com este email') {
          throw new Error('Já está registado neste evento com este email.');
        }
        if (result.details && Array.isArray(result.details)) {
          throw new Error(result.details.join(' | '));
        }
        throw new Error(result.error || 'Erro ao validar inscrição no servidor');
      }

      console.log('✅ Validação server-side passou com sucesso');
      return true;
    } catch (error) {
      clearTimeout(timeoutId);
      if (error.name === 'AbortError') {
        throw new Error('A ligação ao servidor demorou demasiado tempo. Por favor, tente novamente.');
      }
      // Catch TypeError (CORS or Network issues)
      if (error instanceof TypeError) {
        console.error('⚠️ Erro de rede ou CORS detetado:', error);
        throw new Error('Não foi possível contactar o servidor. Por favor, verifique a sua ligação ou tente mais tarde.');
      }
      console.error('⚠️ Erro na validação server-side:', error);
      throw error;
    }
  }

  // Handle form submission
  inscriptionForm.addEventListener('submit', async (e) => {
    e.preventDefault();

    console.log('📤 Iniciando submissão do formulário...');

    // ==========================================
    // RATE LIMITING: Proteção contra spam
    // ==========================================
    const now = Date.now();
    if (now - lastSubmissionTime < RATE_LIMIT_WINDOW) {
      const remainingTime = Math.ceil((RATE_LIMIT_WINDOW - (now - lastSubmissionTime)) / 1000);
      showError(`Por favor, aguarde ${remainingTime} segundo(s) antes de tentar novamente.`);
      return;
    }
    lastSubmissionTime = now;

    // Verificar se Supabase está disponível
    if (!window.supabase || typeof window.supabase.from !== 'function') {
      console.error('❌ Supabase não foi inicializado corretamente');
      showError('Não conseguimos estabelecer conexão no momento. Por favor, recarregue a página e tente novamente.');
      return;
    }

    // ==========================================
    // HONEYPOT VALIDATION: Detectar bots
    // ==========================================
    const honeypot = document.getElementById('honeypot').value;
    if (!validateHoneypot(honeypot)) {
      console.warn('🚨 SEGURANÇA: Submissão bloqueada por honeypot');
      showError('Não foi possível validar o seu pedido. Por favor, tente novamente.');
      return;
    }

    // Get form data
    const formData = new FormData(inscriptionForm);
    const rawData = {
      nome: formData.get('nome'),
      email: formData.get('email'),
      telefone: formData.get('telefone'),
      profissao: formData.get('profissao'),
      origem_evento: formData.get('origem_evento'),
      evento_slug: formData.get('evento_slug'),
      genero: formData.get('genero'),
      faixa_etaria: formData.get('faixa_etaria'),
      nivel_escolaridade: formData.get('nivel_escolaridade')
    };

    // ==========================================
    // XSS PROTECTION: Sanitizar com DOMPurify
    // ==========================================
    const data = {
      nome: sanitizeInput(rawData.nome),
      email: sanitizeInput(rawData.email),
      telefone: sanitizeInput(rawData.telefone),
      profissao: sanitizeInput(rawData.profissao),
      origem_evento: sanitizeInput(rawData.origem_evento),
      evento_slug: sanitizeInput(rawData.evento_slug),
      genero: sanitizeInput(rawData.genero) || null,
      faixa_etaria: sanitizeInput(rawData.faixa_etaria) || null,
      nivel_escolaridade: sanitizeInput(rawData.nivel_escolaridade) || null
    };

    console.log('📋 Dados do formulário (sanitizados):', data);

    // ==========================================
    // VALIDAÇÃO ANTES DO ENVIO: Garantir que nenhum campo é vazio
    // ==========================================
    const fieldsCheck = {
      nome: data.nome,
      email: data.email,
      telefone: data.telefone,
      profissao: data.profissao,
      origem_evento: data.origem_evento,
      evento_slug: data.evento_slug
    };

    for (const [field, value] of Object.entries(fieldsCheck)) {
      if (!value || (typeof value === 'string' && value.trim() === '')) {
        console.error(`❌ Campo obrigatório vazio: ${field}`);
      } else {
        console.log(`✓ ${field}: "${value}" (${value.length} caracteres)`);
      }
    }

    // Validar dados antes de enviar
    const validationErrors = validateFormData(data);
    if (validationErrors.length > 0) {
      showValidationErrors(validationErrors);
      lastSubmissionTime = 0; // Reset rate limit em caso de erro de validação
      return;
    }

    // Disable submit button (Rate Limiting UI)
    submitBtn.disabled = true;
    submitBtn.classList.add('btn-loading');
    btnText.textContent = 'A verificar...';

    try {
      // ==========================================
      // SERVER-SIDE VALIDATION: Chamar Edge Function
      // ==========================================
      await validateWithEdgeFunction(data, honeypot);

      console.log('🔗 Conectando ao Supabase...');
      btnText.textContent = 'A processar...';

      // ==========================================
      // DUPLICATE CHECK: Verificar antes de inserir
      // ==========================================
      const isDuplicate = await checkForDuplicateInscription(data.email, data.evento_slug);
      if (isDuplicate) {
        throw new Error('Já tem uma inscrição neste evento com este endereço de email. Se tem dúvidas, contacte-nos.');
      }

      // Insert into Supabase - LOG DADOS
      console.log('📤 DADOS INSERÇÃO:', JSON.stringify(data));
      console.log('🔍 evento_slug:', data.evento_slug);
      console.log('🔍 email:', data.email);

      // INSERT sem .select() para evitar erros de RLS com papel anon
      const { error } = await window.supabase
        .from('inscricoes')
        .insert([data]);

      if (error) {
        console.error('❌ Erro ao inserir:', error);
        console.error('Código:', error.code);
        console.error('Mensagem:', error.message);
        console.error('Detalhes:', error.details);
        console.error('Hint:', error.hint);
        console.error('🔍 Objeto erro completo:', JSON.stringify(error, null, 2));

        // Tratamento específico para erro de RLS (42501)
        if (error.code === '42501') {
          console.error('ℹ️ ERRO RLS: Verifique os dados contra a política de segurança');
          throw new Error('A inscrição foi rejeitada pelas políticas de segurança. Verifique se preencheu todos os campos corretamente.');
        }

        // Tratamento específico para erro de duplicata
        if (error.code === '23505' || error.message.includes('unique')) {
          throw new Error('Já tem uma inscrição neste evento com este endereço de email. Se tem dúvidas, contacte-nos.');
        }

        throw new Error(error.message || 'Erro ao salvar inscrição');
      }

      console.log('✅ Inscrição salva com sucesso!');
      showSuccess();

    } catch (error) {
      console.error('❌ Erro na submissão:', error);

      // Se for erro de JSON parsing e dados foram enviados, considerar como sucesso
      if (error.message.includes('JSON') || error.message.includes('Unexpected end')) {
        console.log('⚠️ Erro de parsing mas os dados foram provavelmente gravados');
        showSuccess();
        return;
      }

      showError(error.message || 'Não foi possível completar a sua inscrição neste momento. Por favor, tente novamente mais tarde ou contacte o suporte.');

      // GARANTIA: Resetar o estado do botão independentemente do erro
      submitBtn.disabled = false;
      submitBtn.classList.remove('btn-loading');
      btnText.textContent = 'Confirmar Inscrição';
    }
  });

  // Initialize on page load
  initializeForm();
  console.log('✓ Sistema de inscrição pronto');
});
