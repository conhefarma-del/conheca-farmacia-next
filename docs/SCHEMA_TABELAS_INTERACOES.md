# SCHEMAS DAS TABELAS — Referência para Migrações

> **IMPORTANTE:** Ler este ficheiro E `docs/ERROS_RECORRENTES_MIGRACOES.md` ANTES de criar qualquer migração.
> Os nomes das colunas são EXATOS — não inventar nem assumir nomes genéricos.

---

## REFERÊNCIA RÁPIDA — Colunas por tabela

| Tabela | Colunas INSERT | Incluir 'published'? |
|--------|---------------|---------------------|
| drug_interactions | 16 | No SELECT final |
| drug_food_interactions | 8 | No SELECT final |
| drug_disease_interactions | 11 | No SELECT final |
| drug_pregnancy_info | 11 | No SELECT final |
| drug_profiles | 8 | No SELECT final |
| drug_pharmacology | 13 | No SELECT final |

**REGRA DE OURO:** Se a coluna `status` está na lista → SEMPRE incluir `'published'` como último valor do SELECT.

---

## 1. `drugs` — Fármacos base

```sql
CREATE TABLE public.drugs (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug        TEXT UNIQUE NOT NULL,          -- ex: 'amoxicilina', 'metformina'
  name_pt     TEXT NOT NULL,
  name_en     TEXT NOT NULL,
  class_pt    TEXT NOT NULL DEFAULT '',
  class_en    TEXT NOT NULL DEFAULT '',
  aliases     TEXT[] NOT NULL DEFAULT '{}',
  status      TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published')),
  sort_order  INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Colunas para INSERT:** `slug, name_pt, name_en, class_pt, class_en, aliases, status`

---

## 2. `drug_interactions` — Pares fármaco-fármaco

```sql
CREATE TABLE public.drug_interactions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_a_id   UUID NOT NULL REFERENCES drugs(id),   -- UUID MENOR (canonical_order)
  drug_b_id   UUID NOT NULL REFERENCES drugs(id),   -- UUID MAIOR (canonical_order)
  severity    TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('critical','moderate','minor','none')),
  summary_pt  TEXT NOT NULL DEFAULT '',
  summary_en  TEXT NOT NULL DEFAULT '',
  mechanism_pt  TEXT NOT NULL DEFAULT '',             -- era "explanation_pt"
  mechanism_en  TEXT NOT NULL DEFAULT '',             -- era "explanation_en"
  management_pt TEXT NOT NULL DEFAULT '',             -- era "recommendation_pt"
  management_en TEXT NOT NULL DEFAULT '',             -- era "recommendation_en"
  monitoring_pt TEXT NOT NULL DEFAULT '',
  monitoring_en TEXT NOT NULL DEFAULT '',
  red_flags_pt  TEXT NOT NULL DEFAULT '',
  red_flags_en  TEXT NOT NULL DEFAULT '',
  source_pt     TEXT NOT NULL DEFAULT '',
  source_en     TEXT NOT NULL DEFAULT '',
  source_url    TEXT NOT NULL DEFAULT '',
  status      TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_interactions_pair_unique UNIQUE (drug_a_id, drug_b_id),
  CONSTRAINT drug_interactions_canonical_order CHECK (drug_a_id < drug_b_id)
);
```

**Colunas para INSERT (16 + status):**
`drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en, management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en, source_pt, source_en, source_url, status`

**ATENÇÃO:** `drug_a_id` DEVE ser menor que `drug_b_id` (comparação UUID). Verificar ordem com:
```sql
SELECT id, slug FROM drugs WHERE slug IN ('slug_a', 'slug_b');
-- e garantir que id_a < id_b
```

**Template INSERT:**
```sql
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
  ('slug_a', 'slug_b', 'critical',
   'Resumo PT', 'Summary EN',
   'Mecanismo PT', 'Mechanism EN',
   'Gestão PT', 'Management EN',
   'Monitorização PT', 'Monitoring EN',
   'Bandeiras vermelhas PT', 'Red flags EN',
   'Fonte PT', 'Fonte EN', 'https://url-da-fonte')
) AS v(slug_a, slug_b, severity, summary_pt, summary_en,
       mechanism_pt, mechanism_en, management_pt, management_en,
       monitoring_pt, monitoring_en, red_flags_pt, red_flags_en,
       source_pt, source_en, source_url)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
