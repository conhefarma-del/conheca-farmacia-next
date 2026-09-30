-- =====================================================================
-- 282 — Enriquecimento das precautions das 10 fichas com mais lacunas
--       critical (auditoria de consistência cruzada, 2026-10-01)
-- ---------------------------------------------------------------------
-- A auditoria cruzou os pares critical de drug_interactions com o texto
-- das fichas (drug_profiles) e identificou 78 fichas com ≥1 interação
-- critical cujo parceiro não é nomeado. Esta migração resolve as 10
-- fichas com mais lacunas, acrescentando às precautions (PT e EN) um
-- bullet que NOMENA os parceiros critical. O conteúdo clínico vem das
-- summary/management já registadas em drug_interactions (fontes
-- verificadas: Prontuário, EMC-UK, DailyMed — ver pares individuais).
--
-- Pares critical por ficha (da BD, 2026-10-01):
--   warfarina (10): aspirina, flucloxacilina, miconazol, clopidogrel,
--                   cotrimoxazol, ibuprofeno, telitromicina, testosterona,
--                   nimesulida, buprenorfina
--   ritonavir (9): teofilina, roflumilast, fluticasona, vardenafil,
--                  metadona, codeina, fentanilo, morfina, fluoxetina
--   fluoxetina (6): imipramina, sertralina, linezolida, risperidona,
--                   amitriptilina, ritonavir
--   rifampicina (4): artemeter-lumefantrina, dolutegravir, etravirina,
--                    levonorgestrel-etinilestradiol
--   espironolactona (4): enalapril, cloreto_potassio, lisinopril, losartana
--   claritromicina (4): ivabradina, carbamazepina, domperidona, colchicina
--   simvastatina (3): cetoconazol, eritromicina, telitromicina
--   alprazolam (3): morfina, codeina, hidromorfona
--   acenocumarol (3): clopidogrel, aspirina, cotrimoxazol
--   carbamazepina (2): claritromicina, desmopressina
--
-- Padrão idempotente da 273: cada UPDATE usa guarda
--   strpos(precautions_pt, '<marcador único>') = 0
-- de modo que reaplicar = 0 mudanças. Texto acrescentado, nunca
-- substituído.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. WARFARINA — 10 parceiros critical (anticoagulação)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• Interações CRÍTICAS com medicamentos: não inicie nem suspenda nenhum fármaco sem avisar o médico — em particular aspirina, clopidogrel, ibuprofeno e outros AINEs (nimesulida), cotrimoxazol, miconazol (incl. gel oral), flucloxacilina, telitromicina, testosterona e buprenorfina alteram fortemente o INR e o risco hemorrágico.',
    precautions_en = p.precautions_en || E'\n• CRITICAL drug interactions: do not start or stop any medication without informing the doctor — in particular aspirin, clopidogrel, ibuprofeno and other NSAIDs (nimesulide), cotrimoxazole, miconazol (including oral gel), flucloxacillin, telithromycin, testosterone and buprenorphine strongly affect INR and bleeding risk.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'warfarina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, 'Interações CRÍTICAS com medicamentos') = 0;

-- ---------------------------------------------------------------------
-- 2. RITONAVIR — 9 parceiros critical (inibidor CYP3A4 potente)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• O ritonavir é um inibidor muito potente do CYP3A4: CONTRAINDICADO ou exigindo reajuste com teofilina, roflumilast, fluticasona (inalada sistémica), vardenafil e opioides (metadona, codeína, fentanilo, morfina) — depressão respiratória; reveja TODA a medicação com o médico.',
    precautions_en = p.precautions_en || E'\n• Ritonavir is a very potent CYP3A4 inhibitor: CONTRAINDICATED or requiring adjustment with theophylline, roflumilast, inhaled fluticasone (systemic exposure), vardenafil and opioids (methadone, codeine, fentanyl, morphine) — respiratory depression; review ALL medication with the doctor.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'ritonavir') r
WHERE p.drug_id = r.id
  AND strpos(p.precautions_pt, 'inibidor muito potente do CYP3A4') = 0;

-- ---------------------------------------------------------------------
-- 3. FLUOXETINA — 6 parceiros critical (serotonina + CYP2D6)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• Interações críticas: não combinar com linezolida nem ritonavir (risco de síndrome serotoninérgica); com imipramina ou amitriptilina (tricíclicos) eleva fortemente os níveis destes via CYP2D6; precaução com sertralina e risperidona.',
    precautions_en = p.precautions_en || E'\n• Critical interactions: do not combine with linezolid or ritonavir (serotonin syndrome risk); with imipramine or amitriptyline (tricyclics) it strongly raises their levels via CYP2D6; caution with sertraline and risperidone.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'fluoxetina') f
WHERE p.drug_id = f.id
  AND strpos(p.precautions_pt, 'risco de síndrome serotoninérgica') = 0;

-- ---------------------------------------------------------------------
-- 4. RIFAMPICINA — 4 parceiros critical (indução enzimática)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• A rifampicina é um indutor enzimático potente: reduz drasticamente a eficácia de artemeter-lumefantrina (malária — risco de falência terapêutica), dolutegravir e etravirina (VIH — risco de resistência) e do contraceptivo levonorgestrel-etinilestradiol (gravidez não planeada) — usar alternativas.',
    precautions_en = p.precautions_en || E'\n• Rifampicin is a potent enzyme inducer: it drastically reduces the efficacy of artemether-lumefantrine (malaria — treatment failure risk), dolutegravir and etravirine (HIV — resistance risk) and of the levonorgestrel-ethinylestradiol contraceptive (unintended pregnancy) — use alternatives.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'rifampicina') r
