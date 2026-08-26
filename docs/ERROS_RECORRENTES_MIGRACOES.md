# ERROS RECORRENTES — Consultar ANTES de criar qualquer migração

> **ESTE DOCUMENTO É OBRIGATÓRIO.** Ler ANTES de escrever qualquer INSERT/UPDATE.
> Cada erro listado já ocorreu pelo menos 2 vezes nesta sessão.

---

## ERRO 1: FALTA `'published'` NO INSERT

**O que acontece:** O INSERT tem X colunas mas o SELECT tem X-1 valores (falta `'published'`).

**Causa:** Esquecer de incluir o valor do status na última posição do SELECT.

**Exemplo ERRADO:**
```sql
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)        -- 8 colunas
SELECT d.id,
  'Resumo público', 'Public overview',
  'Resumo profissional', 'Professional overview',
  'Fonte PT', 'Fonte EN'               -- 7 valores (FALTA 'published')!
FROM ...
```

**Exemplo CORRECTO:**
```sql
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en,
   overview_pro_pt, overview_pro_en,
   source_pt, source_en, status)        -- 8 colunas
SELECT d.id,
  'Resumo público', 'Public overview',
  'Resumo profissional', 'Professional overview',
  'Fonte PT', 'Fonte EN',
  'published'                            -- 8 valores ✓
FROM ...
```

**REGRAS:**
- Se a coluna `status` está na lista de colunas → incluir `'published'` no SELECT
- Se a coluna `status` NÃO está na lista → não incluir (usa DEFAULT)
- **Verificar SEMPRE:** contar colunas = contar valores no SELECT

---

## ERRO 2: ORDEM CANÓNICA (drug_a_id < drug_b_id)

**O que acontece:** O constraint `drug_interactions_canonical_order` rejeita o INSERT porque `drug_a_id > drug_b_id`.

**Causa:** Não verificar os UUIDs antes de criar os pares.

**Solução PERMANENTE:** Atribuir UUID fixo a fármacos novos (ex: `a0000000-0000-4000-8000-000000000001`) e calcular a ordem antes.

**Antes de criar pares, SEMPRE:**
```javascript
// Verificar ordem de TODOS os pares
const nimesulida = 'a0000000-0000-4000-8000-000000000001';
const drugs = { 'warfarina': '4369efeb-...', 'litio': '49033762-...' };
Object.entries(drugs).forEach(([slug, uuid]) => {
  console.log(uuid < nimesulida ? slug + ' < nimesulida' : 'nimesulida < ' + slug);
});
```

**Hex comparação:** `'a' > '4'`, `'f' > 'c'`, etc. Não confundir com decimal!

---

## ERRO 3: NOMES DE COLUNAS INCORRECTOS

**Consultar SEMPRE `docs/SCHEMA_TABELAS_INTERACOES.md` antes de escrever.**

| ❌ ERRADO | ✅ CORRETO | TABELA |
|-----------|-----------|--------|
| `disease_slug` | `condition_slug` | drug_disease_interactions |
| `disease_pt/en` | `condition_pt/en` | drug_disease_interactions |
| `mechanism_pt/en` (disease) | `reason_pt/en` | drug_disease_interactions |
| `pregnancy_info_pt/en` | `risk_pt/en` | drug_pregnancy_info |
| `lactation_info_pt/en` | `lactation_pt/en` | drug_pregnancy_info |
| `fertility_info_pt/en` | `contraception_pt/en` | drug_pregnancy_info |
| `explanation_pt/en` | `mechanism_pt/en` | drug_interactions |
| `recommendation_pt/en` | `management_pt/en` | drug_interactions |
| `'caution'` (interaction_type) | `'precaution'` | drug_disease_interactions |

---

## ERRO 4: TUPLES COM NÚMERO ERRADO DE VALORES

**O que acontece:** `VALUES lists must all be all be the same length`

**Causa:** Esquecer campos (geralmente `red_flags_pt/en` que são novos).

**Colunas por tabela (contar SEMPRE):**

| Tabela | Colunas (excluding id, timestamps) |
|--------|-------------------------------------|
| `drug_interactions` | 16 (drug_a_id, drug_b_id, severity, summary_pt, summary_en, mechanism_pt, mechanism_en, management_pt, management_en, monitoring_pt, monitoring_en, red_flags_pt, red_flags_en, source_pt, source_en, source_url) |
| `drug_food_interactions` | 8 (drug_id, entity_slug, entity_pt, entity_en, mechanism_pt, mechanism_en, advice_pt, advice_en) |
| `drug_disease_interactions` | 11 (drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity, reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en) |
| `drug_pregnancy_info` | 11 (drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en, lactation_pt, lactation_en, contraception_pt, contraception_en, source_pt, source_en) |
| `drug_profiles` | 8 (drug_id, overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en, source_pt, source_en, status) |
| `drug_pharmacology` | 13 (drug_id, pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en, metabolism_pt, metabolism_en, absorption_pt, absorption_en, half_life_pt, half_life_en, source_pt, source_en, status) |

---

## ERRO 5: `ON d.slug = v.slug` EM VEZ DE `WHERE d.slug = v.slug`

**O que acontece:** Syntax error ou referência a coluna inexistente.

**Causa:** Confundir `ON` (para JOINs) com `WHERE` (para filtros).

**Padrão CORRECTO para INSERT único:**
```sql
SELECT d.id, ...
FROM public.drugs d
WHERE d.slug = 'nome_farmaco'    -- WHERE, não ON!
ON CONFLICT ...
```

**Padrão CORRECTO para INSERT múltiplo:**
```sql
SELECT d.id, ...
FROM public.drugs d
JOIN (VALUES ('slug1'), ('slug2')) AS v(slug)
ON d.slug = v.slug               -- ON aqui é correcto (é um JOIN)
ON CONFLICT ...
```

---

## CHECKLIST PRÉ-MIGRAÇÃO

Antes de escrever QUALQUER INSERT:

- [ ] Ler `docs/SCHEMA_TABELAS_INTERACOES.md` para nomes de colunas
- [ ] Contar colunas no INSERT = contar valores no SELECT
- [ ] Se `status` está na lista → incluir `'published'` no SELECT
- [ ] Verificar ordem canónica de TODOS os pares drug_interactions
- [ ] Usar `WHERE` (não `ON`) para INSERTs de fármaco único
- [ ] Usar `JOIN ... ON` para INSERTs múltiplos via VALUES
- [ ] Verificar `interaction_type` = `'precaution'` ou `'contraindication'` (não `'caution'`)
- [ ] Verificar `pregnancy_category` = `'contraindicated'`, `'caution'`, `'compatible'`, `'no_data'`
- [ ] **DEPOIS de escrever**: correr script de validação de ordem canónica contra UUIDs reais na BD (não apenas fixos)
- [ ] **Incluir red_flags_pt e red_flags_en** em TODOS os tuples drug_interactions (mesmo que vazios '')
