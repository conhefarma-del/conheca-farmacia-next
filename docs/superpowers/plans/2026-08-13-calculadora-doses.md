# Calculadora de Doses — Plano de Implementação (2026-08-13, v1)

> Plano baseado nos modelos de design em `_temp/design-demos/` (`calculadora-doses.html`,
> `calculadora-doses-workspace.html`) e na análise de viabilidade feita em 2026-08-13.
> Ferramenta clínica com 3 modos — **dose pediátrica por peso (mg/kg)**, **ajuste renal
> (Cockcroft–Gault)** e **ajuste hepático (Child–Pugh)** — com fonte citada em cada
> resultado. **A ferramenta recusa calcular quando não há dados** (nunca estima) e
> bloqueia acima da dose máxima com aviso.

## Decisões a confirmar (antes da implementação)

| # | Pergunta | Opção recomendada | Alternativa |
|---|----------|-------------------|-------------|
| 1 | Onde vivem os dados de dosagem? | **Tabela própria `drug_dosing` + `drug_dosing_adjustments`**, curada no admin (cada linha com fonte obrigatória) | JSONB dentro de `drug_pharmacology` (mais simples, mas sem validação por linha e difícil de pesquisar) |
| 2 | Âmbito dos dados iniciais | **Seed com 8–12 fármacos pediátricos/renais críticos** do banco (amoxicilina, amoxicilina+clav, ceftriaxona, paracetamol, artesunato, sulfato de magnésio, zinco, vancomicina, gentamicina...) com fontes reais (DailyMed/BNF-C/Normas OMS) | Sem seed (só admin — começa vazio, ferramenta "recusa calcular" para quase tudo) |
| 3 | Fórmula renal | **Cockcroft–Gault** (padrão dos RCM e das tabelas de ajuste) — como no demo | CKD-EPI (mais precisa mas pede etnia e é menos usada nos RCM) |
| 4 | Histórico de cálculos | **localStorage por dispositivo** (`cf-doses:{drugSlug}`) — último N cálculos para consulta rápida, sem contas | Sem histórico (v1 mínima) |
| 5 | Indicações pediátricas | Dose **por indicação** (amigdalite vs pneumonia mudam os mg/kg) — como no demo, o select de indicação vem da tabela | Uma dose única por fármaco (simples, mas clinicamente errado em vários casos) |

## Arquitetura

- **Público:** `/calculadora-doses` (landing: hero + 3 cards de modo + features + disclaimer de segurança) e `/calculadora-doses/calcular` (workspace com tabs Pediatria/Renal/Hepático → inputs → resultado). Rotas top-level, irmãs de `/interacoes`.
- **Admin:** `/admin/calculadora-doses` (lista de fármacos com dados de dosagem), `/admin/calculadora-doses/[id]` (editar entradas) e `/admin/calculadora-doses/new` (picker de fármaco) — form com **fonte obrigatória** por entrada e validação clínica (max ≥ min, intervalos coerentes).
- **Dados:** 2 tabelas novas — `drug_dosing` (entradas de dosagem por modo/indicação) e `drug_dosing_adjustments` (tabelas de ajuste renal/hepático) — padrão RLS do projeto.
- **Conteúdo:** cada entrada é **curada editorialmente com fonte citada** (RCM/DailyMed, BNF-C, Normas OMS/Ministério). O `drug_id` liga ao perfil do Medicamento ("Ver perfil") e o resultado mostra sempre a fonte. Se não houver dados → **bloqueio com aviso "Sem dados de dosagem para este fármaco"**, nunca estimativa.
- **Engine:** funções puras em `lib/dosing/engine.js` (mg/kg × peso, Cockcroft–Gault, lookup da tabela de ajuste, validação de limites) — testáveis sem BD.

---

## Migração 160 — Schema

**Ficheiro:** `supabase/migrations/160_drug_dosing.sql`