WHERE p.drug_id = r.id
  AND strpos(p.precautions_pt, 'indutor enzimático potente: reduz drasticamente') = 0;

-- ---------------------------------------------------------------------
-- 5. ESPIRONOLACTONA — 4 parceiros critical (hipercaliemia)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• NÃO associar com enalapril, lisinopril, losartana ou suplementos de potássio (cloreto de potássio) sem vigilância estreita — o risco de hipercaliemia potencialmente fatal (arritmias) soma-se; monitorizar K+ sérico na 1.ª semana e após ajustes.',
    precautions_en = p.precautions_en || E'\n• Do NOT combine with enalapril, lisinopril, losartan or potassium supplements (potassium chloride) without close monitoring — the risk of potentially fatal hyperkalaemia (arrhythmias) is additive; monitor serum K+ in the first week and after adjustments.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'espironolactona') s
WHERE p.drug_id = s.id
  AND strpos(p.precautions_pt, 'risco de hipercaliemia potencialmente fatal (arritmias) soma-se') = 0;

-- ---------------------------------------------------------------------
-- 6. CLARITROMICINA — 4 parceiros critical (inibidor CYP3A4)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• Interações críticas: não associar com ivabradina, domperidona ou colchicina (toxicidade grave por inibição do CYP3A4/P-gp) nem com carbamazepina (toxicidade do antiepiléptico) — escolher antibiótico alternativo.',
    precautions_en = p.precautions_en || E'\n• Critical interactions: do not combine with ivabradine, domperidone or colchicine (severe toxicity via CYP3A4/P-gp inhibition) nor with carbamazepine (antiepileptic toxicity) — choose an alternative antibiotic.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'claritromicina') c
WHERE p.drug_id = c.id
  AND strpos(p.precautions_pt, 'não associar com ivabradina') = 0;

-- ---------------------------------------------------------------------
-- 7. SIMVASTATINA — 3 parceiros critical (miopatia)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• RISCO de miopatia/rabdomiólise grave: evitar cetoconazol, eritromicina e telitromicina (inibidores fortes do CYP3A4 que elevam os níveis da sinvastatina); suspenda e contacte o médico se surgirem dores ou fraqueza musculares.',
    precautions_en = p.precautions_en || E'\n• RISK of severe myopathy/rhabdomyolysis: avoid ketoconazole, erythromycin and telithromycin (strong CYP3A4 inhibitors that raise simvastatin levels); stop and contact the doctor if muscle pain or weakness develops.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'simvastatina') s
WHERE p.drug_id = s.id
  AND strpos(p.precautions_pt, 'RISCO de miopatia/rabdomiólise grave') = 0;

-- ---------------------------------------------------------------------
-- 8. ALPRAZOLAM — 3 parceiros critical (opioides)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• NÃO combinar com opioides (morfina, codeína, hidromorfona) — depressão respiratória profunda, sedação extrema e morte; se a associação for inevitável, apenas com as menores doses e supervisão médica próxima.',
    precautions_en = p.precautions_en || E'\n• Do NOT combine with opioids (morphine, codeine, hydromorphone) — profound respiratory depression, extreme sedation and death; if the combination is unavoidable, only with the lowest doses and close medical supervision.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'alprazolam') a
WHERE p.drug_id = a.id
  AND strpos(p.precautions_pt, 'depressão respiratória profunda, sedação extrema e morte') = 0;

-- ---------------------------------------------------------------------
-- 9. ACENOCUMAROL — 3 parceiros critical (anticoagulação)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• Interações críticas: aspirina e clopidogrel (risco hemorrágico aditivo — só com indicação cardiológica clara e vigilância) e cotrimoxazol (potencia fortemente o efeito anticoagulante — evitar; se indispensável, reajustar dose com INR frequente).',
    precautions_en = p.precautions_en || E'\n• Critical interactions: aspirin and clopidogrel (additive bleeding risk — only with clear cardiological indication and monitoring) and cotrimoxazole (strongly potentiates the anticoagulant effect — avoid; if essential, readjust the dose with frequent INR).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'acenocumarol') a
WHERE p.drug_id = a.id
  AND strpos(p.precautions_pt, 'potencia fortemente o efeito anticoagulante — evitar') = 0;

-- ---------------------------------------------------------------------
-- 10. CARBAMAZEPINA — 2 parceiros critical
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• Interações críticas: não associar com claritromicina (eleva a carbamazepina a níveis tóxicos por inibição do CYP3A4) nem com desmopressina (reduz o seu efeito por indução — falência do tratamento da poliúria/enurese).',
    precautions_en = p.precautions_en || E'\n• Critical interactions: do not combine with clarithromycin (raises carbamazepine to toxic levels via CYP3A4 inhibition) nor with desmopressin (reduces its effect via induction — polyuria/enuresis treatment failure).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'carbamazepina') c
WHERE p.drug_id = c.id
  AND strpos(p.precautions_pt, 'eleva a carbamazepina a níveis tóxicos') = 0;

-- =====================================================================
-- Notas:
--  * Os 9 parceiros do ritonavir incluem fluoxetina (recíproco do par
--    critical fluoxetina × ritonavir) — ambos os lados ficam nomeados.
--  * espironolactona × cloreto_potassio: o slug com underscore é o
--    fármaco antigo (duplicado da 254) — o bullet usa o nome
--    "suplementos de potássio (cloreto de potássio)" para cobrir ambos.
--  * A EN da warfarina menciona "ibuprofeno"/"miconazol" como nomes
--    próprios de princípios activos (mantidos tal como na BD para
--    consistência com os slugs).
-- =====================================================================
