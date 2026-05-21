-- Migration 013: Admin Access Questions
-- Tabela para armazenar perguntas de segurança antes do login admin
-- As respostas são guardadas como hashes SHA256

CREATE TABLE IF NOT EXISTS admin_access_questions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  question_1 TEXT NOT NULL,
  answer_1_hash TEXT NOT NULL,
  question_2 TEXT NOT NULL,
  answer_2_hash TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS: apenas admins podem gerir perguntas
ALTER TABLE admin_access_questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage access questions" ON admin_access_questions
  FOR ALL
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));

-- RPC para buscar perguntas (público, sem expor respostas)
CREATE OR REPLACE FUNCTION get_access_questions()
RETURNS TABLE(question_1 TEXT, question_2 TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT aq.question_1, aq.question_2
  FROM admin_access_questions aq
  LIMIT 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC para verificar respostas (público)
CREATE OR REPLACE FUNCTION verify_access_answers(
  answer_1 TEXT,
  answer_2 TEXT
)
RETURNS BOOLEAN AS $$
DECLARE
  stored_hash_1 TEXT;
  stored_hash_2 TEXT;
BEGIN
  -- Validar input
  IF answer_1 IS NULL OR answer_2 IS NULL THEN
    RETURN FALSE;
  END IF;

  IF length(trim(answer_1)) = 0 OR length(trim(answer_2)) = 0 THEN
    RETURN FALSE;
  END IF;

  -- Buscar hashes armazenados
  SELECT aq.answer_1_hash, aq.answer_2_hash INTO stored_hash_1, stored_hash_2
  FROM admin_access_questions aq
  LIMIT 1;

  IF stored_hash_1 IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Comparar hashes (SHA256, lowercase, trimmed)
  RETURN (
    encode(digest(lower(trim(answer_1)), 'sha256'), 'hex') = stored_hash_1
    AND
    encode(digest(lower(trim(answer_2)), 'sha256'), 'hex') = stored_hash_2
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC para guardar/atualizar perguntas (apenas admins)
CREATE OR REPLACE FUNCTION save_access_questions(
  q1 TEXT,
  a1 TEXT,
  q2 TEXT,
  a2 TEXT
)
RETURNS VOID AS $$
DECLARE
  existing_id UUID;
BEGIN
  -- Validar input
  IF q1 IS NULL OR a1 IS NULL OR q2 IS NULL OR a2 IS NULL THEN
    RAISE EXCEPTION 'Todos os campos são obrigatórios';
  END IF;

  IF length(trim(q1)) < 3 OR length(trim(a1)) < 1 OR length(trim(q2)) < 3 OR length(trim(a2)) < 1 THEN
    RAISE EXCEPTION 'Perguntas devem ter pelo menos 3 caracteres e respostas pelo menos 1';
  END IF;

  -- Verificar se já existe registo
  SELECT id INTO existing_id FROM admin_access_questions LIMIT 1;

  IF existing_id IS NOT NULL THEN
    -- Atualizar
    UPDATE admin_access_questions SET
      question_1 = q1,
      answer_1_hash = encode(digest(lower(trim(a1)), 'sha256'), 'hex'),
      question_2 = q2,
      answer_2_hash = encode(digest(lower(trim(a2)), 'sha256'), 'hex'),
      updated_at = NOW()
    WHERE id = existing_id;
  ELSE
    -- Inserir
    INSERT INTO admin_access_questions (question_1, answer_1_hash, question_2, answer_2_hash)
    VALUES (
      q1,
      encode(digest(lower(trim(a1)), 'sha256'), 'hex'),
      q2,
      encode(digest(lower(trim(a2)), 'sha256'), 'hex')
    );
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
