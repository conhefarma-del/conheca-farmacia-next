// Configuração do Supabase - Usando biblioteca oficial
// SECURITY: Usar variáveis de ambiente, nunca hardcoded

import { createClient } from "@supabase/supabase-js";

// Vite exige prefixo VITE_ para variáveis de ambiente expostas
const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_ANON_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Mapeamento de cores para categorias de eventos
export const EVENT_CATEGORY_COLORS = {
  workshop: "#ff6c23",
  palestra: "#0a844f",
  congresso: "#002a32",
  seminario: "#7c3aed", // Roxo
  outro: "#6b7280", // Cinza
};

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
    persistSession: true, // Necessário para o admin manter sessão entre páginas
    autoRefreshToken: true,
    detectSessionInUrl: false,
  },
  realtime: {
    params: {
      eventsPerSecond: 10,
    },
  },
});

// Exportar cliente Supabase (nunca exportar chaves brutas)
export { supabaseClient };
