-- ============================================================================
-- 288 — Enriquecimento das precautions das 33 fichas de fármacos
--       CONTRAINDICADOS na gravidez sem menção nas fichas (padrão 282)
--       + resolução dos 6 registos no_data de drug_pregnancy_info
-- ---------------------------------------------------------------------------
-- PARTE A: 33 UPDATEs idempotentes (guarda strpos sobre o marcador único
--          "• GRAVIDEZ:") que acrescentam um bullet à ficha com a
--          contraindicação e a alternativa segura. Nunca substituem texto.
-- PARTE B: no_data × 6:
--   · daptomicina  → contraindicated (Prontuário l. 2789: "Contra-Ind. e
--     Prec.: Gravidez e aleitamento" — registo 1:1 completo, UPDATE)
--   · febuxostat   → caution (EMC/Adenuric 4.6: "não recomendada em mulheres
--     a amamentar; dados limitados na gravidez" — registo no_data JÁ EXISTE
--     na BD; upgrade 1:1 por UPDATE com guarda pregnancy_category='no_data')
--   · tadalafil, vardenafil, tansulosina, degarelix → mantêm no_data com
--     justificação documentada (fármacos de uso exclusivamente masculino:
--     disfunção eréctil/HBP/cancro da próstata — exposição fetal sem cenário
--     clínico; a categoria no_data é honesta e suficiente).
-- Idempotente: reaplicar = 0 mudanças.
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------
-- PARTE A — 33 UPDATEs (padrão 282, guarda strpos = 0)
-- ---------------------------------------------------------------------

-- 1. WARFARINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — teratogénica (síndrome do feto varfarínico no 1.º trimestre) e hemorragia fetal no 3.º. Usar HEPARINA (não atravessa a placenta) se anticoagulação necessária; não amamentar sem avaliação médica.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — teratogenic (fetal warfarin syndrome in the 1st trimester) and fetal bleeding in the 3rd. Use HEPARIN (does not cross the placenta) if anticoagulation is needed; do not breastfeed without medical evaluation.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'warfarina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 2. ATORVASTATINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — suspender imediatamente se houver gravidez confirmada ou planeada (segurança não estabelecida; anomalias congénitas relatadas com estatinas). Repor a estatina após a amamentação.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — discontinue immediately if pregnancy is confirmed or planned (safety not established; congenital anomalies reported with statins). Resume the statin after breastfeeding.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'atorvastatina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 3. AMIODARONA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — risco de hipotiroidismo fetal, neurodesenvolvimento afectado e bradicardia neonatal (alto teor de iodo); usar apenas em arritmias que ameaçam a vida, preferindo alternativas; amamentação desaconselhada.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — risk of fetal hypothyroidism, impaired neurodevelopment and neonatal bradycardia (high iodine content); use only in life-threatening arrhythmias, preferring alternatives; breastfeeding not advised.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'amiodarona') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 4. APIXABANO
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — dados de segurança insuficientes nos anticoagulantes orais directos; usar HEPARINA de baixo peso molecular se anticoagulação necessária na gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — insufficient safety data for direct oral anticoagulants; use LOW-MOLECULAR-WEIGHT HEPARIN if anticoagulation is needed in pregnancy.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'apixabano') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 5. RIVAROXABANO
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — dados de segurança insuficientes; usar HEPARINA de baixo peso molecular se anticoagulação necessária na gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — insufficient safety data; use LOW-MOLECULAR-WEIGHT HEPARIN if anticoagulation is needed in pregnancy.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'rivaroxabano') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 6. DABIGATRANO
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — dados insuficientes; usar HEPARINA de baixo peso molecular se anticoagulação necessária na gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — insufficient data; use LOW-MOLECULAR-WEIGHT HEPARIN if anticoagulation is needed in pregnancy.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'dabigatrano') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 7. CAPREOMICINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: evitar — ototoxicidade e nefrotoxicidade potenciais para o feto (como os aminoglicosídeos); usar apenas se o tratamento da TB multirresistente não tiver alternativa e o benefício justificar.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: avoid — potential fetal ototoxicity and nephrotoxicity (as with aminoglycosides); use only if MDR-TB treatment has no alternative and benefit justifies.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'capreomicina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 8. ALENDRONATO
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — bifosfonatos acumulam no osso durante anos; evitar na gravidez e suspendê-los antes de conceber.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — bisphosphonates accumulate in bone for years; avoid in pregnancy and discontinue before conceiving.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'alendronato') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 9. EMPAGLIFLOZINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — os antidiabéticos orais não são adequados na gravidez; usar INSULINA (não atravessa a placenta) se necessário.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — oral antidiabetics are not appropriate in pregnancy; use INSULIN (does not cross the placenta) if needed.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'empagliflozina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 10. DAPAGLIFLOZINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — os antidiabéticos orais não são adequados na gravidez; usar INSULINA se necessário.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — oral antidiabetics are not appropriate in pregnancy; use INSULIN if needed.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'dapagliflozina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 11. GLICLAZIDA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — sulfonilureias atravessam a placenta e causam hipoglicemia neonatal; usar INSULINA (antidiabético de escolha na gravidez).',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — sulfonylureas cross the placenta and cause neonatal hypoglycaemia; use INSULIN (the antidiabetic of choice in pregnancy).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'gliclazida') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 12. GLIMEPIRIDA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — sulfonilureias atravessam a placenta e causam hipoglicemia neonatal; usar INSULINA.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — sulfonylureas cross the placenta and cause neonatal hypoglycaemia; use INSULIN.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'glimepirida') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 13. ESTRADIOL
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — estrogénios não têm indicação na gravidez; suspender imediatamente se houver gravidez (a exposição inadvertida de curta duração não prejudica o feto).',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — oestrogens have no indication in pregnancy; discontinue immediately if pregnancy occurs (short inadvertent exposure does not harm the fetus).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'estradiol') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 14. TELITROMICINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: usar apenas se claramente necessário — sem estudos adequados em grávidas; preferir macrólidos com mais dados (eritromicina, azitromicina).',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: use only if clearly necessary — no adequate studies in pregnant women; prefer macrolides with more data (erythromycin, azithromycin).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'telitromicina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 15. CETOCONAZOL (oral)
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado na forma oral — azóis sistémicos são embriotóxicos em animais; para candidíase vaginal/cutânea usar azóis TÓPICOS (clotrimazol, miconazol creme), que são seguros.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: oral form contraindicated — systemic azoles are embryotoxic in animals; for vaginal/cutaneous candidiasis use TOPICAL azoles (clotrimazole, miconazole cream), which are safe.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'cetoconazol') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 16. ITRACONAZOL
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — azól sistémico embriotóxico em animais; adiar o tratamento para após o parto salvo micose sistémica grave; usar tópicos quando aplicável.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — embryotoxic systemic azole; defer treatment until after delivery unless severe systemic mycosis; use topicals when applicable.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'itraconazol') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 17. VORICONAZOL
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — embriotóxico em animais (estudos em ratos e coelhos); evitar na gravidez salvo infeção fúngica invasiva que ameace a vida sem alternativa.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — embryotoxic in animals (rat and rabbit studies); avoid in pregnancy unless life-threatening invasive fungal infection with no alternative.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'voriconazol') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 18. KETOROLACO
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado no 3.º trimestre (fecho prematuro do canal arterial, oligohidramnia, risco hemorrágico) e evitar nos restantes; usar paracetamol como analgésico da gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated in the 3rd trimester (premature ductus arteriosus closure, oligohydramnios, bleeding risk) and best avoided in the others; use paracetamol as the pregnancy analgesic.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'ketorolaco') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 19. PIROXICAM
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado no 3.º trimestre (fecho do canal arterial, oligohidramnia); evitar nos restantes trimestres; usar paracetamol.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated in the 3rd trimester (ductus arteriosus closure, oligohydramnios); avoid in the others; use paracetamol.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'piroxicam') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 20. MELOXICAM
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado no 3.º trimestre (fecho do canal arterial); evitar nos restantes trimestres; usar paracetamol.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated in the 3rd trimester (ductus arteriosus closure); avoid in the others; use paracetamol.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'meloxicam') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 21. INDOMETACINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado no 3.º trimestre (fecho do canal arterial, oligohidramnia — o AINE com mais casos descritos); evitar nos restantes; usar paracetamol.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated in the 3rd trimester (ductus arteriosus closure, oligohydramnios — the NSAID with most reported cases); avoid in the others; use paracetamol.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'indometacina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 22. NIMESULIDA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — AINE inibidor de COX-2; no 3.º trimestre provoca fecho do canal arterial e oligohidramnia; usar paracetamol.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — COX-2 inhibiting NSAID; in the 3rd trimester it causes ductus arteriosus closure and oligohydramnios; use paracetamol.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'nimesulida') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 23. ZONISAMIDA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — teratogénica em animais (malformações fetais); não suspender abruptamente se já em uso e gravidez ocorrer: rever com neurologista; ácido fólico 5 mg/dia se mantida.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — teratogenic in animals (fetal malformations); do not stop abruptly if already in use and pregnancy occurs: review with a neurologist; folic acid 5 mg/day if continued.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'zonisamida') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 24. TAFENOQUINA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — não se conhece o estado G6PD do feto e a tafenoquina causa hemólise potencialmente grave em deficitários; a radicaroterapia (primaquina/tafenoquina) deve ser adiada para após o parto e o desmame.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — fetal G6PD status is unknown and tafenoquine causes potentially severe haemolysis in deficient individuals; radical cure (primaquine/tafenoquine) must be deferred until after delivery and weaning.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'tafenoquina') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 25. ROFLUMILAST
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: evitar — sem estudos adequados; a DPOC da grávida deve ser tratada com broncodilatadores inalados e corticoide inalado conforme o plano de asma/DPOC da gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: avoid — no adequate studies; COPD in pregnancy should be treated with inhaled bronchodilators and inhaled corticosteroid per the pregnancy asthma/COPD plan.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'roflumilast') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 26. BISOPROLOL
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — β-bloqueadores causam atraso do crescimento intrauterino, bradicardia e hipoglicemia neonatais; preferir metildopa ou labetalol como anti-hipertensivo da gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — beta-blockers cause intrauterine growth restriction, neonatal bradycardia and hypoglycaemia; prefer methyldopa or labetalol as the pregnancy antihypertensive.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'bisoprolol') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 27. LORAZEPAM
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: evitar, sobretudo no 1.º trimestre e perto do termo — risco de malformações e síndrome do bebé mole (hipotonia, depressão respiratória) no RN; suspender gradualmente se em uso crónico e rever com médico.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: avoid, especially in the 1st trimester and near term — malformation risk and floppy infant syndrome (hypotonia, respiratory depression); taper gradually if in chronic use and review with the doctor.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'lorazepam') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 28. ZOLPIDEM
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — hipnótico; risco de depressão neonatal e sedação se usado perto do parto; usar medidas não farmacológicas de sono na gravidez.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — hypnotic; risk of neonatal depression and sedation if used near delivery; use non-pharmacological sleep measures in pregnancy.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'zolpidem') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 29. TESTOSTERONA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — androgénios causam virilização do feto feminino (hipertrofia do clitóris, fusão labioescrotal) em todos os trimestres (factor D); contraindicado também durante a amamentação.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — androgens cause virilisation of the female fetus (clitoral hypertrophy, labioscrotal fusion) in all trimesters (factor D); also contraindicated during breastfeeding.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'testosterona') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 30. FLUTAMIDA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — antiandrogénio: uma mulher grávida não deve tomar, e uma GRÁVIDA não deve manusear o medicamento (risco teórico de feminização de feto masculino por contacto); uso exclusivo em homens.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — antiandrogen: a pregnant woman should not take it, and a PREGNANT woman should not handle the medication (theoretical risk of male fetus feminisation through contact); male-only use.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'flutamida') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 31. PIOGLITAZONA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicada — os antidiabéticos orais não são adequados na gravidez; usar INSULINA.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — oral antidiabetics are not appropriate in pregnancy; use INSULIN.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'pioglitazona') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 32. ANASTROZOL
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: contraindicado — inibidor da aromatase; não tem indicação na gravidez (uso em cancro da mama pós-menopáusico); confirmar ausência de gravidez antes de iniciar.',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: contraindicated — aromatase inhibitor; has no indication in pregnancy (use in postmenopausal breast cancer); confirm absence of pregnancy before starting.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'anastrozol') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- 33. NOREISTERONA
UPDATE public.drug_profiles p
SET precautions_pt = p.precautions_pt || E'\n• GRAVIDEZ: não instituir terapêutica de substituição durante a gravidez (Anexo 1); a exposição inadvertida de curta duração não é indicação para interrupção; progestagénios não suprimem a lactação (ao contrário dos estrogénios).',
    precautions_en = p.precautions_en || E'\n• PREGNANCY: do not start replacement therapy during pregnancy (Annex 1); short inadvertent exposure is not an indication for termination; progestogens do not suppress lactation (unlike oestrogens).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'noreisterona') w
