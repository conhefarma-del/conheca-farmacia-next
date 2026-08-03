-- 051: Verificação-citação de TODOS os pares de interações com fontes abertas (NIH/NLM)
--
-- Metodologia (fontes de domínio público, sem violar direitos autorais):
--   Cada par é ancorado aos rótulos aprovados pela FDA dos dois fármacos via
--   DailyMed (NIH/NLM); setIDs verificados através da API pública v2
--   (services/v2/spls.json?drug_name=...). Substituem as strings genéricas
--   ("Literatura de referência (Stockley's; Micromedex)") por citações clicáveis.
--
-- Reclassificação clínica (verificação):
--   - Captopril+Amlodipina e Enalapril+Amlodipina: ACEi+bloqueador de canais de
--     cálcio é combinação de 1.ª linha em hipertensão; o rótulo FDA da amlodipina
--     documenta "amlodipine has been safely administered with ... ACE inhibitors".
--     Severidade 'moderate' sobrestimada => rebaixada para 'none'.
--   - Restantes pares: severidade original mantida, verificada contra rótulos.
--
-- Aplicação única, autossuficiente, para todos os 32 pares. Idempotente: pode
-- ser reaplicada sem efeitos secundários (os pares já atualizados são
-- re-escritos com os mesmos valores).
--
-- Nota (correção): os WHERE usam LEAST/GREATEST de AMBOS os ids dos fármacos,
-- i.e.  LEAST(drug_a_id,drug_b_id) = LEAST((SELECT id ... A),(SELECT id ... B)),
-- de forma a serem independentes da ordem dos ids (UUID) gerados no seed. A
-- primeira versão fixava um fármaco em LEAST e outro em GREATEST, o que só
-- atualizava os pares cujo id menor coincidia com a ordem assumida.
--

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Enalapril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; rótulo aprovado Espironolactona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73564b3d-8ede-4008-b75c-1277153b5bb6',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Enalapril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; approved Spironolactone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73564b3d-8ede-4008-b75c-1277153b5bb6',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Warfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Warfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; rótulo aprovado Ácido acetilsalicílico: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; approved Aspirin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'warfarina'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sildenafil: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; rótulo aprovado Nitroglicerina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3c11c1c2-8e62-4f63-8293-2f8b8d845f7e',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Sildenafil label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=00ee09dd-2de0-4dc4-85f6-b51ed6eabd5b ; approved Nitroglycerin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3c11c1c2-8e62-4f63-8293-2f8b8d845f7e',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'), (SELECT id FROM public.drugs WHERE slug = 'nitroglicerina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sildenafil'), (SELECT id FROM public.drugs WHERE slug = 'nitroglicerina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Alopurinol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b6c5b5c0-b1cb-44c0-a849-5d317e6fa300 ; rótulo aprovado Azatioprina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5116b22b-1460-5535-e063-6394a90acbe5',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Allopurinol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b6c5b5c0-b1cb-44c0-a849-5d317e6fa300 ; approved Azathioprine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5116b22b-1460-5535-e063-6394a90acbe5',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'alopurinol'), (SELECT id FROM public.drugs WHERE slug = 'azatioprina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'alopurinol'), (SELECT id FROM public.drugs WHERE slug = 'azatioprina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Claritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; rótulo aprovado Carbamazepina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9f3d91cd-a959-4e07-a51b-8a4e9ba9ece2',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Clarithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; approved Carbamazepine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=9f3d91cd-a959-4e07-a51b-8a4e9ba9ece2',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'carbamazepina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Enalapril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; rótulo aprovado Hidroclorotiazida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0789baef-3424-43ab-a3fb-4908172da565',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Enalapril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; approved Hydrochlorothiazide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0789baef-3424-43ab-a3fb-4908172da565',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Losartano: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=df4f55f0-fb11-4f6f-a7ed-127b50f955fc ; rótulo aprovado Espironolactona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73564b3d-8ede-4008-b75c-1277153b5bb6',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Losartan label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=df4f55f0-fb11-4f6f-a7ed-127b50f955fc ; approved Spironolactone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73564b3d-8ede-4008-b75c-1277153b5bb6',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'losartano'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'losartano'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Enalapril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Enalapril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amiodarona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=51a88e8e-da02-4b97-9e7e-442fbffd908d ; rótulo aprovado Digoxina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Amiodarone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=51a88e8e-da02-4b97-9e7e-442fbffd908d ; approved Digoxin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'digoxina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Amiodarona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=51a88e8e-da02-4b97-9e7e-442fbffd908d ; rótulo aprovado Warfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Amiodarone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=51a88e8e-da02-4b97-9e7e-442fbffd908d ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'amiodarona'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clopidogrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c9928956-bb7b-4ec2-bc38-d3c9c4199cae ; rótulo aprovado Omeprazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37291cab-e350-d8e3-e063-6294a90a9cb1',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Clopidogrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c9928956-bb7b-4ec2-bc38-d3c9c4199cae ; approved Omeprazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37291cab-e350-d8e3-e063-6294a90a9cb1',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Claritromicina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; rótulo aprovado Atorvastatina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=86841382-4229-4e03-958e-3ac22639efd4',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Clarithromycin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=d836ae7e-fdbf-4dcb-a90d-ede1dcbc3e67 ; approved Atorvastatin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=86841382-4229-4e03-958e-3ac22639efd4',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'atorvastatina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'claritromicina'), (SELECT id FROM public.drugs WHERE slug = 'atorvastatina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Antiácidos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c72f0736-ee20-45b4-baf0-b80f1e3fa9cb ; rótulo aprovado Ciprofloxacina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Antacids label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c72f0736-ee20-45b4-baf0-b80f1e3fa9cb ; approved Ciprofloxacin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14c3bc33-201d-492e-9aee-a4d84c813a3d',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'ciprofloxacina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Antiácidos: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c72f0736-ee20-45b4-baf0-b80f1e3fa9cb ; rótulo aprovado Doxiciclina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cf95b2ca-2cf8-49a8-8e3a-f9b0f5b2072c',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Antacids label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c72f0736-ee20-45b4-baf0-b80f1e3fa9cb ; approved Doxycycline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=cf95b2ca-2cf8-49a8-8e3a-f9b0f5b2072c',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'antiacidos'), (SELECT id FROM public.drugs WHERE slug = 'doxiciclina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Levotiroxina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55f4c679-86cb-b97f-e063-6294a90ad5ef ; rótulo aprovado Omeprazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37291cab-e350-d8e3-e063-6294a90a9cb1',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Levothyroxine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=55f4c679-86cb-b97f-e063-6294a90ad5ef ; approved Omeprazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=37291cab-e350-d8e3-e063-6294a90a9cb1',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'levotiroxina'), (SELECT id FROM public.drugs WHERE slug = 'omeprazol'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Digoxina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4 ; rótulo aprovado Furosemida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cdcd001-ab4b-4210-a455-2e17a7bc4972',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Digoxin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=5886e233-b2da-4acb-be05-9bf40fb8e7f4 ; approved Furosemide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=7cdcd001-ab4b-4210-a455-2e17a7bc4972',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'digoxina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'digoxina'), (SELECT id FROM public.drugs WHERE slug = 'furosemida'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Fluoxetina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490 ; rótulo aprovado Tramadol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=552955e6-2bb3-8755-e063-6394a90ab21c',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Fluoxetine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490 ; approved Tramadol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=552955e6-2bb3-8755-e063-6394a90ab21c',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'fluoxetina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e ; rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=52e6e21d-94b8-41a0-8d13-371c0e66bcee',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e ; approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=52e6e21d-94b8-41a0-8d13-371c0e66bcee',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ácido acetilsalicílico: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366 ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Aspirin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366 ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'aspirina'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Glibenclamida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; rótulo aprovado Metformina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13b1e35f-d047-8ddc-e063-6394a90a24dd',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Glibenclamide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=524eec41-37ee-419a-b7a1-d23e888ae6ab ; approved Metformin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13b1e35f-d047-8ddc-e063-6394a90a24dd',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'glibenclamida'), (SELECT id FROM public.drugs WHERE slug = 'metformina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'glibenclamida'), (SELECT id FROM public.drugs WHERE slug = 'metformina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Espironolactona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73564b3d-8ede-4008-b75c-1277153b5bb6 ; rótulo aprovado Hidroclorotiazida: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0789baef-3424-43ab-a3fb-4908172da565',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Spironolactone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=73564b3d-8ede-4008-b75c-1277153b5bb6 ; approved Hydrochlorothiazide label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=0789baef-3424-43ab-a3fb-4908172da565',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'espironolactona'), (SELECT id FROM public.drugs WHERE slug = 'hidroclorotiazida'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Paracetamol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c737cd6-fe56-4cef-887c-cd6cf83b254c ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Paracetamol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c737cd6-fe56-4cef-887c-cd6cf83b254c ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'));