```sql
-- Entradas de dosagem (por fármaco × modo × indicação)
CREATE TABLE IF NOT EXISTS public.drug_dosing (
  id            UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  drug_id       UUID NOT NULL REFERENCES public.drugs(id) ON DELETE CASCADE,
  mode          TEXT NOT NULL CHECK (mode IN ('pediatric','renal','hepatic')),
  indication_pt TEXT NOT NULL DEFAULT '',          -- ex.: 'Amigdalite / faringite'
  indication_en TEXT,
  -- Pediatria (modo 'pediatric')
  dose_min_mg_kg REAL,                              -- mg/kg por dose
  dose_max_mg_kg REAL,
  per_dose       BOOLEAN NOT NULL DEFAULT true,     -- true = por dose; false = por dia
  max_dose_mg    REAL,                              -- teto por dose (ex.: 500 mg)
  interval_hours REAL,                              -- 8 (3×/dia), 12 (2×/dia)...
  duration_days  INTEGER,
  age_min_months REAL,
  age_max_months REAL,
  weight_min_kg  REAL,
  weight_max_kg  REAL,
  -- Notas clínicas
  notes_pt       TEXT NOT NULL DEFAULT '',
  notes_en       TEXT,
  -- Fonte obrigatória
  source_label_pt TEXT NOT NULL DEFAULT '',
  source_label_en TEXT,
  source_url     TEXT,
  status         TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft','published')),
  is_archived    BOOLEAN NOT NULL DEFAULT false,
  archived_at    TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT now(),
  updated_at     TIMESTAMPTZ DEFAULT now()
);

-- Tabelas de ajuste (renal/hepático) por fármaco
CREATE TABLE IF NOT EXISTS public.drug_dosing_adjustments (
  id             UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  dosing_id      UUID NOT NULL REFERENCES public.drug_dosing(id) ON DELETE CASCADE,
  key_text       TEXT NOT NULL,                     -- 'CrCl > 30', '10–30', '< 10', 'Child-Pugh A/B/C'
  sort_order     INTEGER NOT NULL DEFAULT 0,
  dose_text_pt   TEXT NOT NULL DEFAULT '',          -- ex.: '500 mg 2×/dia'
  dose_text_en   TEXT,
  note_pt        TEXT NOT NULL DEFAULT '',
  note_en        TEXT,
  source_label_pt TEXT NOT NULL DEFAULT '',
  source_url     TEXT,
  created_at     TIMESTAMPTZ DEFAULT now()
);

-- RLS (padrão do projeto)
ALTER TABLE public.drug_dosing ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.drug_dosing_adjustments ENABLE ROW LEVEL SECURITY;

-- Público: entradas publicadas de fármacos publicados
CREATE POLICY "anon_read_drug_dosing" ON public.drug_dosing
  FOR SELECT TO anon, authenticated USING (status = 'published' AND is_archived = false);
CREATE POLICY "anon_read_drug_dosing_adjustments" ON public.drug_dosing_adjustments
  FOR SELECT TO anon, authenticated USING (EXISTS (
    SELECT 1 FROM public.drug_dosing d
    WHERE d.id = dosing_id AND d.status = 'published' AND d.is_archived = false));

-- Admin: tudo (padrão admin_users)
CREATE POLICY "admin_all_drug_dosing" ON public.drug_dosing
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));
CREATE POLICY "admin_all_drug_dosing_adjustments" ON public.drug_dosing_adjustments
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.admin_users WHERE admin_users.user_id = auth.uid()));

-- Indexes
CREATE INDEX idx_drug_dosing_drug ON public.drug_dosing(drug_id, mode, status);
CREATE INDEX idx_dosing_adj_dosing ON public.drug_dosing_adjustments(dosing_id, sort_order);
```

> **Nota (decisão 2 = sem seed):** sem a migração 161, a ferramenta fica funcional
> mas bloqueia quase todos os fármacos ("Sem dados de dosagem") — o admin preenche
> por fármaco ao longo do tempo. O seed acelera o valor imediato.

## Migração 161 — Seed de dosagem (fármacos críticos)

- **Pediatria (mg/kg):** amoxicilina e amoxicilina+clavulânico (por indicação: amigdalite 50 mg/kg/dia 2×/dia máx. 1 g; OMA/pneumonia 80–90 mg/kg/dia 2–3×/dia máx. 2–3 g), ceftriaxona (50–75 mg/kg/dia 1×/dia máx. 2 g), paracetamol (10–15 mg/kg/dose 4–6 h, máx. 60 mg/kg/dia), artesunato+amodiaquina (esquema por faixa de peso da Norma OMS), sulfato de magnésio (esquema por peso), zinco (10–20 mg/dia 10 dias) — cada entrada com `source_label` + `source_url` (DailyMed/BNF-C/Normas OMS).
- **Renal (Cockcroft–Gault):** amoxicilina, ceftriaxona (ajuste), vancomicina (dose por CrCl), gentamicina, enoxaparina — 3–5 linhas de `key_text` por fármaco (`> 30`, `10–30`, `< 10`, hemodiálise) com `dose_text` e fonte.
- **Hepático (Child–Pugh):** fármacos com metabolismo hepático significativo (ex.: rifampicina, metronidazol, clindamicina) — orientação por classe A/B/C.
- Idempotente: `ON CONFLICT` por chave natural (`drug_id + mode + indication_pt`) para reaplicar sem duplicar. **Só fármacos com slug real no banco** (validar antes).

---

## Tarefas

