import { createClient } from "@supabase/supabase-js";

// SECURITY: Require environment variables, no fallback to hardcoded keys
const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    "ERRO: Variáveis SUPABASE_URL e SUPABASE_ANON_KEY são obrigatórias no .env. Defina-as antes de usar."
  );
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
