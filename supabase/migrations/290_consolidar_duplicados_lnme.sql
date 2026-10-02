-- =====================================================================
-- 290 — Consolidação dos 6 pares de fármacos duplicados (padrão da 283)
-- ---------------------------------------------------------------------
-- CONTEXTO: a auditoria de cobertura FF dos LNME (289, secção 20 do
-- docs/INTERACOES_FLUXO_PESQUISA.md) deu 16 fármacos "sem pares". Desta
-- verificação resultou um achado de DADOS, não clínico: parte desses zeros
-- não são lacunas clínicas — são DUPLICADOS DE SLUG que o merge 283 deixou
-- activos, com os pares a viver no slug irmão. Os dois casos que tocam os
-- LNME:
--     vitamina-d (0 pares) ≡ colecalciferol (5 pares)  — mesma substância
--     amoxicilina-acido-clavulanico (0) ≡ amoxicilina-clavulanato (1)
-- A auditoria completa por ATC + nome normalizado (2026-10-02,
-- _temp/_detetar_todos_duplicados.mjs) encontrou 6 pares:
--
--   #  sobrevivente                     arquivado                    motivo
--   1  vitamina-d                       colecalciferol               A11CC05; 264 declara
--                                                                   "vitamina-d = colecalciferol"
--   2  amoxicilina-acido-clavulanico    amoxicilina-clavulanato      J01CR02 + nome PT idêntico
--   3  acido-ascorbico                  acido_ascorbico              A11GA01 + nome idêntico
--   4  acido-folico                     acido_folico                 B03BB01 + nome idêntico
--   5  acido-tranexamico                acido_tranexamico            B02AA02 + nome idêntico
--   6  sulfato-ferroso                  ferro                        B03AA07, mesma substância
--                                                                   ("Ferro (sulfato ferroso)");
--                                                                   a 274 lista ferro/sulfato-ferroso
--   7  losartana                        losartano (JÁ ARQUIVADO)      C09CA01, mesmo nome PT quase
--                                                                   idêntico; a 274 lista o par. O
--                                                                   FÁRMACO já foi arquivado por
--                                                                   outro merge, mas ficaram DUAS
--                                                                   linhas pendentes dele: o par
--                                                                   espironolactona × losartano
--                                                                   (moderate, activo) e a ficha de
--                                                                   gravidez (activa). Fechado aqui.
--
-- CRITÉRIO DO SOBREVIVENTE: quando o LNME está envolvido, sobrevive o slug
-- LNME (é o que as fichas e as dimensões 275–289 usam: verificado —
-- vitamina-d aparece em 278/280/286; amoxicilina-acido-clavulanico em
-- 278/280/286; acido-ascorbico/acido-folico/acido-tranexamico nas LNME e na
-- 289). Nos restantes, sobrevive o slug canónico com hífen (padrão da 283).
--
-- MERGE DE CONTEÚDO (diferença face à 283): a 283 arquivou perfis e
-- farmacologia dos duplicados por "conteúdo não único". Aqui NÃO é o caso —
-- medição de 2026-10-02 (_temp/_gaps_conteudo290.mjs):
--   * drug_pharmacology do duplicado é 2–4× maior em TODOS os 6 pares
--     (ex.: acido-folico mechanism 149 vs 398 chars; metabolism 70 vs 477);
--   * drug_profiles do duplicado é maior em 5 de 6 pares;
--   * 12 campos que o sobrevivente tem VAZIOS têm texto no duplicado
--     (contraception_pt/en em 6 fichas de gravidez + campos de perfil).
-- Por isso a 290 COPIA para o sobrevivente os campos que este tem vazios
-- (nunca sobrepõe texto existente — os sobreviventes foram revistos mais
-- recentemente, Set/Out vs Ago) e só depois arquiva as linhas do duplicado.
-- O conteúdo continua recuperável nas linhas arquivadas (soft-delete).
--
-- COLISÕES (ERRO 7 — resolvidas ANTES do remapeamento; simuladas com
-- _temp/_dryrun290.mjs e _temp/_ordem_canonica_290.mjs):
--   * drug_interactions (2): acido-ascorbico × sulfato-ferroso
--       (ferro × acido_ascorbico moderate vs acido-ascorbico ×
--        sulfato-ferroso minor → vence moderate; ATENÇÃO: este par tem
--        AMBOS os lados duplicados, é uma colisão de segunda ordem que o
--        padrão da 283 não detecta — ver nota do passo 3) e levotiroxina ×
--       sulfato-ferroso (moderate vs moderate → empate, vence a do
--       sobrevivente, critério da 283);
--   * drug_food_interactions (2): sulfato-ferroso|cafe_cha,
--       acido-tranexamico|alcool;
--   * drug_disease_interactions (5): sulfato-ferroso|anemia_nao_diagnosticada
--       (precaution vs contraindication — vence a do sobrevivente por
--        empate de severidade), sulfato-ferroso|hemocromatose,
--       acido-tranexamico|trombose_ativa, vitamina-d|hipercalcemia,
--       amoxicilina-acido-clavulanico|historia_ictericia_clavulanato;
--   * drug_pregnancy_info (6): 1:1 por drug_id → arquiva-se a linha do
--       duplicado (depois de copiar os campos vazios);
--   * drug_profiles / drug_pharmacology (6+6): 1:1 → idem;
--   * drug_target_roles: 0 colisões.
--   * losartano (já arquivado): 1 par órfão (espironolactona × losartano,
--     moderate) com equivalente publicado no slug activo
--     (espironolactona × losartana, critical) → o órfão é arquivado; a ficha
--     de gravidez pendente é copiada/arquivada pelo passo 2.3/5.
--
-- FORA DE ÂMBITO (registado para decisão futura, não silenciado):
--   * carbimazol ≡ tiamazol partilham H03BB01 POR DESENHO (a 274 documenta:
--     carbimazol é profármaco do tiamazol) — são substâncias distintas
--     (propiltiouracilo é H03BB02), não um duplicado de slug. NÃO fundidos.
--   * amoxicilina (J01CA04) vs a associação com clavulanato (J01CR02) —
--     fármacos diferentes, não duplicados. NÃO fundidos.
--   * 6 slugs underscore ACTIVOS sem gémeo com hífen (poractant_alfa,
--     acido_ursodesoxicolico, butilbrometo_hioscina, folinato_calcio,
--     epoetina_alfa, emulsao_lipidica, carbonato_calcio): não são
--     duplicados de nada — ficam como estão; se o padrão de slugs canónicos
--     exigir renomeação, é uma migração de renome (não de fusão).
--
-- DIFERENÇA DE PADRÃO FACE À 283 (passo 3): a decisão de qual par
-- sobrevive é tomada sobre a chave PÓS-REMAPEAMENTO, não sobre os ids
-- originais. O padrão da 283 não detecta colisões de segunda ordem (linha
-- em que os DOIS lados são duplicados) e deixaria um par órfão a apontar
-- para fármacos arquivados.
--
-- Idempotente: todos os passos têm guarda (só copia campos vazios, só
-- arquiva linhas activas, só remapeia o que ainda aponta ao duplicado).
-- =====================================================================

