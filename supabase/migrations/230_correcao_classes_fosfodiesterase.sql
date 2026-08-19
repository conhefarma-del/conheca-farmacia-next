-- =====================================================================
-- 230 — Correção: PDE5 inibidores classificados incorretamente
-- ---------------------------------------------------------------------
-- O padrão '%fosfodiesterase%' na classe respiratórios capturou
-- sildenafil (G04BE03), tadalafil (G04BE08) e vardenafil (G04BE09)
-- que são urológicos (disfunção erétil), não respiratórios.
--
-- Cria classe 'urologicos' e move os 3 fármacos.
-- =====================================================================

-- =====================================================================
-- 1. Criar classe urologicos
-- =====================================================================
INSERT INTO public.drug_classes
  (slug, name_pt, name_en, description_pt, description_en, atc_prefix, sort_order)
VALUES
  ('urologicos', 'Urológicos e Saúde Sexual', 'Urologicals & Sexual Health',
   'Os urológicos tratam disfunções do trato urinário e disfunção erétil. Os inibidores da fosfodiesterase-5 (PDE5) — sildenafil (Viagra®, Revatio®), tadalafil (Cialis®) e vardenafil (Levitra®) — inibem seletivamente a PDE5 no músculo liso do corpo cavernoso, potenciando o efeito do GMPc e promovendo vasodilatação. São usados em disfunção erétil e, o sildenafil e tadalafil, também em hipertensão arterial pulmonar (HAP). Contraindicados em doentes a nitratos (risco de hipotensão grave). (Fontes: DailyMed/FDA, EMC-UK/MHRA)',
   'Urologicals treat urinary tract dysfunctions and erectile dysfunction. Phosphodiesterase-5 (PDE5) inhibitors — sildenafil (Viagra®, Revatio®), tadalafil (Cialis®) and vardenafil (Levitra®) — selectively inhibit PDE5 in the corpus cavernous smooth muscle, potentiating GMPc effect and promoting vasodilation. Used in erectile dysfunction and, sildenafil and tadalafil, also in pulmonary arterial hypertension (PAH). Contraindicated in patients taking nitrates (risk of severe hypotension). (Sources: DailyMed/FDA, EMC-UK/MHRA)',
   'G04', 136)

ON CONFLICT (slug) DO NOTHING;

-- =====================================================================
-- 2. Mover PDE5 inibidores para urologicos
-- =====================================================================
UPDATE public.drugs
SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'urologicos')
WHERE slug IN ('sildenafil', 'tadalafil', 'vardenafil');

-- =====================================================================
-- 3. Corrigir acetilcisteina:确保 está em respiratórios (já OK, reforço)
-- =====================================================================
UPDATE public.drugs
SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'respiratorios')
WHERE slug = 'acetilcisteina' AND class_id IS NULL;

-- =====================================================================
-- 4. Corrigir poractant_alfa: garantir que está em respiratórios (OK)
-- =====================================================================
UPDATE public.drugs
SET class_id = (SELECT id FROM public.drug_classes WHERE slug = 'respiratorios')
WHERE slug = 'poractant_alfa' AND class_id IS NULL;
