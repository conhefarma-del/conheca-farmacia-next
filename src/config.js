// Configuração do Supabase - Usando biblioteca oficial
// SECURITY: Usar variáveis de ambiente, nunca hardcoded

import { createClient } from "@supabase/supabase-js";

// Vite exige prefixo VITE_ para variáveis de ambiente expostas
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Validação das variáveis de ambiente
if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error("❌ Variáveis de ambiente do Supabase não configuradas!");
  console.error("Certifique-se de que o arquivo .env contém:");
  console.error("  VITE_SUPABASE_URL=sua_url_aqui");
  console.error("  VITE_SUPABASE_ANON_KEY=sua_chave_aqui");
}

// Criar cliente oficial do Supabase
const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: {
    persistSession: false, // Não persistir sessão em localStorage para aplicação estática
    autoRefreshToken: false,
    detectSessionInUrl: false,
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
});

// Exportar para módulos ES6
export { supabaseClient, SUPABASE_URL, SUPABASE_ANON_KEY };

// Manter compatibilidade com código legado (window.supabase)
window.supabase = supabaseClient;
window.SUPABASE_URL = SUPABASE_URL;
window.SUPABASE_ANON_KEY = SUPABASE_ANON_KEY;

console.log("✅ Supabase configurado com biblioteca oficial");