### T1 — Migração 160 (schema) + 161 (seed)
SQL acima. Aplicar no Supabase. Validar slugs reais dos fármacos antes do seed.

### T2 — Engine puro: `lib/dosing/engine.js` (novo)
Funções puras, sem BD, com testes unitários:
```js
export function calculatePediatricDose({ doseMinMgKg, doseMaxMgKg, perDose, maxDoseMg, weightKg })
// → { doseMg, doseRangeText, blocked, reason }
// blocked=true se sem dados OU dose resultante > maxDoseMg (nunca silencia)
export function calculateCrCl({ ageYears, weightKg, sex, creatinineMgDl })
// Cockcroft–Gault: ((140 − idade) × peso × fatorSexo) / (72 × creatinina); fatorSexo 1.15 se feminino
export function findRenalAdjustment(adjustments, crCl) // devolve a linha ativa da tabela
export function parseRangeKey(keyText) // '> 30' | '10–30' | '< 10' → {min,max}
```
- Regras: mg/kg por dose × peso → arredondamento clínico (5/10 mg); bloqueio com aviso acima da dose máxima; recusa total sem dados
- Testes: sequências típicas (criança 6 anos/22 kg com amoxicilina 20 mg/kg → 440 mg ≤ 500 mg; acima da max → bloqueio)

### T3 — Camada de dados: `lib/api/dosing.js` (novo)
- `DOSING_COLUMNS` (SELECT explícito) + `normalizeDosing(row)` → `{ drugId, drugSlug, drugName, mode, indication, doseMinMgKg, ..., adjustments: [...] }`
- `getDosingForDrug(drugId)` — entradas publicadas + ajustes ordenados
- `getDosingOptions()` — fármacos com dados pediátricos (para o select do workspace, com indicações) + fármacos com dados renais/hepáticos
- `searchDosingDrugs(query)` — para o picker do admin
- Padrão `unstable_cache` + tags `dosing`; queries com colunas explícitas.

### T4 — Ações server: `lib/actions/dosing.js` (novo)
- Admin (padrão `requireAdmin` + sanitização + validação clínica):
  - `createDosingEntry` / `updateDosingEntry` — valida: `dose_max_mg_kg ≥ dose_min_mg_kg`, `max_dose_mg > 0` quando pediátrico, `interval_hours > 0`, `source_label` **obrigatório**; slug do fármaco resolvido do picker
  - `saveAdjustments(dosingId, rows)` — delete + insert idempotente (padrão do sync de autores)
  - `archiveDosingEntry` / `deleteDosingEntry` (hard delete, só superadmin)
- Sem ações públicas de escrita (a calculadora é read-only — segurança: nunca guarda dados do doente, só no localStorage do dispositivo).

### T5 — Admin: `app/[lang]/admin/(protected)/calculadora-doses/`
- `page.js` — tabela: fármaco, modos com dados, indicações, nº de linhas de ajuste, status; ações editar/arquivar/eliminar
- `new/page.js` + `[id]/page.js` — `components/admin/DosingForm.jsx` (novo): picker de fármaco (search), modo, indicação (PT/EN), campos pediátricos (mg/kg min/max, per dose/dia, dose máxima, intervalo, duração, faixas etárias/peso), **editor de ajustes dinâmico** (key_text + dose_text + fonte), **campo de fonte obrigatório** + preview do cálculo real com o engine (valida os números antes de guardar)
- Sidebar: item "Calculadora de Doses" (ícone `Calculator`)

### T6 — Landing `/calculadora-doses`
`app/[lang]/(public)/calculadora-doses/page.js` + `components/pages/CalculadoraLandingPage.jsx`:
- Hero (eyebrow "Ferramenta clínica" + título + subtítulo) — do demo, fundo verde profundo
- **3 cards de modo** (Pediatria `Baby`, Renal `Droplets`, Hepático `FileHeart`) com tags (`mg/kg · max · intervalo`, `Cockcroft–Gault`, `Child–Pugh`) → todos levam ao workspace
- Secção features (fonte citada, limites e alarmes, histórico no dispositivo) + **disclaimer de segurança** (apoio à decisão, não substitui avaliação clínica; recusa calcular sem dados)
- Estado vazio + skeletons (`loading.jsx`) no padrão do projeto