BEGIN;

CREATE TEMP TABLE _m290_t AS
SELECT clock_timestamp() AS t1;

-- ---------------------------------------------------------------------
-- 1. IDs: duplicado → sobrevivente
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m290_ids AS
SELECT d.id AS duplicado_id, s.id AS sobrevivente_id, v.slug_dup, v.slug_sob
FROM (VALUES
  ('colecalciferol',                'vitamina-d'),
  ('amoxicilina-clavulanato',       'amoxicilina-acido-clavulanico'),
  ('acido_ascorbico',               'acido-ascorbico'),
  ('acido_folico',                  'acido-folico'),
  ('acido_tranexamico',             'acido-tranexamico'),
  ('ferro',                         'sulfato-ferroso'),
  ('losartano',                     'losartana')
) AS v(slug_dup, slug_sob)
JOIN public.drugs d ON d.slug = v.slug_dup
JOIN public.drugs s ON s.slug = v.slug_sob
WHERE s.is_archived = false
  -- o duplicado pode já estar arquivado (caso losartano): a linha continua a
  -- ser necessária para limpar pares/fichas pendentes dele
  AND (d.is_archived = false OR v.slug_dup = 'losartano');

-- ---------------------------------------------------------------------
-- 2. MERGE de conteúdo 1:1 — copiar para o sobrevivente apenas os campos
--    que este tem VAZIOS (nunca sobrepor texto existente).
--    Regra de scope (ERRO 11): o alias do target só aparece no SET e WHERE.
-- ---------------------------------------------------------------------