WHERE p.drug_id = w.id
  AND strpos(p.precautions_pt, '• GRAVIDEZ:') = 0;

-- ---------------------------------------------------------------------
-- PARTE B — resolução dos 6 no_data de drug_pregnancy_info
-- ---------------------------------------------------------------------
-- B.1: daptomicina → contraindicated (Prontuário l. 2789: "Contra-Ind. e
--      Prec.: Gravidez e aleitamento") — UPDATE do registo existente.
UPDATE public.drug_pregnancy_info dpi
SET pregnancy_category = 'contraindicated',
    risk_pt = 'Contraindicada na gravidez e no aleitamento (Prontuário, secção 1.1.11, entrada DAPTOMICINA: "Contra-Ind. e Prec.: Gravidez e aleitamento"). Os dados humanos são muito limitados; usar apenas se o benefício (infeção grave por S. aureus resistente) claramente ultrapassar o risco.',
    risk_en = 'Contraindicated in pregnancy and breastfeeding (Prontuário, section 1.1.11, DAPTOMICINA entry: "Contraindications and precautions: pregnancy and breastfeeding"). Human data are very limited; use only if the benefit (severe resistant S. aureus infection) clearly outweighs the risk.',
    trimester_pt = 'Evitar em todos os trimestres; usar salvo necessidade clínica grave sem alternativa.',
    trimester_en = 'Avoid in all trimesters; use only for serious clinical need without alternative.',
    lactation_pt = 'Contraindicado o aleitamento durante o tratamento (Prontuário); desconhece-se a excreção no leite.',
    lactation_en = 'Breastfeeding contraindicated during treatment (Prontuário); excretion into milk unknown.',
    contraception_pt = '',
    contraception_en = '',
    source_pt = 'Prontuário Terapêutico INFARMED — 1.1.11, DAPTOMICINA: "Contra-Ind. e Prec.: Gravidez e aleitamento" (l. 2789).',
    source_en = 'Prontuário Terapêutico INFARMED — 1.1.11, DAPTOMICIN: "Contraindications and precautions: pregnancy and breastfeeding" (l. 2789).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'daptomicina') w
WHERE dpi.drug_id = w.id
  AND dpi.pregnancy_category = 'no_data';

-- B.2: febuxostat → caution (EMC/Adenuric 4.6: dados limitados; não
--      recomendado em lactação) — UPDATE do registo no_data JÁ EXISTENTE
--      (verificação BD pré-migração: 1 linha pregnancy_category='no_data').
UPDATE public.drug_pregnancy_info dpi
SET pregnancy_category = 'caution',
    risk_pt = 'Dados limitados na gravidez; o EMC (Adenuric) regista "Febuxostat should not be used during pregnancy" como precaução geral e "not known whether excreted in human milk" — tratar a hiperuricemia/gota com allopurinol-adjacentes só se necessário e preferir adiá-la para após a gravidez.',
    risk_en = 'Limited data in pregnancy; the EMC (Adenuric) records "Febuxostat should not be used during pregnancy" as a general precaution and "not known whether excreted in human milk" — manage hyperuricaemia/gout only if necessary and prefer deferring until after pregnancy.',
    trimester_pt = 'Evitar; adiar o tratamento da gota para após o parto salvo crises frequentes (usar colquicina na menor dose se necessário).',
    trimester_en = 'Avoid; defer gout treatment until after delivery except in frequent attacks (use colchicine at the lowest dose if needed).',
    lactation_pt = 'Não recomendado (EMC 4.6: "should not be used during breastfeeding"); a excreção no leite é desconhecida.',
    lactation_en = 'Not recommended (EMC 4.6: "should not be used during breastfeeding"); excretion into milk unknown.',
    contraception_pt = '',
    contraception_en = '',
    source_pt = 'EMC-UK (MHRA) — SmPC Febuxostat (Adenuric): https://www.medicines.org.uk/emc/product/2587/smpc (secção 4.6).',
    source_en = 'EMC-UK (MHRA) — Febuxostat SmPC (Adenuric): https://www.medicines.org.uk/emc/product/2587/smpc (section 4.6).',
    status = 'published',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'febuxostat') w