### T7 — Workspace `/calculadora-doses/calcular`
`app/[lang]/(public)/calculadora-doses/calcular/page.js` + `components/pages/CalculadoraWorkspaceClient.jsx`:
- **Tabs Pediatria / Renal / Hepático** (como no demo) — cada modo mostra só os campos relevantes
- Painel de inputs: fármaco (select com `getDosingOptions`), indicação (vem da tabela, só quando o fármaco tem múltiplas), idade, peso, sexo, creatinina sérica
- **Resultado**: dose calculada grande (ex.: "440 mg") + esquema (mg/kg ×/dia · duração) + verificação "dentro do intervalo / bloqueado" — **caixa de aviso âmbar quando bloqueado ou acima da dose máxima**; tabela de ajuste renal com a linha ativa destacada (`.active-row`) + CrCl em destaque; fonte(s) com links; chips "Perfil: X" / "Farmacologia: X" / "Interações"
- Histórico localStorage `cf-doses:{drugSlug}` (últimos 5) + botão limpar; disclaimer no rodapé do resultado
- Só com dados → estado "Sem dados de dosagem para este fármaco" (bloqueio explícito)

### T8 — i18n, CSS, SEO e navegação
- Chaves `calculadora_page.*` e `calculadora_workspace.*` em pt/en
- Classes `.mode-*`/`.calc-*`/`.result-*`/`.adj-table` do demo adaptadas + dark mode
- `loading.jsx` para `/calculadora-doses` e `/calculadora-doses/calcular`
- Sitemap: `/calculadora-doses` + `/calculadora-doses/calcular` (estáticos)
- Menu principal: item "Calculadora de Doses" (junto de Ferramentas/Interações)

---

## Ficheiros

| Ficheiro | Ação |
|---|---|
| `supabase/migrations/160_drug_dosing.sql` | Novo (schema) |
| `supabase/migrations/161_seed_drug_dosing.sql` | Novo (seed de dosagem com fontes) |
| `lib/dosing/engine.js` | Novo (engine puro + testes) |
| `lib/api/dosing.js` | Novo |
| `lib/actions/dosing.js` | Novo |
| `components/admin/DosingForm.jsx` | Novo |
| `components/pages/CalculadoraLandingPage.jsx` | Novo |
| `components/pages/CalculadoraWorkspaceClient.jsx` | Novo |
| `app/[lang]/(public)/calculadora-doses/{page,calcular}` | Novos (+ `loading.jsx`) |
| `app/[lang]/admin/(protected)/calculadora-doses/` | Novos (listagem + forms) |
| `components/layout/AdminSidebar.jsx` | Modificar (item Calculadora de Doses) |
| Menu principal público | Modificar (item Calculadora de Doses) |
| `app/sitemap.js` | Modificar |
| `lib/i18n.js` + `public/i18n/*.json` | Modificar |
| CSS do projeto | Modificar (classes do demo) |

## Fora de âmbito (consciente)

- **Cálculo automático de doses renais para todos os fármacos** — só os com dados curados; a ferramenta recusa sem dados
- **CKD-EPI** (fica Cockcroft–Gault, padrão RCM; migrar depois sem tocar no schema — só no engine)
- **Doses oncológicas** (superfície corporal/m2, ciclos) — v1 pediátrica por peso
- **Cálculo de infusão contínua / velocidade de perfusão** — pode ser follow-up
- **Contas públicas / histórico na cloud** — v1 localStorage (decisão 4)
- **Interações ativas no resultado** (ex.: avisar interação do fármaco calculado) — a ligação existe via chips, não dentro do resultado
- **PDF/impressão do cálculo** — pode ser follow-up
- **Validação clínica formal por revisores** — a fonte citada é o mecanismo de confiança na v1

---

## Ordem de Execução

1. **Confirmar decisões** (1–5) com o utilizador
2. **T1** — Migrações 160 + 161 (aplicar; validar slugs dos fármacos reais no seed)
3. **T2 + T3** — Engine puro com testes + camada de dados
4. **T4 + T5** — Ações + admin (form com validação clínica e fonte obrigatória)
5. **T8 parcial** — i18n + CSS base + skeletons
6. **T6 + T7** — Páginas públicas (landing + workspace)
7. **T8 restante** — sitemap + menu + SEO

## Verificação

- `npm run build` sem erros + testes do `engine.js` passam (pediátrico normal, acima da max → bloqueio, sem dados → recusa, CrCl com/sem ajuste)
- Seed: cada fármaco tem `source_label` preenchido; os valores batem com a fonte (spot-check amoxicilina/ceftriaxona)
- Workspace: calcular 22 kg amoxicilina → 440 mg com esquema e fonte; peso que excede a max → aviso âmbar e bloqueio; fármaco sem dados → recusa explícita
- Tabela renal destaca a linha ativa pelo CrCl; fonte com link abre o RCM/DailyMed
- Admin: criar entrada exige fonte; validação rejeita max < min; preview calcula com o engine real
- Histórico localStorage guarda/limpa; dark mode correto nas classes novas; skeletons e sitemap ok
