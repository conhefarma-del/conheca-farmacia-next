-- =====================================================================
-- 273 — Cruzamento NPH × protamina nos perfis e farmacologia
-- ---------------------------------------------------------------------
-- Complementa a migração 272 (par critical insulina-nph × protamina)
-- reforçando as fichas dos dois fármacos em drug_profiles e
-- drug_pharmacology, para que qualquer profissional que consulte uma
-- das fichas enja o aviso da outra via.
--
-- NOTA: 269/270 já foram aplicadas; como usam ON CONFLICT DO NOTHING,
-- editá-las não alteraria a BD. Esta migração faz UPDATE direto com
-- guarda strpos(...) = 0 → idempotente (reaplicar = 0 mudanças).
--
-- Os 4 UPDATEs abaixo acrescentam UMA linha de bullets (perfis) ou UMA
-- frase (farmacologia) a cada campo, sem tocar no conteúdo existente.
-- =====================================================================

-- 1. insulina-nph — drug_profiles.precautions
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• A insulina NPH contém protamina: informe qualquer equipa médica — a exposição prévia (NPH ou insulina protamina-zinco) aumenta o risco de reação anafiláctica à protamina IV, o antídoto da heparina (ver ficha Protamina)',
    precautions_en = p.precautions_en || E'\n• NPH insulin contains protamine: tell any medical team — prior exposure (NPH or protamine-zinc insulin) increases the risk of anaphylactic reaction to IV protamine, the heparin antidote (see the Protamine profile)',
    updated_at = now()
FROM public.drugs d
WHERE p.drug_id = d.id
  AND d.slug = 'insulina-nph'
  AND strpos(p.precautions_pt, 'A insulina NPH contém protamina') = 0;

-- 2. protamina — drug_profiles.precautions (torna a pergunta obrigatória explícita)
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• Antes da administração, questionar SEMPRE o uso atual ou preterido de insulinas NPH/protamina-zinco: os anticorpos anti-protamina pré-formados elevam o risco de anafilaxia (ver ficha Insulina isofânica/NPH)',
    precautions_en = p.precautions_en || E'\n• Before administration, ALWAYS ask about current or past use of NPH/protamine-zinc insulins: pre-formed anti-protamine antibodies raise the anaphylaxis risk (see the Isophane/NPH insulin profile)',
    updated_at = now()
FROM public.drugs d
WHERE p.drug_id = d.id
  AND d.slug = 'protamina'
  AND strpos(p.precautions_pt, 'questionar SEMPRE') = 0;

-- 3. insulina-nph — drug_pharmacology.mechanism
UPDATE public.drug_pharmacology ph
SET mechanism_pt = ph.mechanism_pt || E' A protamina do depósito é também um alergénio relevante: doentes tratados com NPH podem desenvolver anticorpos anti-protamina, que aumentam o risco de reação anafiláctica à protamina IV (antídoto da heparina).',
    mechanism_en = ph.mechanism_en || E' The depot protamine is also a clinically relevant allergen: patients on NPH can develop anti-protamine antibodies, which increase the risk of anaphylactic reaction to IV protamine (the heparin antidote).',
    updated_at = now()
FROM public.drugs d
WHERE ph.drug_id = d.id
  AND d.slug = 'insulina-nph'
  AND strpos(ph.mechanism_pt, 'alergénio relevante') = 0;

-- 4. protamina — drug_pharmacology.mechanism
UPDATE public.drug_pharmacology ph
SET mechanism_pt = ph.mechanism_pt || E' Doentes previamente expostos à protamina (insulinas NPH ou protamina-zinco) têm anticorpos pré-formados que podem mediar reações anafiláticas na reexposição IV — daí a anamnese obrigatória antes da administração.',
    mechanism_en = ph.mechanism_en || E' Patients previously exposed to protamine (NPH or protamine-zinc insulins) carry pre-formed antibodies that can mediate anaphylactic reactions on IV re-exposure — hence the mandatory history-taking before administration.',
    updated_at = now()
FROM public.drugs d
WHERE ph.drug_id = d.id
  AND d.slug = 'protamina'
  AND strpos(ph.mechanism_pt, 'anticorpos pré-formados') = 0;