-- 2.1 drug_profiles
UPDATE public.drug_profiles sp
SET overview_public_pt = CASE WHEN sp.overview_public_pt = '' THEN dp.overview_public_pt ELSE sp.overview_public_pt END,
    overview_public_en = CASE WHEN sp.overview_public_en = '' THEN dp.overview_public_en ELSE sp.overview_public_en END,
    overview_pro_pt    = CASE WHEN sp.overview_pro_pt    = '' THEN dp.overview_pro_pt    ELSE sp.overview_pro_pt    END,
    overview_pro_en    = CASE WHEN sp.overview_pro_en    = '' THEN dp.overview_pro_en    ELSE sp.overview_pro_en    END,
    indications_pt     = CASE WHEN sp.indications_pt     = '' THEN dp.indications_pt     ELSE sp.indications_pt     END,
    indications_en     = CASE WHEN sp.indications_en     = '' THEN dp.indications_en     ELSE sp.indications_en     END,
    side_effects_pt    = CASE WHEN sp.side_effects_pt    = '' THEN dp.side_effects_pt    ELSE sp.side_effects_pt    END,
    side_effects_en    = CASE WHEN sp.side_effects_en    = '' THEN dp.side_effects_en    ELSE sp.side_effects_en    END,
    precautions_pt     = CASE WHEN sp.precautions_pt     = '' THEN dp.precautions_pt     ELSE sp.precautions_pt     END,
    precautions_en     = CASE WHEN sp.precautions_en     = '' THEN dp.precautions_en     ELSE sp.precautions_en     END,
    source_pt          = CASE WHEN sp.source_pt          = '' THEN dp.source_pt          ELSE sp.source_pt          END,
    source_en          = CASE WHEN sp.source_en          = '' THEN dp.source_en          ELSE sp.source_en          END,
    updated_at = now()
FROM _m290_ids i
JOIN public.drug_profiles dp
  ON dp.drug_id = i.duplicado_id
 AND dp.is_archived = false
WHERE sp.drug_id = i.sobrevivente_id
  AND sp.is_archived = false;

-- 2.2 drug_pharmacology
UPDATE public.drug_pharmacology sh
SET pharmacodynamics_pt = CASE WHEN sh.pharmacodynamics_pt = '' THEN dh.pharmacodynamics_pt ELSE sh.pharmacodynamics_pt END,
    pharmacodynamics_en = CASE WHEN sh.pharmacodynamics_en = '' THEN dh.pharmacodynamics_en ELSE sh.pharmacodynamics_en END,
    mechanism_pt        = CASE WHEN sh.mechanism_pt        = '' THEN dh.mechanism_pt        ELSE sh.mechanism_pt        END,
    mechanism_en        = CASE WHEN sh.mechanism_en        = '' THEN dh.mechanism_en        ELSE sh.mechanism_en        END,
    metabolism_pt       = CASE WHEN sh.metabolism_pt       = '' THEN dh.metabolism_pt       ELSE sh.metabolism_pt       END,
    metabolism_en       = CASE WHEN sh.metabolism_en       = '' THEN dh.metabolism_en       ELSE sh.metabolism_en       END,
    absorption_pt       = CASE WHEN sh.absorption_pt       = '' THEN dh.absorption_pt       ELSE sh.absorption_pt       END,
    absorption_en       = CASE WHEN sh.absorption_en       = '' THEN dh.absorption_en       ELSE sh.absorption_en       END,
    half_life_pt        = CASE WHEN sh.half_life_pt        = '' THEN dh.half_life_pt        ELSE sh.half_life_pt        END,
    half_life_en        = CASE WHEN sh.half_life_en        = '' THEN dh.half_life_en        ELSE sh.half_life_en        END,
    source_pt           = CASE WHEN sh.source_pt           = '' THEN dh.source_pt           ELSE sh.source_pt           END,
    source_en           = CASE WHEN sh.source_en           = '' THEN dh.source_en           ELSE sh.source_en           END,
    updated_at = now()
FROM _m290_ids i
JOIN public.drug_pharmacology dh
  ON dh.drug_id = i.duplicado_id
 AND dh.is_archived = false
