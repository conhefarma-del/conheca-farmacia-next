-- ============================================================================
-- 285 — Gravidez/Aleitamento (drug_pregnancy_info) para os 19 fármacos
--       restantes do Lote 1 com zero cobertura (2026-10-01)
-- ---------------------------------------------------------------------------
-- Fecha a dimensão gravidez do Lote 1 (a 284 cobriu misoprostol,
-- metilergometrina, retinol e griseofulvina; estes são os restantes 19).
--
-- Categorias (verificação final): contraindicated ×1 (albendazol) ·
-- compatible ×4 (metildopa, clotrimazol, tiamina, oxitocina) ·
-- caution ×14 (hidralazina, lidocaina, midazolam, atropina, clorpromazina,
-- prometazina, hidroxizina, imipramina, dapsona, mebendazol, ivermectina,
-- pirantel, miconazol, terbinafina). 1+4+14 = 19 ✓
--
-- NOTA metildopa: o Anexo 1 do Prontuário l. 40956 tem "Contra-indicada na
-- gravidez; V. Androgénios" — é um ERRO GRÁFICO do PDF: o texto pertence à
-- entrada dos androgénios (mesterolona, linha anterior). A metildopa é
-- historicamente o anti-hipertensivo de ESCOLHA na gravidez (4.3.1) e é
-- registada como compatible.
--
-- FONTES (corroboradas em fontes_interacoes/prontuario_utf8.txt):
--   Anexo 1 (Fármacos e Gravidez, p. 539+):
--     · metildopa      — l. 40956 (ver nota no cabeçalho; uso de referência
--                        histórico na HTA gravídica)
--     · dapsona        — l. 39906-07: "Hemólise e metahemoglobinemia neonatal;
--                        administrar 5 mg/dia de ácido fólico à mãe" (3º, CM)
--     · lidocaína      — l. 40810: "usar se o benefício for superior" (3º)
--     · midazolam      — l. 41016: "efeito depressor no RN; V. Benzodiazepinas" (DM)
--     · miconazol      — l. 41014: "Evitar, a menos que seja essencial" (CM)
--     · prometazina    — l. 41377 (C ou D)
--     · hidroxizina    — l. 40499: "V. Anti-histamínicos H1. Deve evitar-se" (C)
--     · imipramina     — l. 40528: "evitar, a menos que os benefícios
--                        clínicos potenciais ultrapassem os riscos" (CM)
--     · mebendazol     — l. 40907: "Evitar por toxicidade em estudos animais" (CM)
--     · pirantel       — l. 41331: "Evitar" (C)
--     · amoxicilina+clav — l. 40593-94: "a associação de ácido clavulânico à
--                        amoxicilina aumenta 6 vezes a toxicidade hepática...
--                        precaução na gravidez" (D)
--   Anexo 2 (Fármacos e aleitamento, p. 577+):
--     · albendazol     — l. 42180: "Contra-indicado"
--     · amoxicilina    — l. 42225: "Seguro na dose usual"
--     · atropina       — l. 42248: "precaução; efeitos antimuscarínicos"
--     · dapsona        — l. 42493: "continuar a lactação; risco muito pequeno
--                        excepto se há défice em G6PD; anemia hemolítica"
--     · anti-histamínicos H1 — l. 42199: "recomenda-se evitá-los: sonolência
--                        com a clemastina" (aplica-se a prometazina/hidroxizina)
--     · lidocaína      — l. 42834: "quantidades muito pequenas para ser perigosa"
--     · mebendazol     — l. 42812: "produtor recomenda evitar"
--     · tiamina        — l. 43206: sem entrada restritiva (vitamina; compatível)
--   Anexo 1 não lista atropina, clorpromazina, tiamina, dopamina? (não aplicável
--   aqui), albendazol, ivermectina, terbinafina, clotrimazol — cobertos pelas
--   classes/entradas gerais e EMC-UK SmPC 4.6 (indicado por fármaco).
-- ============================================================================

BEGIN;

INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
   lactation_pt, lactation_en, contraception_pt, contraception_en,
   source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en, v.trimester_pt, v.trimester_en,
       v.lactation_pt, v.lactation_en, v.contraception_pt, v.contraception_en,
       v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES

  -- ------------------------------------------------------------------
  -- 1. Metildopa (Lote 1) — anti-hipertensivo de referência na gravidez
  -- ------------------------------------------------------------------
  ('metildopa', 'compatible',
   'A metildopa é o anti-hipertensivo de referência histórico na hipertensão gravidica, com décadas de experiência e seguimento de crianças expostas sem efeitos adversos a longo prazo. NOTA sobre a fonte: o Anexo 1 do Prontuário tem um erro gráfico na linha "Metildopa — Contra-indicada na gravidez; V. Androgénios" — o texto pertence à entrada dos androgénios (mesterolona); nenhuma fonte séria classifica a metildopa como contraindicada, e o próprio Prontuário (4.3.1.) a descreve como anti-hipertensivo de eleição na gravidez.',
   'Methyldopa is the historical reference antihypertensive in pregnancy hypertension, with decades of experience and follow-up of exposed children without long-term adverse effects. NOTE on the source: the Prontuário Annex 1 contains a graphical error on the line "Methyldopa — Contraindicated in pregnancy; See Androgens" — the text belongs to the androgen entry (mesterolone); no reputable source classifies methyldopa as contraindicated, and the Prontuário itself (4.3.1.) describes it as the antihypertensive of choice in pregnancy.',
   'Compatível em todos os trimestres; dose habitual 250–500 mg 2–3×/dia. Pode causar depressão materna — vigiar. Descontinuar até 6 meses pós-parto? — não; continuar se indicado.',
   'Compatible in all trimesters; usual dose 250–500 mg 2–3×/day. May cause maternal depression — monitor. Continue if indicated postpartum.',
   'Excreta-se no leite em pequenas quantidades; em doses terapêuticas é geralmente considerada compatível com a amamentação (EMC-UK).',
   'Excreted into milk in small amounts; at therapeutic doses generally considered compatible with breastfeeding (EMC-UK).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 4.3.1 (Anti-hipertensores): metildopa como anti-hipertensivo de eleição na gravidez; Anexo 1 l. 40956 (nota de erro gráfico documentada). EMC-UK (MHRA) — SmPC Methyldopa: https://www.medicines.org.uk/emc/product/2195/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — 4.3.1 (Antihypertensives): methyldopa as the antihypertensive of choice in pregnancy; Annex 1 l. 40956 (graphical error documented). EMC-UK (MHRA) — Methyldopa SmPC: https://www.medicines.org.uk/emc/product/2195/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 2. Hidralazina (Lote 1) — HTA gravídica grave, IV hospitalar
  -- ------------------------------------------------------------------
  ('hidralazina', 'caution',
   'A hidralazina IV é usada há décadas na hipertensão grave/pre-eclâmpsia da grávida com ampla experiência clínica, mas dados de segurança sistematizados são limitados: o EMC-UK nota "not been established" e relatos de taquicardia fetal e hipoglicemia neonatal com uso prolongado. Preferir metildopa ou labetalol quando disponíveis; hidralazina reserva-se para crises hipertensivas.',
   'IV hydralazine has been used for decades in severe pregnancy hypertension/pre-eclampsia with extensive clinical experience, but systematic safety data are limited: EMC-UK notes safety "not been established" and reports of fetal tachycardia and neonatal hypoglycaemia with prolonged use. Prefer methyldopa or labetalol when available; hydralazine is reserved for hypertensive crises.',
   'Uso IV/IM em ambiente hospitalar para crises hipertensivas na gravidez e pré-eclâmpsia; monitorizar frequência cardíaca fetal e glicemia neonatal se uso prolongado.',
   'IV/IM use in hospital for hypertensive crises in pregnancy and pre-eclampsia; monitor fetal heart rate and neonatal glucose if prolonged use.',
   'Excreção no leite não bem caracterizada; usar com precaução e vigiar o lactente quanto a hipotensão. Em geral preferir metildopa se amamentar.',
   'Excretion into milk is not well characterised; use with caution and monitor the infant for hypotension. Prefer methyldopa when breastfeeding.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Hydralazine (Apresoline): https://www.medicines.org.uk/emc/product/2372/smpc (secção 4.6). Prontuário Terapêutico INFARMED — 4.3.1 (hidralazina como alternativa nas crises).',
   'EMC-UK (MHRA) — Hydralazine SmPC (Apresoline): https://www.medicines.org.uk/emc/product/2372/smpc (section 4.6). Prontuário Terapêutico INFARMED — 4.3.1 (hydralazine as alternative in crises).'),

  -- ------------------------------------------------------------------
  -- 3. Lidocaína (Lote 1) — anestésico local de referência
  -- ------------------------------------------------------------------
  ('lidocaina', 'caution',
   'A lidocaína em doses de anestesia local é considerada segura na gravidez; o Anexo 1 regista "não se conhecem malformações; usar se o benefício for superior ao risco" (3.º trimestre, factor C). Doses IV elevadas (toxicidade sistémica) associam-se a depressão do SNC e arritmias fetais — respeitar as doses máximas.',
   'Lidocaine at local anaesthetic doses is considered safe in pregnancy; Annex 1 records "no malformations known; use if benefit outweighs risk" (3rd trimester, factor C). High IV doses (systemic toxicity) are associated with fetal CNS depression and arrhythmias — respect maximum doses.',
   'Compatível em todos os trimestres para uso local/Regional; evitar doses tóxicas IV.',
   'Compatible in all trimesters for local/regional use; avoid toxic IV doses.',
   'Presente no leite em quantidades muito pequenas para ser perigosa (Prontuário, Anexo 2, l. 42834) — compatível com a amamentação.',
   'Present in milk in amounts too small to be harmful (Prontuário, Annex 2, l. 42834) — compatible with breastfeeding.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Lidocaína... usar se o benefício for superior" (l. 40810); Anexo 2: "Presente no leite em quantidades muito pequenas" (l. 42834). EMC-UK (MHRA) — SmPC Lidocaine.',
   'Prontuário Terapêutico INFARMED — Annex 1: "Lidocaine... use if benefit outweighs risk" (l. 40810); Annex 2: "Present in milk in amounts too small to be harmful" (l. 42834). EMC-UK (MHRA) — Lidocaine SmPC.'),

  -- ------------------------------------------------------------------
  -- 4. Midazolam (Lote 1) — depressão neonatal
  -- ------------------------------------------------------------------
  ('midazolam', 'caution',
   'Benzodiazepina de meia-vida curta usada em sedação/procedimentos; o Anexo 1 regista "o uso antes da cesariana tem um efeito depressor no RN; V. Benzodiazepinas" (factor DM). Evitar perto do termo; se necessário, administrar a menor dose possível e estar preparado para ressuscitação neonatal (depressão respiratória, hipotonia — "síndrome do bebé mole").',
   'Short-acting benzodiazepine used for sedation/procedures; Annex 1 records "use before caesarean section has a depressant effect on the newborn; See Benzodiazepines" (factor DM). Avoid near term; if necessary, use the lowest possible dose and be prepared for neonatal resuscitation (respiratory depression, hypotonia — "floppy infant syndrome").',
   'Evitar perto do termo e durante o parto; usar apenas se claramente necessário em procedimentos, na menor dose eficaz.',
   'Avoid near term and during labour; use only if clearly necessary for procedures, at the lowest effective dose.',
   'Excreta-se no leite; preferir evitar a amamentação durante 4–6 horas após dose única (meia-vida curta) ou usar alternativa; o Anexo 2 remete para "Benzodiazepinas" (sonolência no lactente).',
   'Excreted into milk; preferably avoid breastfeeding for 4–6 hours after a single dose (short half-life) or use an alternative; Annex 2 refers to "Benzodiazepines" (infant drowsiness).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Midazolam — O uso antes da cesariana tem um efeito depressor no RN; V. Benzodiazepinas" (l. 41016); Anexo 2 (l. 42913). EMC-UK (MHRA) — SmPC Midazolam: https://www.medicines.org.uk/emc/product/5457/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Midazolam — Use before caesarean section has a depressant effect on the newborn; See Benzodiazepines" (l. 41016); Annex 2 (l. 42913). EMC-UK (MHRA) — Midazolam SmPC: https://www.medicines.org.uk/emc/product/5457/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 5. Atropina (Lote 1) — antimuscarínico; precaução no lactente
  -- ------------------------------------------------------------------
  ('atropina', 'caution',
   'Não há entrada específica no Anexo 1 do Prontuário; atravessa a placenta e, em doses terapêuticas, não há relatos de teratogenicidade. Em doses altas perto do termo pode causar taquicardia fetal e depressão neonatal antimuscarínica.',
   'No specific entry in the Prontuário Annex 1; it crosses the placenta and, at therapeutic doses, there are no teratogenicity reports. At high doses near term it may cause fetal tachycardia and neonatal antimuscarinic depression.',
   'Usar apenas se indicado (bradicardia sintomática, pré-anestesia) e na menor dose eficaz; vigiar a frequência cardíaca fetal em doses altas perto do termo.',
   'Use only if indicated (symptomatic bradycardia, anaesthesia premedication) at the lowest effective dose; monitor fetal heart rate at high doses near term.',
   'Usar com precaução; podem verificar-se efeitos antimuscarínicos no lactente (Prontuário, Anexo 2, l. 42248) — em dose única habitual o risco é pequeno; doses elevadas ou repetidas podem reduzir a produção de leite (efeito anticolinérgico).',
   'Use with caution; antimuscarinic effects may occur in the infant (Prontuário, Annex 2, l. 42248) — at the usual single dose the risk is small; high or repeated doses may reduce milk production (anticholinergic effect).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 2: "Atropina — Usar com precaução; efeitos antimuscarínicos no lactente" (l. 42248). Anexo 1: sem entrada específica. EMC-UK (MHRA) — SmPC Atropine.',
   'Prontuário Terapêutico INFARMED — Annex 2: "Atropine — Use with caution; antimuscarinic effects in the infant" (l. 42248). Annex 1: no specific entry. EMC-UK (MHRA) — Atropine SmPC.'),

  -- ------------------------------------------------------------------
  -- 6. Clorpromazina (Lote 1) — antipsicótico fenotiazínico
  -- ------------------------------------------------------------------
  ('clorpromazina', 'caution',
   'Fenotiazina com ampla experiência na gravidez (náuseas gravídicas, psicose): não há evidência consistente de teratogenicidade em doses habituais. Riscos a vigiar no 3.º trimestre/parto: depressão neonatal, icterícia, sintomas extrapiramidais transitórios no RN.',
   'Phenothiazine with extensive pregnancy experience (nausea, psychosis): no consistent evidence of teratogenicity at usual doses. Risks to monitor in the 3rd trimester/delivery: neonatal depression, jaundice, transient extrapyramidal symptoms in the newborn.',
   'Usar apenas se claramente necessário, na menor dose eficaz; evitar doses altas no 3.º trimestre (risco de sintomas neonatais).',
   'Use only if clearly necessary, at the lowest effective dose; avoid high doses in the 3rd trimester (risk of neonatal symptoms).',
   'Excreta-se no leite; o Anexo 2 remete para "Antipsicóticos": sonolência e letargia possíveis no lactente (padrão documentado para a cloropromazina). Preferir alternativa se amamentar; se usar, vigiar sedação do lactente.',
   'Excreted into milk; Annex 2 refers to "Antipsychotics": possible drowsiness and lethargy in the infant (documented pattern for chlorpromazine). Prefer an alternative when breastfeeding; if used, monitor infant sedation.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 2 (cloropromazina, sob "Antipsicóticos"; l. 42424); Anexo 1: sem entrada específica (uso clínico histórico em náuseas gravídicas). EMC-UK (MHRA) — SmPC Chlorpromazine.',
   'Prontuário Terapêutico INFARMED — Annex 2 (chlorpromazine, under "Antipsychotics"; l. 42424); Annex 1: no specific entry (historical use in pregnancy nausea). EMC-UK (MHRA) — Chlorpromazine SmPC.'),

  -- ------------------------------------------------------------------
  -- 7. Prometazina (Lote 1) — fenotiazina anti-histamínica
  -- ------------------------------------------------------------------
  ('prometazina', 'caution',
   'O Anexo 1 classifica a prometazina com factor "C ou D": ampla experiência sem teratogenicidade estabelecida em doses habituais; evitar doses altas e uso prolongado perto do termo pela depressão neonatal (a prometazina é sedativa e os RN são sensíveis).',
   'Annex 1 classifies promethazine as factor "C or D": extensive experience without established teratogenicity at usual doses; avoid high doses and prolonged use near term due to neonatal depression (promethazine is sedating and newborns are sensitive).',
   'Usar em dose única ou curta para náuseas/anafilaxia; evitar uso crónico e perto do termo.',
   'Use as a single dose or short course for nausea/anaphylaxis; avoid chronic use and use near term.',
   'Os anti-histamínicos H1 em geral: "quantidade significativa de alguns anti-histamínicos no leite... recomenda-se evitá-los: sonolência" (Anexo 2, l. 42199). A prometazina é a que tem mais dados: quantidades pequenas, mas vigiar sonolência/irritabilidade do lactente.',
   'H1 antihistamines in general: "significant amounts of some antihistamines in milk... avoidance recommended: drowsiness" (Annex 2, l. 42199). Promethazine has the most data: small amounts, but monitor infant drowsiness/irritability.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Prometazina — C ou D" (l. 41377); Anexo 2: Anti-histamínicos H1 (l. 42199). EMC-UK (MHRA) — SmPC Promethazine (Phenergan).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Promethazine — C or D" (l. 41377); Annex 2: Antihistamines H1 (l. 42199). EMC-UK (MHRA) — Promethazine SmPC (Phenergan).'),

  -- ------------------------------------------------------------------
  -- 8. Hidroxizina (Lote 1) — "Deve evitar-se"
  -- ------------------------------------------------------------------
  ('hidroxizina', 'caution',
   'O Anexo 1 regista "V. Anti-histamínicos H1. Deve evitar-se" (factor C): a hidroxizina deve evitar-se na gravidez, sobretudo no 1.º trimestre e perto do termo. Se for indispensável um antihistamínico, preferir alternativas com mais dados (loratadina, cetirizina) ou clorofeniramina.',
   'Annex 1 records "See Antihistamines H1. Should be avoided" (factor C): hydroxyzine should be avoided in pregnancy, especially in the 1st trimester and near term. If an antihistamine is indispensable, prefer alternatives with more data (loratadine, cetirizine) or chlorphenamine.',
   'Evitar; usar apenas se não houver alternativa e o benefício justificar, na menor dose e período possível.',
   'Avoid; use only if there is no alternative and benefit justifies, at the lowest dose and duration possible.',
   'A hidroxizina remete para "Anti-histamínicos H1" no Anexo 2: "quantidade significativa de alguns anti-histamínicos no leite... recomenda-se evitá-los: sonolência com a clemastina" — evitar a amamentação durante o tratamento.',
   'Hydroxyzine refers to "Antihistamines H1" in Annex 2: "significant amounts of some antihistamines in milk... avoidance recommended: drowsiness with clemastine" — avoid breastfeeding during treatment.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Hidroxizina — V. Anti-histamínicos H1. Deve evitar-se" (l. 40499); Anexo 2: Anti-histamínicos H1 (l. 42199). EMC-UK (MHRA) — SmPC Hydroxyzine (Atarax).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Hydroxyzine — See Antihistamines H1. Should be avoided" (l. 40499); Annex 2: Antihistamines H1 (l. 42199). EMC-UK (MHRA) — Hydroxyzine SmPC (Atarax).'),

  -- ------------------------------------------------------------------
  -- 9. Imipramina (Lote 1) — TCA
  -- ------------------------------------------------------------------
  ('imipramina', 'caution',
   'O Anexo 1 regista "evitar, a menos que os benefícios clínicos potenciais ultrapassem os riscos" (factor CM). Os TCAs têm longa experiência sem sinal de teratogenicidade major; risco no 3.º trimestre: sintomas neonatais de retirada/efeitos anticolinérgicos (jitteriness, retenção urinária).',
   'Annex 1 records "avoid unless potential clinical benefits outweigh risks" (factor CM). TCAs have long experience without a major teratogenicity signal; risk in the 3rd trimester: neonatal withdrawal/anticholinergic symptoms (jitteriness, urinary retention).',
   'Usar apenas se necessário (enurese, depressão sem alternativa), na menor dose eficaz; vigiar sintomas neonatais se uso no 3.º trimestre.',
   'Use only if necessary (enuresis, depression without alternative), at the lowest effective dose; monitor neonatal symptoms if used in the 3rd trimester.',
   'O Anexo 2 remete para "Antidepressores (tricíclicos e afins)": presentes no leite em níveis variáveis; recomenda-se evitar ou vigiar o lactente quanto a sedação. Os TCAs têm níveis lactcionais mais baixos que os ISRS — decisão clínica individualizada.',
   'Annex 2 refers to "Antidepressants (tricyclics and related)": present in milk at variable levels; avoidance or infant monitoring for sedation is recommended. TCAs have lower milk levels than SSRIs — individualised clinical decision.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Imipramina — evitar, a menos que os benefícios clínicos potenciais ultrapassem os riscos" (l. 40528); Anexo 2: Antidepressores (l. 42741). EMC-UK (MHRA) — SmPC Imipramine (Tofranil).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Imipramine — avoid unless potential clinical benefits outweigh risks" (l. 40528); Annex 2: Antidepressants (l. 42741). EMC-UK (MHRA) — Imipramine SmPC (Tofranil).'),

  -- ------------------------------------------------------------------
  -- 10. Dapsona (Lote 1) — hemólise neonatal; folato
  -- ------------------------------------------------------------------
  ('dapsona', 'caution',
   'O Anexo 1 regista "Hemólise e metahemoglobinemia neonatal; administrar 5 mg/dia de ácido fólico à mãe" (3.º trimestre, factor CM). A dapsona é usada na malária (com pirimetamina) e na hanseníase na gravidez quando o benefício justifica; monitorizar bilirrubina e metemoglobina do RN.',
   'Annex 1 records "Neonatal haemolysis and methaemoglobinaemia; administer 5 mg/day folic acid to the mother" (3rd trimester, factor CM). Dapsone is used in malaria (with pyrimethamine) and leprosy in pregnancy when benefit justifies; monitor newborn bilirubin and methaemoglobin.',
   'Usar apenas se claramente necessário; suplementar ácido fólico (5 mg/dia, Prontuário) durante o tratamento; evitar no termo se possível pela hemólise neonatal.',
   'Use only if clearly necessary; supplement folic acid (5 mg/day, Prontuário) during treatment; avoid near term if possible due to neonatal haemolysis.',
   'Compatível com vigilância: "continuar a lactação; risco muito pequeno para o lactente excepto se há défice em G6PD; anemia hemolítica" (Anexo 2, l. 42493). Não amamentar se o lactente tiver G6PD desconhecida/défice — rastreio antes se possível.',
   'Compatible with monitoring: "continue breastfeeding; very small risk for the infant except if G6PD deficient; haemolytic anaemia" (Annex 2, l. 42493). Do not breastfeed if the infant has unknown/deficient G6PD — screen beforehand if possible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Dapsona — Hemólise e metahemoglobinemia neonatal; administrar 5 mg/dia de ácido fólico à mãe" (l. 39906-07); Anexo 2: "Dapsona... défice em G6PD; anemia hemolítica" (l. 42493). EMC-UK (MHRA) — SmPC Dapsone.',
   'Prontuário Terapêutico INFARMED — Annex 1: "Dapsone — Neonatal haemolysis and methaemoglobinaemia; administer 5 mg/day folic acid to the mother" (l. 39906-07); Annex 2: "Dapsone... G6PD deficiency; haemolytic anaemia" (l. 42493). EMC-UK (MHRA) — Dapsone SmPC.'),

  -- ------------------------------------------------------------------
  -- 11. Albendazol (Lote 1) — contra-indicado na lactação; gravidez evitar
  -- ------------------------------------------------------------------
  ('albendazol', 'contraindicated',
   'Benzimidazol que inibe a polimerização da tubulina — mecanismo teoricamente embriotóxico. O Prontuário não tem entrada própria no Anexo 1 (evitar por precaução em todos os trimestres, sobretudo no 1.º); os dados em humanos são limitados, mas estudos de massa (WHO) não mostraram aumento de malformações. EMC-UK: "women should be warned of the potential risk and pregnancy avoided" durante e 1 mês após.',
   'Benzimidazole inhibiting tubulin polymerisation — theoretically embryotoxic mechanism. The Prontuário has no dedicated Annex 1 entry (avoid as precaution in all trimesters, especially the 1st); human data are limited, but mass-treatment studies (WHO) showed no increase in malformations. EMC-UK: "women should be warned of the potential risk and pregnancy avoided" during and for 1 month after.',
   'Evitar em todos os trimestres; tratar antes de engravidar ou postergar até após o 1.º trimestre se clinicamente possível. Teste de gravidez antes se possível.',
   'Avoid in all trimesters; treat before pregnancy or defer until after the 1st trimester if clinically possible. Pregnancy test beforehand if possible.',
   'Contra-indicado (Prontuário, Anexo 2, l. 42180): "Albendazol — Contra-indicado".',
   'Contraindicated (Prontuário, Annex 2, l. 42180): "Albendazole — Contraindicated".',
   'Evitar a gravidez durante o tratamento e 1 mês após (EMC-UK); contracepção eficaz em mulheres em idade fértil.',
   'Avoid pregnancy during treatment and for 1 month after (EMC-UK); effective contraception in women of child-bearing potential.',
   'Prontuário Terapêutico INFARMED — Anexo 2: "Albendazol — Contra-indicado" (l. 42180). EMC-UK (MHRA) — SmPC Albendazole (Zentel): https://www.medicines.org.uk/emc/product/1441/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — Annex 2: "Albendazole — Contraindicated" (l. 42180). EMC-UK (MHRA) — Albendazole SmPC (Zentel): https://www.medicines.org.uk/emc/product/1441/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 12. Mebendazol (Lote 1) — evitar por toxicidade animal
  -- ------------------------------------------------------------------
  ('mebendazol', 'caution',
   'O Anexo 1 regista "Evitar por toxicidade em estudos animais" (factor CM). Como o albendazol, os estudos de tratamento em massa da OMS não mostraram aumento de malformações, mas a etiqueta recomenda evitar — sobretudo no 1.º trimestre.',
   'Annex 1 records "Avoid due to toxicity in animal studies" (factor CM). Like albendazole, WHO mass-treatment studies showed no increase in malformations, but the label recommends avoidance — especially in the 1st trimester.',
   'Evitar, sobretudo no 1.º trimestre; deferir o tratamento se clinicamente possível.',
   'Avoid, especially in the 1st trimester; defer treatment if clinically possible.',
   'O Anexo 2 regista que o produtor recomenda evitar (l. 42812); a absorção sistémica do mebendazol é baixa, pelo que o risco teórico é pequeno — decisão individualizada.',
   'Annex 2 records that the manufacturer recommends avoiding (l. 42812); mebendazole systemic absorption is low, so the theoretical risk is small — individualised decision.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Mebendazol — Evitar por toxicidade em estudos animais" (l. 40907); Anexo 2 (l. 42812). EMC-UK (MHRA) — SmPC Mebendazole (Vermox).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Mebendazole — Avoid due to toxicity in animal studies" (l. 40907); Annex 2 (l. 42812). EMC-UK (MHRA) — Mebendazole SmPC (Vermox).'),

  -- ------------------------------------------------------------------
  -- 13. Ivermectina (Lote 1) — dados limitados; precaução
  -- ------------------------------------------------------------------
  ('ivermectina', 'caution',
   'Sem entrada no Anexo 1 do Prontuário. Os dados publicados de tratamento em massa (WHO/estudos africanos) não mostraram aumento de malformações com exposição no 1.º trimestre, mas os rótulos (EMC/Stromectol) recomendam evitar na gravidez, sobretudo no 1.º trimestre — o risco de oncocercose/filariose não tratada também se pondera.',
   'No entry in the Prontuário Annex 1. Published mass-treatment data (WHO/African studies) showed no increase in malformations with 1st-trimester exposure, but labels (EMC/Stromectol) recommend avoidance in pregnancy, especially the 1st trimester — the risk of untreated onchocerciasis/filariasis is also weighed.',
   'Evitar, sobretudo no 1.º trimestre; usar se o benefício (doença filarial grave) justificar.',
   'Avoid, especially in the 1st trimester; use if benefit (severe filarial disease) justifies.',
   'Excreção no leite não bem caracterizada; evitar a amamentação durante o tratamento e por ~1 semana após (meia-vida longa do metabolito) por precaução.',
   'Excretion into milk is not well characterised; avoid breastfeeding during treatment and for ~1 week after (long metabolite half-life) as a precaution.',
   'Evitar a gravidez durante e 1 mês após o tratamento (EMC-UK).',
   'Avoid pregnancy during and for 1 month after treatment (EMC-UK).',
   'EMC-UK (MHRA) — SmPC Ivermectin (Stromectol): https://www.medicines.org.uk/emc/product/2917/smpc (secção 4.6). WHO Mectizan donation programme data (observacional).',
   'EMC-UK (MHRA) — Ivermectin SmPC (Stromectol): https://www.medicines.org.uk/emc/product/2917/smpc (section 4.6). WHO Mectizan donation programme data (observational).'),

  -- ------------------------------------------------------------------
  -- 14. Pirantel (Lote 1) — "Evitar"
  -- ------------------------------------------------------------------
  ('pirantel', 'caution',
   'O Anexo 1 regista "Evitar" (factor C). Absorção sistémica baixa; usar apenas se claramente necessário e a alternativa (mebendazol) não for adequada.',
   'Annex 1 records "Avoid" (factor C). Low systemic absorption; use only if clearly necessary and if the alternative (mebendazole) is not suitable.',
   'Evitar; deferir o tratamento desparasitante para após a gravidez se possível.',
   'Avoid; defer deworming treatment until after pregnancy if possible.',
   'Excreção no leite pouco caracterizada; a baixa absorção sistémica torna o risco teórico pequeno — compatível com precaução.',
   'Milk excretion poorly characterised; low systemic absorption makes the theoretical risk small — compatible with caution.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Pirantel — Evitar" (l. 41331). EMC-UK — SmPC Pyrantel (em países com registo).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Pyrantel — Avoid" (l. 41331). EMC-UK — Pyrantel SmPC (in countries with registration).'),

  -- ------------------------------------------------------------------
  -- 15. Miconazol (Lote 1) — "Evitar, a menos que seja essencial" (sistémico)
  -- ------------------------------------------------------------------
  ('miconazol', 'caution',
   'O Anexo 1 regista "Evitar, a menos que seja essencial" (factor CM) — aplica-se ao miconazol oral sistémico/gel bucal, com absorção parcial. O tópico vaginal/creme cutâneo tem absorção negligenciável e é o tratamento de escolha da candidíase vulvovaginal na gravidez.',
   'Annex 1 records "Avoid, unless essential" (factor CM) — applies to oral systemic miconazol/oral gel, with partial absorption. Vaginal topical/cutaneous cream has negligible absorption and is the treatment of choice for vulvovaginal candidiasis in pregnancy.',
   'Formulações tópicas (creme vaginal/cutâneo) são preferíveis e seguras; evitar o gel oral/sistémico salvo necessidade.',
   'Topical formulations (vaginal/cutaneous cream) are preferable and safe; avoid the oral gel/systemic form unless needed.',
   'O Anexo 2 remete para "Benzodiazepinas"? — não: a entrada "Miconazol — V. Benzodiazepinas" (l. 42912) é outro erro de remissão do PDF (pertence à linha anterior). O tópico vaginal é compatível; o gel oral em doses altas vigiar o lactente.',
   'Annex 2 refers to "Benzodiazepines"? — no: the entry "Miconazole — See Benzodiazepines" (l. 42912) is another PDF cross-reference error (belongs to the previous line). Vaginal topical is compatible; oral gel at high doses — monitor the infant.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Miconazol — Evitar, a menos que seja essencial" (l. 41014); Anexo 2 l. 42912 (nota de erro de remissão documentada). EMC-UK (MHRA) — SmPC Miconazole (Daktarin) e Gyno-Daktar.',
   'Prontuário Terapêutico INFARMED — Annex 1: "Miconazole — Avoid, unless essential" (l. 41014); Annex 2 l. 42912 (cross-reference error documented). EMC-UK (MHRA) — Miconazole SmPC (Daktarin) and Gyno-Daktar.'),

  -- ------------------------------------------------------------------
  -- 16. Terbinafina (Lote 1) — dados limitados; precaução
  -- ------------------------------------------------------------------
  ('terbinafina', 'caution',
   'Sem entrada no Anexo 1 do Prontuário. A terbinafina não é teratogénica em animais, mas os dados humanos são limitados; os rótulos (EMC/Lamisil) recomendam evitar na gravidez, salvo se claramente necessário (onicomicose não é urgência — pode tratar-se após o parto).',
   'No entry in the Prontuário Annex 1. Terbinafine is not teratogenic in animals, but human data are limited; labels (EMC/Lamisil) recommend avoiding in pregnancy unless clearly necessary (onychomycosis is not an emergency — treat after delivery).',
   'Evitar; adiar o tratamento de micoses não urgentes para após o parto.',
   'Avoid; defer treatment of non-urgent mycoses until after delivery.',
   'A terbinafina excreta-se no leite (níveis elevados em animais); EMC recomenda evitar a amamentação durante o tratamento.',
   'Terbinafine is excreted into milk (elevated levels in animals); EMC recommends avoiding breastfeeding during treatment.',
   '',
   '',
   'EMC-UK (MHRA) — SmPC Terbinafine (Lamisil): https://www.medicines.org.uk/emc/product/2647/smpc (secção 4.6). Prontuário Terapêutico INFARMED — 7.1.2 (Antifúngicos).',
   'EMC-UK (MHRA) — Terbinafine SmPC (Lamisil): https://www.medicines.org.uk/emc/product/2647/smpc (section 4.6). Prontuário Terapêutico INFARMED — 7.1.2 (Antifungals).'),

  -- ------------------------------------------------------------------
  -- 17. Clotrimazol (Lote 1) — tópico; compatível
  -- ------------------------------------------------------------------
  ('clotrimazol', 'compatible',
   'Sem entrada no Anexo 1 do Prontuário (uso tópico, absorção sistémica negligenciável). O clotrimazol vaginal/creme é o tratamento de 1.ª linha da candidíase vulvovaginal na gravidez, em qualquer trimestre — décadas de uso sem sinal de risco fetal.',
   'No entry in the Prontuário Annex 1 (topical use, negligible systemic absorption). Vaginal clotrimazole/cream is the first-line treatment for vulvovaginal candidiasis in pregnancy, in any trimester — decades of use without a fetal risk signal.',
   'Compatível em todos os trimestres para uso tópico vaginal/cutâneo; a aplicação intravaginal profunda ao deitar reduz o desconforto.',
   'Compatible in all trimesters for topical vaginal/cutaneous use; deep intravaginal application at bedtime reduces discomfort.',
   'Absorção sistémica negligenciável — compatível com a amamentação; evitar a aplicação do creme nos seios (o lactente pode ingerir excipientes).',
   'Negligible systemic absorption — compatible with breastfeeding; avoid applying the cream to the breasts (the infant may ingest excipients).',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 7.1.2 (Antifúngicos tópicos); EMC-UK (MHRA) — SmPC Clotrimazole (Canesten): https://www.medicines.org.uk/emc/product/2973/smpc (secção 4.6).',
   'Prontuário Terapêutico INFARMED — 7.1.2 (Topical antifungals); EMC-UK (MHRA) — Clotrimazole SmPC (Canesten): https://www.medicines.org.uk/emc/product/2973/smpc (section 4.6).'),

  -- ------------------------------------------------------------------
  -- 18. Tiamina (Lote 1) — vitamina; compatível
  -- ------------------------------------------------------------------
  ('tiamina', 'compatible',
   'Sem entrada restritiva nos Anexos: a tiamina é uma vitamina essencial, necessária em doses maiores na gravidez (metabolismo aumentado) e no alcoolismo (profilaxia de Wernicke). Em doses fisiológicas/suplementares não há risco fetal conhecido.',
   'No restrictive entry in the Annexes: thiamine is an essential vitamin, needed in larger amounts in pregnancy (increased metabolism) and in alcoholism (Wernicke prophylaxis). At physiological/supplementary doses there is no known fetal risk.',
   'Compatível em todos os trimestres; a suplementação é recomendada em situações de risco (alcoolismo, hiperemese com parentérica).',
   'Compatible in all trimesters; supplementation is recommended in at-risk situations (alcoholism, hyperemesis with parenteral route).',
   'Sem entrada restritiva no Anexo 2; a tiamina passa para o leite e é segura nas doses habituais — compatível.',
   'No restrictive entry in Annex 2; thiamine passes into milk and is safe at usual doses — compatible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — 11.3.1 (Vitaminas); Anexo 2 l. 43206 (sem restrição).',
   'Prontuário Terapêutico INFARMED — 11.3.1 (Vitamins); Annex 2 l. 43206 (no restriction).'),

  -- ------------------------------------------------------------------
  -- 19. Oxitocina (Lote 1) — uso obstétrico padrão
  -- ------------------------------------------------------------------
  ('oxitocina', 'compatible',
   'A oxitocina é a hormona endógena do parto; a oxitocina sintética é o uterotónico de 1.ª linha na indução/aumento do trabalho de parto e na profilaxia/tratamento da hemorragia pós-parto — uso obstétrico padrão em todos os hospitais. O Anexo 1 regista a entrada com a nota sobre doses altas a termo; os riscos (hiperbilrubinemia neonatal, hiponatremia com infusão prolongada) são conhecidos e vigiados.',
   'Oxytocin is the endogenous birth hormone; synthetic oxytocin is the first-line uterotonic for induction/augmentation of labour and prevention/treatment of postpartum haemorrhage — standard obstetric practice in all hospitals. Annex 1 records the entry with a note on high doses at term; risks (neonatal hyperbilirubinaemia, hyponatraemia with prolonged infusion) are known and monitored.',
   'Uso obstétrico padrão (indução, condução do parto, PPH); administrar com vigilância cardiotocográfica materna e fetal; evitar doses altas prolongadas a termo (hiponatremia fetal).',
   'Standard obstetric use (induction, labour augmentation, PPH); administer with maternal and fetal cardiotocographic monitoring; avoid prolonged high doses at term (fetal hyponatraemia).',
   'A oxitocina é destruída pela oxitocinase no plasma; passa pouco para o leite e não há relatos de efeitos adversos no lactente nas doses obstétricas — compatível.',
   'Oxytocin is destroyed by plasma oxytocinase; little passes into milk and there are no reports of adverse effects in infants at obstetric doses — compatible.',
   '',
   '',
   'Prontuário Terapêutico INFARMED — Anexo 1: "Oxitocina" (l. 41209); 7.2.1 (Ocitócicos). EMC-UK (MHRA) — SmPC Oxytocin (Syntocinon).',
   'Prontuário Terapêutico INFARMED — Annex 1: "Oxytocin" (l. 41209); 7.2.1 (Oxytocics). EMC-UK (MHRA) — Oxytocin SmPC (Syntocinon).')

) AS v(slug, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en,
       lactation_pt, lactation_en, contraception_pt, contraception_en,
       source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;

COMMIT;

-- ============================================================================
-- Verificações pós-migração (esperado):
--   SELECT count(*) FROM public.drug_pregnancy_info p
--     JOIN public.drugs d ON d.id = p.drug_id
--     WHERE d.slug IN ('metildopa','hidralazina','lidocaina','midazolam',
--                      'atropina','clorpromazina','prometazina','hidroxizina',
--                      'imipramina','dapsona','albendazol','mebendazol',
--                      'ivermectina','pirantel','miconazol','terbinafina',
--                      'clotrimazol','tiamina','oxitocina')
--       AND p.is_archived = false;
--   → 19 (Lote 1 fica 23/23 na dimensão gravidez)
--
-- Categorias: contraindicated ×1 (albendazol) · caution ×14 (hidralazina,
-- lidocaina, midazolam, atropina, clorpromazina, prometazina, hidroxizina,
-- imipramina, dapsona, mebendazol, ivermectina, pirantel, miconazol,
-- terbinafina) · compatible ×4 (metildopa, clotrimazol, tiamina, oxitocina)
-- 1+14+4 = 19 ✓
-- ============================================================================
