-- Newsletter System: RLS policies, unsubscribe_token, and RPC functions
-- Migration 013 - Newsletter insert policy and RPC functions

-- Adicionar coluna unsubscribe_token
ALTER TABLE newsletter
ADD COLUMN IF NOT EXISTS unsubscribe_token UUID DEFAULT uuid_generate_v4();

-- Criar índice para o token
CREATE INDEX IF NOT EXISTS idx_newsletter_unsubscribe_token
ON newsletter(unsubscribe_token);

-- Garantir colunas de auditoria (SEC-AUD-01)
ALTER TABLE newsletter ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE newsletter ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Política INSERT pública com validação de email (SEC-SQL-04)
CREATE POLICY "Public can insert newsletter subscriptions"
ON newsletter
FOR INSERT
TO anon
WITH CHECK (
  email IS NOT NULL
  AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
  AND length(email) <= 254
);

-- Política SELECT apenas para admins (SEC-SQL-01)
CREATE POLICY "Admins can read newsletter"
ON newsletter
FOR SELECT
TO authenticated
USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));

-- Função RPC para subscrição segura (SEC-SQL-01/04)
-- Permite verificar se email já existe + inserir/reativar sem expor dados
CREATE OR REPLACE FUNCTION subscribe_newsletter(p_email TEXT)
RETURNS JSONB AS $$
DECLARE
  v_email TEXT;
  v_existing RECORD;
BEGIN
  -- Validar email
  v_email := lower(trim(p_email));
  IF v_email !~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' OR length(v_email) > 254 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Email inválido.');
  END IF;

  -- Verificar se já existe
  SELECT id, status INTO v_existing FROM newsletter WHERE email = v_email LIMIT 1;

  IF FOUND THEN
    IF v_existing.status = 'active' THEN
      RETURN jsonb_build_object('success', false, 'error', 'Este email já está subscrito.');
    END IF;
    -- Reativar
    UPDATE newsletter SET status = 'active', updated_at = NOW() WHERE id = v_existing.id;
    RETURN jsonb_build_object('success', true, 'message', 'Subscrição reativada com sucesso!');
  END IF;

  -- Inserir novo
  INSERT INTO newsletter (email) VALUES (v_email);
  RETURN jsonb_build_object('success', true, 'message', 'Subscrição realizada com sucesso!');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função RPC para unsubscribe seguro por token (SEC-SQL-01)
CREATE OR REPLACE FUNCTION unsubscribe_newsletter(p_token UUID)
RETURNS JSONB AS $$
DECLARE
  v_updated INT;
BEGIN
  UPDATE newsletter
  SET status = 'unsubscribed', updated_at = NOW()
  WHERE unsubscribe_token = p_token
    AND status = 'active';

  GET DIAGNOSTICS v_updated = ROW_COUNT;

  IF v_updated = 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'Token inválido ou já cancelado.');
  END IF;

  RETURN jsonb_build_object('success', true, 'message', 'Subscrição cancelada com sucesso.');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