```

---

## 3. `drug_food_interactions` — Interações alimento/bebida

```sql
CREATE TABLE public.drug_food_interactions (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id     UUID NOT NULL REFERENCES drugs(id),
  entity_slug TEXT NOT NULL,                  -- ex: 'alimentos_ricos_potassio', 'toranja'
  entity_pt   TEXT NOT NULL,
  entity_en   TEXT NOT NULL,
  severity    TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('critical','moderate','minor','none')),
  mechanism_pt TEXT NOT NULL DEFAULT '',
  mechanism_en TEXT NOT NULL DEFAULT '',
  advice_pt   TEXT NOT NULL DEFAULT '',
  advice_en   TEXT NOT NULL DEFAULT '',
  source_pt   TEXT NOT NULL DEFAULT '',
  source_en   TEXT NOT NULL DEFAULT '',
  sort_order  INT NOT NULL DEFAULT 0,
  status      TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_food_interactions_unique UNIQUE (drug_id, entity_slug)
);
```

**Colunas para INSERT (8 + status):**
`drug_id, entity_slug, entity_pt, entity_en, mechanism_pt, mechanism_en, advice_pt, advice_en, status`

**Template INSERT:**
```sql
INSERT INTO public.drug_food_interactions
  (drug_id, entity_slug, entity_pt, entity_en,
   mechanism_pt, mechanism_en, advice_pt, advice_en, status)
SELECT d.id, v.entity_slug, v.entity_pt, v.entity_en,
  v.mechanism_pt, v.mechanism_en, v.advice_pt, v.advice_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('slug_farmaco', 'entity_slug', 'Nome PT', 'Name EN',
   'Mecanismo PT', 'Mechanism EN', 'Conselho PT', 'Advice EN')
) AS v(slug, entity_slug, entity_pt, entity_en,
       mechanism_pt, mechanism_en, advice_pt, advice_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, entity_slug) DO NOTHING;
```

---

## 4. `drug_disease_interactions` — Interações doença/condição

```sql
CREATE TABLE public.drug_disease_interactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id         UUID NOT NULL REFERENCES drugs(id),
  condition_slug  TEXT NOT NULL,               -- NÃO é "disease_slug"!
  condition_pt    TEXT NOT NULL,               -- NÃO é "disease_pt"!
  condition_en    TEXT NOT NULL,               -- NÃO é "disease_en"!
  interaction_type TEXT NOT NULL DEFAULT 'precaution' CHECK (interaction_type IN ('contraindication','precaution')),
  severity        TEXT NOT NULL DEFAULT 'moderate' CHECK (severity IN ('critical','moderate','minor','none')),
  reason_pt       TEXT NOT NULL DEFAULT '',    -- NÃO é "mechanism_pt"!
  reason_en       TEXT NOT NULL DEFAULT '',    -- NÃO é "mechanism_en"!
  advice_pt       TEXT NOT NULL DEFAULT '',
  advice_en       TEXT NOT NULL DEFAULT '',
  source_pt       TEXT NOT NULL DEFAULT '',
  source_en       TEXT NOT NULL DEFAULT '',
  sort_order      INT NOT NULL DEFAULT 0,
  status          TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived     BOOLEAN NOT NULL DEFAULT false,
  archived_at     TIMESTAMPTZ,
  archived_by     UUID,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT drug_disease_interactions_unique UNIQUE (drug_id, condition_slug)
);
```

**Colunas para INSERT (11 + status):**
`drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity, reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en, status`

**interaction_type:** `'contraindication'` ou `'precaution'` (NÃO `'caution'`!)

**Template INSERT:**
```sql
INSERT INTO public.drug_disease_interactions
  (drug_id, condition_slug, condition_pt, condition_en,
   interaction_type, severity, reason_pt, reason_en,
   advice_pt, advice_en, source_pt, source_en, status)
SELECT d.id, v.condition_slug, v.condition_pt, v.condition_en,
  v.interaction_type, v.severity, v.reason_pt, v.reason_en,
  v.advice_pt, v.advice_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('slug_farmaco', 'insuficiencia_renal', 'Insuficiência renal', 'Renal impairment',
   'precaution', 'moderate',
   'Razão PT', 'Reason EN', 'Conselho PT', 'Advice EN',
   'Fonte PT', 'Fonte EN')
) AS v(slug, condition_slug, condition_pt, condition_en,
       interaction_type, severity, reason_pt, reason_en,
       advice_pt, advice_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id, condition_slug) DO NOTHING;
