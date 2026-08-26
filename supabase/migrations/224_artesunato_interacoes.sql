-- =====================================================================
-- 224 — Artesunato: interações fármaco-fármaco
-- Fontes: drugs.com (114 interações listadas) + MedScape (24 interações)
-- Focamos nos fármacos que existem na BD (9 pares)
-- Nenhum par é "major" — apenas moderate
-- Ordem canónica: artesunato (1d1fa0f6) < todos os outros
-- =====================================================================

INSERT INTO public.drug_interactions
  (drug_a_id, drug_b_id, severity, summary_pt, summary_en,
   mechanism_pt, mechanism_en, management_pt, management_en,
   monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
   source_pt, source_en, source_url, status)
SELECT a.id, b.id, v.severity, v.summary_pt, v.summary_en,
  v.mechanism_pt, v.mechanism_en, v.management_pt, v.management_en,
  v.monitoring_pt, v.monitoring_en, v.red_flags_pt, v.red_flags_en,
  v.source_pt, v.source_en, v.source_url, 'published'
FROM (VALUES
  -- ═══════ 1. Artesunato × Rifampicina (MODERATE) ═══════
  -- MedScape: rifampin will decrease artesunate by inducing UGT
  ('artesunato', 'rifampicina', 'moderate',
   'Antimalárico + indutor UGT: rifampicina reduz níveis do metabólito activo (DHA).',
   'Antimalarial + UGT inducer: rifampicin reduces active metabolite (DHA) levels.',
   'A rifampicina induz UGT1A9, a enzima que metaboliza o artesunato a diidroartemisinina (DHA). A coadministração diminui a AUC e a concentração máxima de DHA, reduzindo a eficácia antimalárica.',
   'Rifampicin induces UGT1A9, the enzyme that metabolises artesunate to dihydroartemisinin (DHA). Co-administration decreases AUC and peak plasma concentration of DHA, reducing antimalarial efficacy.',
   'Evitar se possível. Se necessário, considerar dose dupla de artesunato ou monitorizar carga parasitária.',
   'Avoid if possible. If necessary, consider doubling artesunate dose or monitor parasitaemia.',
   'Carga parasitária, hemograma, função hepática.',
   'Parasite count, blood count, liver function.',
   'Falha terapêutica antimalárica.',
   'Antimalarial treatment failure.',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 2. Artesunato × Ritonavir (MODERATE) ═══════
  -- MedScape: ritonavir will decrease artesunate by increasing metabolism
  ('artesunato', 'ritonavir', 'moderate',
   'Antimalárico + inibidor/enzima mista: ritonavir reduz níveis de DHA.',
   'Antimalarial + mixed enzyme inhibitor: ritonavir reduces DHA levels.',
   'O ritonavir diminui a AUC e a concentração máxima do metabólito activo DHA, possivelmente via indução de UGT ouother metabolic pathways. Risco de falha terapêutica antimalárica.',
   'Ritonavir decreases AUC and peak plasma concentration of the active metabolite DHA, possibly via UGT induction or other metabolic pathways. Risk of antimalarial treatment failure.',
   'Monitorizar carga parasitária frequentemente. Considerar dose adicional de artesunato.',
   'Monitor parasitaemia frequently. Consider additional artesunate dose.',
   'Carga parasitária.',
   'Parasite count.',
   'Falha terapêutica antimalárica.',
   'Antimalarial treatment failure.',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 3. Artesunato × Fenitoína (MODERATE) ═══════
  -- MedScape: phenytoin will decrease artesunate by inducing UGT
  ('artesunato', 'fenitoina', 'moderate',
   'Antimalárico + indutor UGT: fenitoína reduz níveis de DHA.',
   'Antimalarial + UGT inducer: phenytoin reduces DHA levels.',
   'A fenitoína induz UGT, diminuindo a AUC de DHA. Efeito semelhante à rifampicina mas menos pronunciado.',
   'Phenytoin induces UGT, decreasing DHA AUC. Effect similar to rifampicin but less pronounced.',
   'Monitorizar carga parasitária. Considerar ajuste de dose.',
   'Monitor parasitaemia. Consider dose adjustment.',
   'Carga parasitária, níveis de fenitoína.',
   'Parasite count, phenytoin levels.',
   'Falha terapêutica antimalárica.',
   'Antimalarial treatment failure.',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 4. Artesunato × Carbamazepina (MODERATE) ═══════
  -- MedScape: carbamazepine will decrease artesunate by inducing UGT
  ('artesunato', 'carbamazepina', 'moderate',
   'Antimalárico + indutor UGT: carbamazepina reduz níveis de DHA.',
   'Antimalarial + UGT inducer: carbamazepine reduces DHA levels.',
   'A carbamazepina induz UGT, diminuindo a AUC de DHA. Risco de falha terapêutica antimalárica em doentes epilépticos.',
   'Carbamazepine induces UGT, decreasing DHA AUC. Risk of antimalarial treatment failure in epileptic patients.',
   'Monitorizar carga parasitária. Considerar dose adicional de artesunato.',
   'Monitor parasitaemia. Consider additional artesunate dose.',
   'Carga parasitária, níveis de carbamazepina.',
   'Parasite count, carbamazepine levels.',
   'Falha terapêutica antimalárica.',
   'Antimalarial treatment failure.',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 5. Artesunato × Fenobarbital (MODERATE) ═══════
  -- MedScape: phenobarbital will decrease artesunate by inducing UGT
  ('artesunato', 'fenobarbital', 'moderate',
   'Antimalárico + indutor UGT: fenobarbital reduz níveis de DHA.',
   'Antimalarial + UGT inducer: phenobarbital reduces DHA levels.',
   'O fenobarbital induz UGT, diminuindo a AUC de DHA. Efeito semelhante a outros indutores enzimáticos.',
   'Phenobarbital induces UGT, decreasing DHA AUC. Effect similar to other enzyme inducers.',
   'Monitorizar carga parasitária. Considerar dose adicional.',
   'Monitor parasitaemia. Consider additional dose.',
   'Carga parasitária, níveis de fenobarbital.',
   'Parasite count, phenobarbital levels.',
   'Falha terapêutica antimalárica.',
   'Antimalarial treatment failure.',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 6. Artesunato × Nevirapina (MODERATE) ═══════
  -- MedScape: nevirapine will decrease artesunate by increasing metabolism
  ('artesunato', 'nevirapina', 'moderate',
   'Antimalárico + indutor enzimático: nevirapina reduz níveis de DHA.',
   'Antimalarial + enzyme inducer: nevirapine reduces DHA levels.',
   'A nevirapina diminui a AUC de DHA, possivelmente via indução de UGT e CYP enzimas. Relevante em doentes VIH+ em Angola.',
   'Nevirapine decreases DHA AUC, possibly via UGT and CYP enzyme induction. Relevant for HIV+ patients in Angola.',
   'Monitorizar carga parasitária e carga viral VIH.',
   'Monitor parasitaemia and HIV viral load.',
   'Carga parasitária, hemograma.',
   'Parasite count, blood count.',
   'Falha terapêutica antimalárica.',
   'Antimalarial treatment failure.',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 7. Artesunato × Diclofenaco (MODERATE) ═══════
  -- MedScape: diclofenac will increase artesunate by inhibiting UGT
  ('artesunato', 'diclofenaco', 'moderate',
   'Antimalárico + inibidor UGT: diclofenaco pode aumentar níveis de DHA.',
   'Antimalarial + UGT inhibitor: diclofenac may increase DHA levels.',
   'O diclofenaco inibe UGT, aumentando a AUC de DHA. Efeito oposto aos indutores — pode aumentar eficácia mas também toxicidade.',
   'Diclofenac inhibits UGT, increasing DHA AUC. Opposite effect to inducers — may increase efficacy but also toxicity.',
   'Monitorizar sinais de toxicidade antimalárica.',
   'Monitor for signs of antimalarial toxicity.',
   'Hemograma, função hepática.',
   'Blood count, liver function.',
   '', '',
   'drugs.com; MedScape',
   'drugs.com; MedScape',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 8. Artesunato × Valproato (MODERATE) ═══════
  -- drugs.com: valproic acid listed as moderate interaction
  ('artesunato', 'valproato', 'moderate',
   'Antimalárico + antiepiléptico: valproato pode interagir com metabolismo do artesunato.',
   'Antimalarial + antiepileptic: valproate may interact with artesunate metabolism.',
   'O valproato pode inibir parcialmente UGT, aumentando ligeiramente os níveis de DHA. Efeito clinicamente modesto mas a monitorizar.',
   'Valproate may partially inhibit UGT, slightly increasing DHA levels. Clinically modest effect but worth monitoring.',
   'Monitorizar níveis de valproato e sinais de toxicidade.',
   'Monitor valproate levels and signs of toxicity.',
   'Níveis de valproato, hemograma.',
   'Valproate levels, blood count.',
   '', '',
   'drugs.com',
   'drugs.com',
   'https://www.drugs.com/drug-interactions/artesunate.html'),

  -- ═══════ 9. Artesunato × Metotrexato (MODERATE) ═══════
  -- drugs.com: listed as moderate interaction
  ('artesunato', 'metotrexato', 'moderate',
   'Antimalárico + antimetabolito: ambos afetam hemograma. Risco aditivo de mielossupressão.',
   'Antimalarial + antimetabolite: both affect blood count. Additive risk of myelosuppression.',
   'Ambos podem causar mielossupressão. A combinação aumenta o risco de pancitopopenia, especialmente em doses altas de metotrexato.',
   'Both can cause myelosuppression. The combination increases the risk of pancytopenia, especially with high-dose methotrexate.',
   'Monitorizar hemograma semanalmente durante tratamento concomitante.',
   'Monitor blood count weekly during concomitant treatment.',
   'Hemograma, sinais de infeção.',
   'Blood count, signs of infection.',
   'Pancitopopenia.',
   'Pancytopenia.',
   'drugs.com',
   'drugs.com',
   'https://www.drugs.com/drug-interactions/artesunate.html')
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