-- Captopril + Amlodipina: severidade rebaixada após verificação
-- Combinação de 1.ª linha (ACEi + bloqueador de canais de cálcio); sem interação
-- adversa documentada; o rótulo FDA da amlodipina documenta uso seguro com IECA.
UPDATE public.drug_interactions
SET
  severity = 'none',
  summary_pt = 'Sem interação adversa clinicamente relevante. ACEi + bloqueador dos canais de cálcio é combinação de 1.ª linha em hipertensão; o efeito hipotensor aditivo é esperado e requer apenas monitorização da pressão arterial durante a titulação. Não é contraindicada.',
  summary_en = 'No clinically relevant adverse interaction. An ACE inhibitor plus a calcium-channel blocker is a first-line antihypertensive combination; additive hypotension is expected and only requires BP monitoring during titration. Not contraindicated.',
  mechanism_pt = '', mechanism_en = '',
  monitoring_pt = '', monitoring_en = '',
  red_flags_pt = '', red_flags_en = '',
  management_pt = 'Combinação habitual e recomendada. Iniciar com doses baixas e subir gradualmente; monitorizar a pressão arterial nas primeiras semanas.',
  management_en = 'Usual and recommended combination. Start at low doses and titrate gradually; monitor blood pressure in the early weeks.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Captopril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a43a5373-ded9-4912-8c98-edaec8352836 ; rótulo aprovado Amlodipina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58a67272-c4c7-4e2c-85a5-9d39034d12c3',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Captopril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=a43a5373-ded9-4912-8c98-edaec8352836 ; approved Amlodipine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58a67272-c4c7-4e2c-85a5-9d39034d12c3',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'captopril'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'captopril'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'));

