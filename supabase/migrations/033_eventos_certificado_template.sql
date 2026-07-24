-- 033: campos de template de certificado por evento (editáveis no CMS, PT)
ALTER TABLE public.events
  ADD COLUMN IF NOT EXISTS certificado_cor TEXT DEFAULT '#00493A',
  ADD COLUMN IF NOT EXISTS certificado_texto TEXT
    DEFAULT 'Certificamos que o participante concluiu com aproveitamento.',
  ADD COLUMN IF NOT EXISTS certificado_logo_url TEXT,
  ADD COLUMN IF NOT EXISTS certificado_carga_horaria TEXT,
  ADD COLUMN IF NOT EXISTS certificado_assinante_1_nome TEXT DEFAULT 'Conheça Farmácia',
  ADD COLUMN IF NOT EXISTS certificado_assinante_1_cargo TEXT DEFAULT 'Conheça Farmácia',
  ADD COLUMN IF NOT EXISTS certificado_assinante_2_nome TEXT,
  ADD COLUMN IF NOT EXISTS certificado_assinante_2_cargo TEXT DEFAULT 'Ordem dos Farmacêuticos';
