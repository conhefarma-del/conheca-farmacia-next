-- =====================================================================
-- 276 — Guardas de integridade ATC na própria BD (prevenção de regressões)
-- ---------------------------------------------------------------------
-- Prende na base de dados as três invariantes que a auditoria da 274
-- verificou manualmente (dopamina C01CA24, tiamazol H03BB02, classes
-- erradas), para que erros futuros falhem na BD e não cheguem ao site:
--
--   1. FORMATO do atc_code: CHECK imediato (^[A-Z][0-9]{2}(…)?$ ou NULL).
--   2. COERÊNCIA classe ↔ letra ATC: trigger que valida o 1.º carácter
--      contra a tabela de referência atc_class_letters (semeada com os
--      conjuntos observados nos 375 fármacos actuais, pós-274).
--   3. UNICIDADE de atc_code excepto pares canónico/duplicado: trigger
--      que bloqueia partilha de ATC entre fármacos "diferentes"; os
--      8 códigos actualmente partilhados por pares do mesmo princípio
--      activo (ex.: losartana/losartano) ficam na whitelist
--      atc_shared_exceptions — qualquer NOVO duplicado de outro ATC
--      falha na BD.
--
-- Reexecução segura: CREATE TABLE IF NOT EXISTS, DROP TRIGGER IF EXISTS,
-- sementes com ON CONFLICT DO NOTHING. Nenhum UPDATE de dados de fármacos.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Formato do ATC
--    Níveis reais do ATC: letra anatómica + 2 dígitos + (1–2 LETRAS de
--    subgrupo) + 2 DÍGITOS da substância → "J01", "C01CA04", "J01XX09".
-- ---------------------------------------------------------------------
ALTER TABLE public.drugs
  DROP CONSTRAINT IF EXISTS drugs_atc_code_format_chk;
ALTER TABLE public.drugs
  ADD CONSTRAINT drugs_atc_code_format_chk
  CHECK (atc_code IS NULL OR atc_code ~ '^[A-Z][0-9]{2}([A-Z]{1,2}[0-9]{2})?$');

-- ---------------------------------------------------------------------
-- 2. Tabela de referência: letras ATC permitidas por classe do site
--    (semeada com o estado pós-274 — ver cabeçalho da auditoria 274)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.atc_class_letters (
  class_slug TEXT PRIMARY KEY,
  letters    TEXT NOT NULL  -- concatenação, ex.: 'C'
);

INSERT INTO public.atc_class_letters (class_slug, letters) VALUES
  ('antibacterianos',     'J'),
  ('antimicobacteriais',  'J'),
  ('antiretrovirais',     'J'),
  ('antifungicos',        'DJA'),
  ('anestesicos',         'NM'),
  ('hormonas',            'HGLAB'),
  ('anti_helminticos',    'PJ'),
  ('nutricao',            'AB'),
  ('antidepressivos',     'NR'),
  ('ansioliticos',        'NR'),
  ('cardiovasculares',    'CGS'),
  ('antipsicoticos',      'N'),
  ('antimalaricos',       'P'),
  ('antiepilepticos',     'N'),
  ('respiratorios',       'RS'),
  ('dermatologicos',      'DG'),
  ('outros',              'V'),
  ('anticoagulantes',     'B'),
  ('antidotoss',          'VN'),
  ('imunossupressores',   'HL'),
  ('analgesicos',         'NR'),
  ('antiparkinsonianos',  'N'),
  ('antidiabeticos',      'A'),
  ('gastrointestinais',   'A'),
  ('antivirais',          'J'),
  ('antineoplasicos',     'L'),
  ('musculoesqueleticos', 'M'),
  ('urologicos',          'G'),
  ('snc_outros',          'N')
ON CONFLICT (class_slug) DO NOTHING;

-- ---------------------------------------------------------------------
-- 3. Whitelist de ATC partilhado por pares canónico/duplicado
--    (mesmo princípio activo — padrão da migração 254)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.atc_shared_exceptions (
  atc_code   TEXT PRIMARY KEY,
  reason     TEXT NOT NULL DEFAULT ''
);