```

---

## 5. `drug_pregnancy_info` — Perfil gravidez/lactação (1:1 por fármaco)

```sql
CREATE TABLE public.drug_pregnancy_info (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id             UUID NOT NULL UNIQUE REFERENCES drugs(id),
  pregnancy_category  TEXT NOT NULL DEFAULT 'caution' CHECK (pregnancy_category IN ('contraindicated','caution','compatible','no_data')),
  risk_pt             TEXT NOT NULL DEFAULT '',    -- NÃO é "pregnancy_info_pt"!
  risk_en             TEXT NOT NULL DEFAULT '',    -- NÃO é "pregnancy_info_en"!
  trimester_pt        TEXT NOT NULL DEFAULT '',
  trimester_en        TEXT NOT NULL DEFAULT '',
  lactation_pt        TEXT NOT NULL DEFAULT '',    -- NÃO é "lactation_info_pt"!
  lactation_en        TEXT NOT NULL DEFAULT '',    -- NÃO é "lactation_info_en"!
  contraception_pt    TEXT NOT NULL DEFAULT '',    -- NÃO é "fertility_info_pt"!
  contraception_en    TEXT NOT NULL DEFAULT '',    -- NÃO é "fertility_info_en"!
  source_pt           TEXT NOT NULL DEFAULT '',
  source_en           TEXT NOT NULL DEFAULT '',
  status              TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived         BOOLEAN NOT NULL DEFAULT false,
  archived_at         TIMESTAMPTZ,
  archived_by         UUID,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Colunas para INSERT (11 + status):**
`drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en, lactation_pt, lactation_en, contraception_pt, contraception_en, source_pt, source_en, status`

**pregnancy_category:** `'contraindicated'`, `'caution'`, `'compatible'`, `'no_data'`

**Template INSERT:**
```sql
INSERT INTO public.drug_pregnancy_info
  (drug_id, pregnancy_category, risk_pt, risk_en,
   trimester_pt, trimester_en, lactation_pt, lactation_en,
   contraception_pt, contraception_en, source_pt, source_en, status)
SELECT d.id, v.pregnancy_category, v.risk_pt, v.risk_en,
  v.trimester_pt, v.trimester_en, v.lactation_pt, v.lactation_en,
  v.contraception_pt, v.contraception_en, v.source_pt, v.source_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('slug_farmaco', 'compatible',
   'Risco PT', 'Risk EN',
   'Trimestre PT', 'Trimester EN',
   'Aleitamento PT', 'Lactation EN',
   'Contracepção PT', 'Contraception EN',
   'Fonte PT', 'Fonte EN')
) AS v(slug, pregnancy_category, risk_pt, risk_en,
       trimester_pt, trimester_en, lactation_pt, lactation_en,
       contraception_pt, contraception_en, source_pt, source_en)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
```

---

## 6. `drug_profiles` — Perfil público/profissional (1:1 por fármaco)

```sql
CREATE TABLE public.drug_profiles (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id           UUID NOT NULL UNIQUE REFERENCES drugs(id),
  overview_public_pt TEXT NOT NULL DEFAULT '',
  overview_public_en TEXT NOT NULL DEFAULT '',
  overview_pro_pt   TEXT NOT NULL DEFAULT '',
  overview_pro_en   TEXT NOT NULL DEFAULT '',
  source_pt         TEXT NOT NULL DEFAULT '',
  source_en         TEXT NOT NULL DEFAULT '',
  status            TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived       BOOLEAN NOT NULL DEFAULT false,
  archived_at       TIMESTAMPTZ,
  archived_by       UUID,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Colunas adicionais (migration 080):
  indications_pt    TEXT NOT NULL DEFAULT '',
  indications_en    TEXT NOT NULL DEFAULT '',
  side_effects_pt   TEXT NOT NULL DEFAULT '',
  side_effects_en   TEXT NOT NULL DEFAULT '',
  precautions_pt    TEXT NOT NULL DEFAULT '',
  precautions_en    TEXT NOT NULL DEFAULT '',
  updated_by        UUID
);
```

**Colunas para INSERT (8 — as colunas adicionais têm DEFAULT ''):**
`drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en, source_pt, source_en, status`

**IMPORTANTE:** Incluir SEMPRE `'published'` na posição do `status`!

**Template INSERT:**
```sql
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en, source_pt, source_en, status)
SELECT d.id,
  'Resumo público PT', 'Public overview EN',
  'Resumo profissional PT', 'Professional overview EN',
  'Fonte PT', 'Fonte EN', 'published'
FROM public.drugs d
JOIN (VALUES ('slug_farmaco')) AS v(slug)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
```

---

## 7. `drug_pharmacology` — Farmacologia detalhada (1:1 por fármaco)

```sql
CREATE TABLE public.drug_pharmacology (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drug_id             UUID NOT NULL UNIQUE REFERENCES drugs(id),
  pharmacodynamics_pt TEXT NOT NULL DEFAULT '',
  pharmacodynamics_en TEXT NOT NULL DEFAULT '',
  mechanism_pt        TEXT NOT NULL DEFAULT '',
  mechanism_en        TEXT NOT NULL DEFAULT '',
  metabolism_pt       TEXT NOT NULL DEFAULT '',
  metabolism_en       TEXT NOT NULL DEFAULT '',
  absorption_pt       TEXT NOT NULL DEFAULT '',
  absorption_en       TEXT NOT NULL DEFAULT '',
  half_life_pt        TEXT NOT NULL DEFAULT '',
  half_life_en        TEXT NOT NULL DEFAULT '',
  source_pt           TEXT NOT NULL DEFAULT '',
  source_en           TEXT NOT NULL DEFAULT '',
  status              TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived         BOOLEAN NOT NULL DEFAULT false,
  archived_at         TIMESTAMPTZ,
  updated_by          UUID,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

**Colunas para INSERT (12 + status):**
`drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en, metabolism_pt, metabolism_en, absorption_pt, absorption_en, half_life_pt, half_life_en, source_pt, source_en, status`

**Template INSERT:**
```sql
INSERT INTO public.drug_pharmacology
  (drug_id, pharmacodynamics_pt, pharmacodynamics_en,
   mechanism_pt, mechanism_en, metabolism_pt, metabolism_en,
   absorption_pt, absorption_en, half_life_pt, half_life_en,
   source_pt, source_en, status)
SELECT d.id,
  'Farmacodinâmica PT', 'Pharmacodynamics EN',
  'Mecanismo PT', 'Mechanism EN',
  'Metabolismo PT', 'Metabolism EN',
  'Absorção PT', 'Absorption EN',
  'Meia-vida PT', 'Half-life EN',
  'Fonte PT', 'Fonte EN', 'published'
FROM public.drugs d
JOIN (VALUES ('slug_farmaco')) AS v(slug)
ON d.slug = v.slug
ON CONFLICT (drug_id) DO NOTHING;
```

---

## ERROS COMUNS A EVITAR

| ❌ ERRADO | ✅ CORRETO | TABELA |
|-----------|-----------|--------|
| `explanation_pt/en` | `mechanism_pt/en` | drug_interactions |
| `recommendation_pt/en` | `management_pt/en` | drug_interactions |
| `disease_slug` | `condition_slug` | drug_disease_interactions |
| `disease_pt/en` | `condition_pt/en` | drug_disease_interactions |
| `mechanism_pt/en` (disease) | `reason_pt/en` | drug_disease_interactions |
| `pregnancy_info_pt/en` | `risk_pt/en` | drug_pregnancy_info |
| `lactation_info_pt/en` | `lactation_pt/en` | drug_pregnancy_info |
| `fertility_info_pt/en` | `contraception_pt/en` | drug_pregnancy_info |
| `'caution'` (interaction_type) | `'precaution'` | drug_disease_interactions |
| `WHERE a.slug = v.slug_a` | `JOIN drugs a ON a.slug = v.slug_a` | Todas |
| `source_url` como coluna | `source_url` existe em drug_interactions | drug_interactions |

---

## CHECK CONSTRAINTS IMPORTANTES

- `drug_interactions.severity`: `'critical'`, `'moderate'`, `'minor'`, `'none'`
- `drug_interactions_canonical_order`: `drug_a_id < drug_b_id` (UUID comparison!)
- `drug_disease_interactions.interaction_type`: `'contraindication'`, `'precaution'`
- `drug_pregnancy_info.pregnancy_category`: `'contraindicated'`, `'caution'`, `'compatible'`, `'no_data'`
- `drug_target_roles.role`: `'substrate'`, `'inhibitor'`, `'inducer'`

---

## PADRÃO DE INSERT COM JOIN (USAR SEMPRE)

```sql
-- ❌ NUNCA fazer:
FROM public.drugs a
JOIN public.drugs b ON TRUE
JOIN (VALUES ...) AS v(...)
WHERE a.slug = v.slug_a AND b.slug = v.slug_b

-- ✅ SEMPRE fazer:
FROM (VALUES ...)
AS v(slug_a, slug_b, ...)
JOIN public.drugs a ON a.slug = v.slug_a
JOIN public.drugs b ON b.slug = v.slug_b
```

---

## VERIFICAÇÃO DE ORDEM CANÓNICA (drug_interactions)

Antes de criar pares drug_interactions, verificar UUIDs:
```sql
SELECT id, slug FROM drugs WHERE slug IN ('slug_a', 'slug_b');
-- Se UUID de slug_a > UUID de slug_b → trocar a ordem!
```