WHERE sh.drug_id = i.sobrevivente_id
  AND sh.is_archived = false;

-- 2.3 drug_pregnancy_info (1:1; copia os campos vazios e só depois arquiva
--     a linha do duplicado — o UNIQUE(drug_id) impede o remapeamento)
UPDATE public.drug_pregnancy_info sq
SET risk_pt          = CASE WHEN sq.risk_pt          = '' THEN dq.risk_pt          ELSE sq.risk_pt          END,
    risk_en          = CASE WHEN sq.risk_en          = '' THEN dq.risk_en          ELSE sq.risk_en          END,
    trimester_pt     = CASE WHEN sq.trimester_pt     = '' THEN dq.trimester_pt     ELSE sq.trimester_pt     END,
    trimester_en     = CASE WHEN sq.trimester_en     = '' THEN dq.trimester_en     ELSE sq.trimester_en     END,
    lactation_pt     = CASE WHEN sq.lactation_pt     = '' THEN dq.lactation_pt     ELSE sq.lactation_pt     END,
    lactation_en     = CASE WHEN sq.lactation_en     = '' THEN dq.lactation_en     ELSE sq.lactation_en     END,
    contraception_pt = CASE WHEN sq.contraception_pt = '' THEN dq.contraception_pt ELSE sq.contraception_pt END,
    contraception_en = CASE WHEN sq.contraception_en = '' THEN dq.contraception_en ELSE sq.contraception_en END,
    source_pt        = CASE WHEN sq.source_pt        = '' THEN dq.source_pt        ELSE sq.source_pt        END,
    source_en        = CASE WHEN sq.source_en        = '' THEN dq.source_en        ELSE sq.source_en        END,
    updated_at = now()
FROM _m290_ids i
JOIN public.drug_pregnancy_info dq
  ON dq.drug_id = i.duplicado_id
 AND dq.is_archived = false
WHERE sq.drug_id = i.sobrevivente_id
  AND sq.is_archived = false;

-- ---------------------------------------------------------------------
-- 3. drug_interactions — decisão sobre a chave PÓS-REMAPEAMENTO
--
--    PORQUE NÃO O PADRÃO DA 283: a 283 comparava chaves CRUAS (par_a/par_b
--    com os ids originais), o que só detecta o caso "o mesmo par existe nos
--    dois lados". Aqui há uma colisão de SEGUNDA ORDEM que esse padrão não
--    vê: `ferro × acido_ascorbico` tem AMBOS os lados duplicados, pelo que
--    só colide com `acido-ascorbico × sulfato-ferroso` DEPOIS de remapear.
--    Com a lógica da 283 essa linha ficaria activa a apontar para dois
--    fármacos arquivados (par órfão) — verificado em 2026-10-02 com
--    _temp/_ordem_canonica_290.mjs (7 linhas fora de ordem, 1 órfão).
--    Aqui calcula-se a chave final de CADA linha activa, decide-se o
--    sobrevivente por grupo e só depois se remapeia.
-- ---------------------------------------------------------------------
CREATE TEMP TABLE _m290_rank AS
SELECT v.sev, v.rk FROM (VALUES
  ('critical', 4),
  ('moderate', 3),
  ('minor', 2),
  ('none', 1)
) AS v(sev, rk);

-- 3.1 chave final de cada linha activa (LEAST/GREATEST garante a ordem
--     canónica pedida pelo CHECK, que o PostgreSQL avalia POR LINHA)
CREATE TEMP TABLE _m290_cand AS
SELECT c.linha_id,
       LEAST(c.sub_a, c.sub_b)    AS nova_a,
       GREATEST(c.sub_a, c.sub_b) AS nova_b,
       c.severity,
       (SELECT rk FROM _m290_rank WHERE sev = c.severity) AS rk,
       CASE WHEN c.sub_a <> c.drug_a_id OR c.sub_b <> c.drug_b_id THEN 1 ELSE 0 END AS precisa_remap
FROM (
  SELECT di.id AS linha_id,
         di.drug_a_id, di.drug_b_id, di.severity,
         COALESCE(i1.sobrevivente_id, di.drug_a_id) AS sub_a,
         COALESCE(i2.sobrevivente_id, di.drug_b_id) AS sub_b
  FROM public.drug_interactions di
  LEFT JOIN _m290_ids i1 ON i1.duplicado_id = di.drug_a_id
  LEFT JOIN _m290_ids i2 ON i2.duplicado_id = di.drug_b_id
  WHERE di.is_archived = false
) c;