WHERE dpi.drug_id = w.id
  AND dpi.pregnancy_category = 'no_data';

-- B.3: justificação documentada para os 4 restantes (fármacos de uso
--      exclusivamente masculino). O registo no_data é mantido e a
--      justificação fica gravada nos campos de risco (UPDATE in-place).
--      tadalafil, vardenafil — inibidores da PDE5 (disfunção eréctil)
--      tansulosina — alfa-1 bloqueador (hiperplasia benigna da próstata)
--      degarelix — antagonista GnRH (cancro da próstata)
UPDATE public.drug_pregnancy_info dpi
SET risk_pt = 'Fármaco de uso EXCLUSIVAMENTE MASCULINO (disfunção eréctil). Não existem estudos de gravidez porque não há cenário clínico de exposição fetal — a categoria no_data é honesta e suficiente. Nota teórica: inibidores da PDE5 não são teratogénicos em animais.',
    risk_en = 'MALE-ONLY drug (erectile dysfunction). No pregnancy studies exist because there is no clinical scenario of fetal exposure — the no_data category is honest and sufficient. Theoretical note: PDE5 inhibitors are not teratogenic in animals.',
    trimester_pt = 'Sem indicação em mulheres; sem exposição fetal esperada.',
    trimester_en = 'No indication in women; no fetal exposure expected.',
    lactation_pt = 'Sem cenário de uso em lactação.',
    lactation_en = 'No breastfeeding use scenario.',
    source_pt = 'Justificação documentada (auditoria 288): uso exclusivamente masculino — EMC-UK SmPC 4.6 não define categoria de gravidez.',
    source_en = 'Documented justification (audit 288): male-only use — EMC-UK SmPC 4.6 defines no pregnancy category.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug IN ('tadalafil','vardenafil')) w
