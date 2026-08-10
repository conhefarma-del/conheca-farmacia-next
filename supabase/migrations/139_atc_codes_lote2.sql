-- =====================================================================
-- 139 — Códigos ATC (lote 2): 54 fármacos que ficaram sem classificação
-- ---------------------------------------------------------------------
-- A migração 084 preencheu o atc_code de 146 fármacos, mas 53 fármacos
-- ficaram vazios porque os fármacos correspondentes só foram criados
-- depois (069 nutrição/electrólitos, 085 hormonas, 132 antibióticos, …)
-- — o UPDATE com JOIN da 084 não tocou linhas inexistentes. Este lote
-- cobre os 54 em falta (lista do utilizador; inclui os 9 da 069).
--
-- Códigos verificados no índice ATC/DDD oficial (WHO Collaborating
-- Centre for Drug Statistics Methodology, atcddd.fhi.no) em 2026-08.
-- Conteúdo factual (classificação oficial), não clínico.
-- Idempotente: reaplicar é seguro (UPDATEs re-escritos com valores
-- idênticos). Aplicar manualmente no Supabase (SQL editor).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Preenchimento (padrão 7.6 do documento de fluxo: JOIN com condição
-- ON d.slug = v.slug — nunca omitir a condição de junção).
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET atc_code = v.atc_code
FROM (VALUES
  -- --- Nutrição / electrólitos (069) ---
  -- Os 7 primeiros repetem os códigos já escolhidos na 084 (que não
  -- foram aplicados porque os fármacos não existiam então).
  ('acido_ascorbico', 'A11GA01'),
  ('aminoacidos', 'B05BA01'),
  ('carbonato_calcio', 'A12AA04'),
  ('cloreto_potassio', 'A12BA01'),
  ('colecalciferol', 'A11CC05'),
  ('emulsao_lipidica', 'B05BA02'),
  ('zinco', 'A12CB01'),
  -- Desvios conscientes da 084 (formas IV na BD, não orais):
  --   glicose: a 084 usava V06DC01 (glucose, nutrientes orais); a
  --   dextrose injetável (Dextrose 50% do perfil 137) é B05BA03
  --   (carbohydrates — solutions for parenteral nutrition).
  ('glicose', 'B05BA03'),
  --   sulfato_magnesio: a 084 usava A12CC02 (sulfato de magnésio oral);
  --   o MgSO4 da BD é a forma injetável (pré-eclâmpsia/eclâmpsia) →
  --   B05XA05 (magnesium sulfate — I.V. solution additive). O próprio
  --   índice WHO remete soluções parentéricas de electrólitos para B05B/B05X.
  ('sulfato_magnesio', 'B05XA05'),
  -- --- Antimaláricos ---
  ('artesunato', 'P01BE02'),
  ('artesunato-amodiaquina', 'P01BF03'),
  ('diidroartemisinina-piperaquina', 'P01BF05'),
  ('sulfadoxina-pirimetamina', 'P01BD51'),
  -- --- Antituberculosos ---
  ('bedaquilina', 'J04AK05'),
  ('estreptomicina', 'J01GA01'),
  ('etambutol', 'J04AK02'),
  ('isoniazida', 'J04AC01'),
  ('pirazinamida', 'J04AK01'),
  ('rifabutina', 'J04AB04'),
  ('rifampicina', 'J04AB02'),
  -- --- Penicilinas / β-lactâmicos ---
  ('ampicilina', 'J01CA01'),
  ('amoxicilina-clavulanato', 'J01CR02'),
  ('benzilpenicilina-benzatina', 'J01CE08'),
  ('fenoximetilpenicilina', 'J01CE02'),
  ('piperacilina-tazobactam', 'J01CR05'),
  -- --- Cefalosporinas ---
  ('cefalexina', 'J01DB01'),
  ('cefazolina', 'J01DB04'),
  ('cefepima', 'J01DE01'),
  ('cefotaxima', 'J01DD01'),
  ('ceftazidima', 'J01DD02'),
  ('ceftriaxona', 'J01DD04'),
  ('cefuroxima', 'J01DC02'),
  -- --- Antifúngicos ---
  ('cetoconazol', 'J02AB02'),
  ('fluconazol', 'J02AC01'),
  ('itraconazol', 'J02AC02'),
  ('voriconazol', 'J02AC03'),
  -- --- Sistema nervoso ---
  ('alprazolam', 'N05BA12'),
  ('clozapina', 'N05AH02'),
  ('donepezilo', 'N06DA02'),
  ('fenobarbital', 'N03AA02'),
  ('haloperidol', 'N05AD01'),
  ('lamotrigina', 'N03AX09'),
  ('litio', 'N05AN01'),
  ('memantina', 'N06DX01'),
  ('valproato', 'N03AG01'),
  -- --- Antidiabéticos / hormonas ---
  ('gliclazida', 'A10BB09'),
  ('glimepirida', 'A10BB12'),
  ('pioglitazona', 'A10BG03'),
  ('estradiol', 'G03CA03'),
  ('levonorgestrel', 'G03AC03'),
  ('tiamazol', 'H03BB02'),
  -- --- Antineoplásicos / outros ---
  ('anastrozol', 'L02BG03'),
  ('tamoxifeno', 'L02BA01'),
  ('linezolida', 'J01XX08')
) AS v(slug, atc_code)
WHERE d.slug = v.slug;