INSERT INTO public.atc_shared_exceptions (atc_code, reason) VALUES
  ('C09CA01', 'losartana / losartano (254)'),
  ('B03AA07', 'sulfato-ferroso / ferro'),
  ('B03BB01', 'acido-folico / acido_folico'),
  ('J01CR02', 'amoxicilina-acido-clavulanico / amoxicilina-clavulanato'),
  ('A11CC05', 'colecalciferol / vitamina-d'),
  ('A11GA01', 'acido-ascorbico / acido_ascorbico'),
  ('H03BB01', 'carbimazol / tiamazol (profármaco, 274)'),
  ('B02AA02', 'acido-tranexamico / acido_tranexamico')
ON CONFLICT (atc_code) DO NOTHING;

-- ---------------------------------------------------------------------
-- 4. Trigger: coerência classe↔letra + unicidade de ATC
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.fn_drugs_atc_guard()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_letter   TEXT;
  v_class    TEXT;
  v_allowed  TEXT;
  v_other    UUID;
BEGIN
  -- NULL é sempre permitido (fármaco sem ATC)
  IF NEW.atc_code IS NULL OR NEW.atc_code = '' THEN
    RETURN NEW;
  END IF;

  v_letter := substring(NEW.atc_code FROM 1 FOR 1);

  -- classe do fármaco
  SELECT c.slug INTO v_class
  FROM public.drug_classes c
  WHERE c.id = NEW.class_id;

  -- (a) coerência classe ↔ letra
  IF v_class IS NOT NULL THEN
    SELECT letters INTO v_allowed
    FROM public.atc_class_letters
    WHERE class_slug = v_class;

    IF v_allowed IS NULL THEN
      RAISE EXCEPTION 'ATC guard: classe "%" sem registo em atc_class_letters — adicionar as letras permitidas antes de usar ATC %', v_class, NEW.atc_code;
    END IF;

    IF position(v_letter in v_allowed) = 0 THEN
      RAISE EXCEPTION 'ATC guard: % (letra %) é incoerente com a classe "%" (letras permitidas: %)', NEW.atc_code, v_letter, v_class, v_allowed;
    END IF;
  END IF;

  -- (b) unicidade: outro fármaco activo com o mesmo ATC?
  SELECT d.id INTO v_other
  FROM public.drugs d
  WHERE d.atc_code = NEW.atc_code
    AND d.id <> NEW.id
    AND NOT d.is_archived
  LIMIT 1;

  IF v_other IS NOT NULL THEN
    IF NOT EXISTS (SELECT 1 FROM public.atc_shared_exceptions e WHERE e.atc_code = NEW.atc_code) THEN
      RAISE EXCEPTION 'ATC guard: % já está atribuído a outro fármaco (id %). Se for um par canónico/duplicado do mesmo princípio activo, adicionar o código a atc_shared_exceptions.', NEW.atc_code, v_other;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_drugs_atc_guard ON public.drugs;
CREATE TRIGGER trg_drugs_atc_guard
  BEFORE INSERT OR UPDATE OF atc_code, class_id, is_archived
  ON public.drugs
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_drugs_atc_guard();

-- ---------------------------------------------------------------------
-- 5. Índice de suporte: pesquisa rápida por ATC (usado pela guarda e
--    pelas páginas de classe terapêutica)
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_drugs_atc_code ON public.drugs (atc_code) WHERE atc_code IS NOT NULL;

-- =====================================================================
-- Notas:
--  * A whitelist cresce por decisão consciente: se no futuro se criar
--    outro par canónico/duplicado (padrão 254), a migração correspondente
--    deve inserir o ATC em atc_shared_exceptions — caso contrário falha
--    na BD, que é exactamente o comportamento pretendido.
--  * Novas classes do site têm de ser registadas em atc_class_letters
--    (o trigger dá mensagem explícita a indicar o que fazer).
--  * Fármacos arquivados não bloqueiam a reutilização do ATC.
-- =====================================================================