-- 3.2 arquivar as linhas que perdem o grupo: fica a de maior severidade;
--     em empate fica a que NÃO precisa de remapeamento (a do sobrevivente,
--     critério da 283) e, se ambas precisarem, a de menor id (determinístico).
--     Também arquiva pares que colapsariam em si mesmos (nova_a = nova_b).
UPDATE public.drug_interactions di
SET is_archived = true, updated_at = now()
FROM _m290_cand c
WHERE di.id = c.linha_id
  AND di.is_archived = false
  AND (
    c.nova_a = c.nova_b
    OR EXISTS (
      SELECT 1
      FROM _m290_cand k
      JOIN public.drug_interactions kl
        ON kl.id = k.linha_id
       AND kl.is_archived = false
      WHERE k.linha_id <> c.linha_id
        AND k.nova_a = c.nova_a
        AND k.nova_b = c.nova_b
        AND (
          k.rk > c.rk
          OR (k.rk = c.rk AND k.precisa_remap < c.precisa_remap)
          OR (k.rk = c.rk AND k.precisa_remap = c.precisa_remap AND k.linha_id < c.linha_id)
        )
    )
  );

-- 3.3 remapear as sobreviventes para a chave final (já canónica; todas as
--     colisões foram arquivadas em 3.2, pelo que não há violação do UNIQUE)
UPDATE public.drug_interactions di
SET drug_a_id = c.nova_a,
    drug_b_id = c.nova_b,
    updated_at = now()
FROM _m290_cand c
WHERE di.id = c.linha_id
  AND di.is_archived = false
  AND (di.drug_a_id <> c.nova_a OR di.drug_b_id <> c.nova_b);

-- ---------------------------------------------------------------------
-- 4. drug_food_interactions / drug_disease_interactions
--    (colisão = mesma entidade já no sobrevivente → arquiva a do duplicado;
--     as restantes remapeiam — padrão da 283)
-- ---------------------------------------------------------------------
UPDATE public.drug_food_interactions dfi
SET is_archived = true, updated_at = now()
FROM _m290_ids i
JOIN public.drug_food_interactions keep
  ON keep.drug_id = i.sobrevivente_id
 AND keep.is_archived = false
WHERE dfi.drug_id = i.duplicado_id
  AND dfi.is_archived = false
  AND keep.entity_slug = dfi.entity_slug;

UPDATE public.drug_food_interactions dfi
SET drug_id = i.sobrevivente_id, updated_at = now()
FROM _m290_ids i
WHERE dfi.drug_id = i.duplicado_id
  AND dfi.is_archived = false
  AND NOT EXISTS (
    SELECT 1 FROM public.drug_food_interactions x
    WHERE x.drug_id = i.sobrevivente_id
      AND x.entity_slug = dfi.entity_slug
      AND x.is_archived = false
  );

UPDATE public.drug_disease_interactions ddi
SET is_archived = true, updated_at = now()
FROM _m290_ids i
JOIN public.drug_disease_interactions keep
  ON keep.drug_id = i.sobrevivente_id
 AND keep.is_archived = false
WHERE ddi.drug_id = i.duplicado_id
  AND ddi.is_archived = false
  AND keep.condition_slug = ddi.condition_slug;

UPDATE public.drug_disease_interactions ddi
SET drug_id = i.sobrevivente_id, updated_at = now()
FROM _m290_ids i
WHERE ddi.drug_id = i.duplicado_id
  AND ddi.is_archived = false
  AND NOT EXISTS (
    SELECT 1 FROM public.drug_disease_interactions x
    WHERE x.drug_id = i.sobrevivente_id
      AND x.condition_slug = ddi.condition_slug
      AND x.is_archived = false
  );

-- ---------------------------------------------------------------------
-- 5. Arquivar perfis, farmacologia e gravidez das linhas duplicadas
--    (soft-delete; o conteúdo já foi copiado no passo 2 e continua
--     recuperável nas linhas arquivadas)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles dp
SET is_archived = true, archived_at = (SELECT t1 FROM _m290_t), updated_at = now()
FROM _m290_ids i
WHERE dp.drug_id = i.duplicado_id
  AND dp.is_archived = false;

