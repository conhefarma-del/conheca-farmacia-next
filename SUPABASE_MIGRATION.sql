-- Criar tabela 'inscricoes' no Supabase
-- Execute este script no SQL Editor do Supabase Dashboard

CREATE TABLE inscricoes (
  id BIGSERIAL PRIMARY KEY,
  nome TEXT NOT NULL,
  email TEXT NOT NULL,
  telefone TEXT NOT NULL,
  profissao TEXT NOT NULL,
  origem_evento TEXT NOT NULL,
  evento_slug TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Criar índices para melhor performance
CREATE INDEX idx_inscricoes_email ON inscricoes(email);
CREATE INDEX idx_inscricoes_evento_slug ON inscricoes(evento_slug);
CREATE INDEX idx_inscricoes_created_at ON inscricoes(created_at);

-- Ativar Row Level Security (RLS) - IMPORTANTE
ALTER TABLE inscricoes ENABLE ROW LEVEL SECURITY;

-- Criar política para permitir INSERT sem autenticação
CREATE POLICY "Permitir inscrições de qualquer um" ON inscricoes
  FOR INSERT
  WITH CHECK (true);

-- Criar política para permitir SELECT apenas para autenticados (admin)
CREATE POLICY "Permitir leitura para autenticados" ON inscricoes
  FOR SELECT
  USING (auth.role() = 'authenticated');

-- Criar função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criar trigger para atualizar updated_at
CREATE TRIGGER update_inscricoes_updated_at
BEFORE UPDATE ON inscricoes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