-- Enalapril + Amlodipina: severidade rebaixada após verificação
-- Combinação de 1.ª linha (ACEi + bloqueador de canais de cálcio); sem interação
-- adversa documentada; o rótulo FDA da amlodipina documenta uso seguro com IECA.
UPDATE public.drug_interactions
SET
  severity = 'none',
  summary_pt = 'Sem interação adversa clinicamente relevante. ACEi + bloqueador dos canais de cálcio é combinação de 1.ª linha em hipertensão; o efeito hipotensor aditivo é esperado e requer apenas monitorização da pressão arterial durante a titulação. Não é contraindicada.',
  summary_en = 'No clinically relevant adverse interaction. An ACE inhibitor plus a calcium-channel blocker is a first-line antihypertensive combination; additive hypotension is expected and only requires BP monitoring during titration. Not contraindicated.',
  mechanism_pt = '', mechanism_en = '',
  monitoring_pt = '', monitoring_en = '',
  red_flags_pt = '', red_flags_en = '',
  management_pt = 'Combinação habitual e recomendada. Iniciar com doses baixas e subir gradualmente; monitorizar a pressão arterial nas primeiras semanas.',
  management_en = 'Usual and recommended combination. Start at low doses and titrate gradually; monitor blood pressure in the early weeks.',
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Enalapril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; rótulo aprovado Amlodipina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58a67272-c4c7-4e2c-85a5-9d39034d12c3',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Enalapril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=b31372f7-cda3-4ead-a481-4cde62e843fd ; approved Amlodipine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=58a67272-c4c7-4e2c-85a5-9d39034d12c3',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Metformina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13b1e35f-d047-8ddc-e063-6394a90a24dd ; rótulo aprovado Cotrimoxazol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=08500fcb-dbec-4ac2-91c3-189d27907ec0',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Metformin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=13b1e35f-d047-8ddc-e063-6394a90a24dd ; approved Co-trimoxazole label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=08500fcb-dbec-4ac2-91c3-189d27907ec0',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'metformina'), (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'metformina'), (SELECT id FROM public.drugs WHERE slug = 'cotrimoxazol'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sertralina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 ; rótulo aprovado Fluoxetina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Sertraline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 ; approved Fluoxetine label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=09fb3100-1e06-4cdc-8016-7e4f5d097490',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sertralina'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sertralina'), (SELECT id FROM public.drugs WHERE slug = 'fluoxetina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Sertralina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 ; rótulo aprovado Tramadol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=552955e6-2bb3-8755-e063-6394a90ab21c',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Sertraline label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=91e24d17-ff0a-449c-9472-b9df74c98456 ; approved Tramadol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=552955e6-2bb3-8755-e063-6394a90ab21c',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'sertralina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'sertralina'), (SELECT id FROM public.drugs WHERE slug = 'tramadol'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Clopidogrel: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c9928956-bb7b-4ec2-bc38-d3c9c4199cae ; rótulo aprovado Ácido acetilsalicílico: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Clopidogrel label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=c9928956-bb7b-4ec2-bc38-d3c9c4199cae ; approved Aspirin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=3ba0a9f2-062a-401e-82eb-54383a822366',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'clopidogrel'), (SELECT id FROM public.drugs WHERE slug = 'aspirina'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e ; rótulo aprovado Diclofenac: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ddd2278b-70be-41ca-8a84-e3fe0f1a1561',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e ; approved Diclofenac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ddd2278b-70be-41ca-8a84-e3fe0f1a1561',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'diclofenac'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'ibuprofeno'), (SELECT id FROM public.drugs WHERE slug = 'diclofenac'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Diclofenac: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ddd2278b-70be-41ca-8a84-e3fe0f1a1561 ; rótulo aprovado Prednisolona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=52e6e21d-94b8-41a0-8d13-371c0e66bcee',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Diclofenac label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=ddd2278b-70be-41ca-8a84-e3fe0f1a1561 ; approved Prednisolone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=52e6e21d-94b8-41a0-8d13-371c0e66bcee',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));

UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Paracetamol: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c737cd6-fe56-4cef-887c-cd6cf83b254c ; rótulo aprovado Warfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Paracetamol label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=4c737cd6-fe56-4cef-887c-cd6cf83b254c ; approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'paracetamol'), (SELECT id FROM public.drugs WHERE slug = 'warfarina'));