WHERE dpi.drug_id = w.id
  AND dpi.pregnancy_category = 'no_data';

UPDATE public.drug_pregnancy_info dpi
SET risk_pt = 'Fármaco de uso EXCLUSIVAMENTE MASCULINO (hiperplasia benigna da próstata). Não existem estudos de gravidez porque não há cenário clínico de exposição fetal — a categoria no_data é honesta e suficiente. Nota teórica: os alfa-1 bloqueadores são usados na gravidez em hipertensão (doxazosina) sem sinal de teratogenicidade.',
    risk_en = 'MALE-ONLY drug (benign prostatic hyperplasia). No pregnancy studies exist because there is no clinical scenario of fetal exposure — the no_data category is honest and sufficient. Theoretical note: alpha-1 blockers are used in pregnancy hypertension (doxazosin) with no teratogenicity signal.',
    trimester_pt = 'Sem indicação em mulheres; sem exposição fetal esperada.',
    trimester_en = 'No indication in women; no fetal exposure expected.',
    lactation_pt = 'Sem cenário de uso em lactação.',
    lactation_en = 'No breastfeeding use scenario.',
    source_pt = 'Justificação documentada (auditoria 288): uso exclusivamente masculino — EMC-UK SmPC 4.6 não define categoria de gravidez.',
    source_en = 'Documented justification (audit 288): male-only use — EMC-UK SmPC 4.6 defines no pregnancy category.',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'tansulosina') w