UPDATE public.drug_pharmacology dh
SET is_archived = true, archived_at = (SELECT t1 FROM _m290_t), updated_at = now()
FROM _m290_ids i
WHERE dh.drug_id = i.duplicado_id
  AND dh.is_archived = false;

UPDATE public.drug_pregnancy_info dq
SET is_archived = true, archived_at = (SELECT t1 FROM _m290_t), updated_at = now()
FROM _m290_ids i
WHERE dq.drug_id = i.duplicado_id
  AND dq.is_archived = false;

-- ---------------------------------------------------------------------
-- 6. Publicar o perfil do sobrevivente quando está em draft mas o
--    duplicado (arquivado) estava publicado — o LNME exige ficha publicada
--    (caso verificado: acido-tranexamico, perfil draft vs duplicado
--     published; conteúdo do sobrevivente é o revisto mais recentemente)
-- ---------------------------------------------------------------------
UPDATE public.drug_profiles sp
SET status = 'published', updated_at = now()
FROM _m290_ids i
JOIN public.drug_profiles dp
  ON dp.drug_id = i.duplicado_id
WHERE sp.drug_id = i.sobrevivente_id
  AND sp.is_archived = false
  AND sp.status = 'draft'
  AND dp.status = 'published';

-- ---------------------------------------------------------------------
-- 7. Arquivar os fármacos duplicados (soft-delete, padrão do projeto)
-- ---------------------------------------------------------------------
UPDATE public.drugs d
SET is_archived = true,
    archived_at = (SELECT t1 FROM _m290_t),
    archived_by = NULL,
    updated_at  = now()
FROM _m290_ids i
WHERE d.id = i.duplicado_id
  AND d.is_archived = false;

COMMIT;

-- =====================================================================
-- Verificação pós-migração (executar à parte, expectativas):--   SELECT slug, is_archived, sort_order FROM drugs
--     WHERE slug IN ('vitamina-d','colecalciferol',
--                    'amoxicilina-acido-clavulanico','amoxicilina-clavulanato',
--                    'acido-ascorbico','acido_ascorbico',
--                    'acido-folico','acido_folico',
--                    'acido-tranexamico','acido_tranexamico',
--                    'sulfato-ferroso','ferro','losartana','losartano')
--     ORDER BY slug;
--   → 7 arquivados (colecalciferol, amoxicilina-clavulanato, acido_ascorbico,
--     acido_folico, acido_tranexamico, ferro, losartano) + 7 activos.
--
--   -- nenhum par activo a apontar para fármacos arquivados (fecha também o
--   -- órfão losartano que a 289 deixou pendente):
--   SELECT d.slug, count(*) FROM drug_interactions i
--     JOIN drugs d ON d.id IN (i.drug_a_id, i.drug_b_id)
--     WHERE d.is_archived AND i.is_archived = false
--     GROUP BY d.slug;   → 0 linhas
--
--   -- ordem canónica intacta:
--   SELECT count(*) FROM drug_interactions WHERE drug_a_id > drug_b_id;  → 0
--
--   -- cobertura FF dos 2 LNME que eram falsos zeros:
--   SELECT d.slug, count(*) FROM drugs d
--     JOIN drug_interactions i ON d.id IN (i.drug_a_id, i.drug_b_id)
--     WHERE d.slug IN ('vitamina-d','amoxicilina-acido-clavulanico')
--       AND i.is_archived = false AND i.status = 'published'
--     GROUP BY d.slug;   → vitamina-d = 5, amoxicilina-acido-clavulanico = 1
--
--   -- par espironolactona × losartana (activo) = critical; o órfão de
--   -- losartano fica arquivado:
--   SELECT i.severity, i.is_archived FROM drug_interactions i
--     WHERE i.drug_a_id = LEAST((SELECT id FROM drugs WHERE slug='espironolactona'),
--                               (SELECT id FROM drugs WHERE slug='losartana'))
--       AND i.drug_b_id = GREATEST((SELECT id FROM drugs WHERE slug='espironolactona'),
--                                  (SELECT id FROM drugs WHERE slug='losartana'));
--
--   -- nenhum campo que o duplicado tinha preenchido ficou vazio:
--   (comparar contraception_pt/en das 6 fichas — deve estar preenchido)
-- =====================================================================
