// Teste de conexão com Supabase
const { createClient } = require('@supabase/supabase-js');

// Carregar variáveis de ambiente do .env
require('dotenv').config();

async function testSupabaseConnection() {
  try {
    console.log('Testing Supabase connection...');

    const SUPABASE_URL = process.env.VITE_SUPABASE_URL;
    const SUPABASE_ANON_KEY = process.env.VITE_SUPABASE_ANON_KEY;

    if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
      console.error('❌ Variáveis de ambiente do Supabase não configuradas!');
      return false;
    }

    // Criar cliente oficial do Supabase
    const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
        detectSessionInUrl: false,
      },
    });

    // Testar conexão fazendo uma consulta simples
    const { data, error, count } = await supabaseClient
      .from('articles')
      .select('*', { count: 'exact', head: true });

    if (error) {
      console.error('❌ Erro ao conectar com Supabase:', error);
      return false;
    }

    console.log('✅ Conexão com Supabase estabelecida com sucesso');
    console.log(`📊 Total de artigos encontrados: ${count || 0}`);
    return true;
  } catch (err) {
    console.error('❌ Erro inesperado ao testar conexão:', err);
    return false;
  }
}

// Executar o teste
testSupabaseConnection()
  .then(success => {
    if (!success) {
      process.exit(1);
    }
    console.log('✅ Teste de conexão concluído com sucesso');
  })
  .catch(err => {
    console.error('❌ Falha crítica no teste de conexão:', err);
    process.exit(1);
  });