WHERE dpi.drug_id = w.id
  AND dpi.pregnancy_category = 'no_data';

UPDATE public.drug_pregnancy_info dpi
SET risk_pt = 'Fármaco de uso EXCLUSIVAMENTE MASCULINO (cancro da próstata). Não existem estudos de gravidez porque não há cenário clínico de exposição fetal — a categoria no_data é honesta e suficiente. Nota teórica: antagonistas da GnRH induzem hipogonadismo materno se administrados a uma mulher — o Prontuário regista "Pré-menopausa, gravidez" nas contra-indicações (l. 37401).',
    risk_en = 'MALE-ONLY drug (prostate cancer). No pregnancy studies exist because there is no clinical scenario of fetal exposure — the no_data category is honest and sufficient. Theoretical note: GnRH antagonists induce maternal hypogonadism if given to a woman — the Prontuário records "pre-menopause, pregnancy" among contraindications (l. 37401).',
    trimester_pt = 'Sem indicação em mulheres; contraindicado na pré-menopausa e gravidez (Prontuário l. 37401).',
    trimester_en = 'No indication in women; contraindicated pre-menopause and in pregnancy (Prontuário l. 37401).',
    lactation_pt = 'Sem cenário de uso em lactação.',
    lactation_en = 'No breastfeeding use scenario.',
    source_pt = 'Justificação documentada (auditoria 288): uso exclusivamente masculino; Prontuário l. 37401 ("Pré-menopausa, gravidez" nas contra-indicações do degarelix).',
    source_en = 'Documented justification (audit 288): male-only use; Prontuário l. 37401 ("pre-menopause, pregnancy" among degarelix contraindications).',
    updated_at = now()
FROM (SELECT d.id FROM public.drugs d WHERE d.slug = 'degarelix') w
WHERE dpi.drug_id = w.id
  AND dpi.pregnancy_category = 'no_data';

COMMIT;

-- ============================================================================
-- Verificações pós-migração (esperado):
--   A. SELECT count(*) FROM drug_profiles p JOIN drugs d ON d.id = p.drug_id
--      WHERE d.slug IN (<33 slugs>) AND strpos(p.precautions_pt,'• GRAVIDEZ:') > 0;
--      → 33
--   B. SELECT d.slug, dpi.pregnancy_category FROM drug_pregnancy_info dpi
--      JOIN drugs d ON d.id = dpi.drug_id
--      WHERE d.slug IN ('febuxostat','tadalafil','vardenafil','tansulosina',
--                       'daptomicina','degarelix');
--      → febuxostat = caution (novo) · daptomicina = contraindicated (upgrade)
--      → tadalafil/vardenafil/tansulosina/degarelix = no_data com justificação
-- ============================================================================
