# Fluxo de Pesquisa e Adição de Interações Medicamentosas

Documento que descreve o método usado para **pesquisar, verificar e adicionar**
interações à calculadora de interações (`/interacoes`).

> **Quatro fluxos independentes.** O trabalho divide-se em **quatro pedidos
> separados**, cada um com o seu fluxo próprio. Podem ser pedidos em qualquer
> ordem e são **aditivos** (nenhum toca no que já existe):

- **Fluxo 1 — Interação medicamento-medicamento** (`drug_interactions`): o
  método histórico, por família terapêutica. Abrange as migrações de seed
  (044/045), a verificação-citação (051) e as migrações por família (052–059),
  com o Prontuário Terapêutico como fonte adicional. → Ver **secção 3 e 4**.
- **Fluxo 2 — As três dimensões novas** (alimento/bebida, doença, gestação):
  adiciona as interações **não-medicamento-medicamento** para fármacos **que
  já existem** em `public.drugs`. Usa **EMC-UK como fonte canónica** (com
  Health Canada e DailyMed de apoio e corroboração). → Ver **secção 12**.
- **Fluxo 3 — Perfis de fármaco + farmacologia** (`drug_profiles` +
  `drug_pharmacology`): a ficha editorial de cada fármaco (overview
  público/profissionais, indicações, efeitos secundários, precauções — PT/EN)
  e a secção **Farmacologia** (farmacodinâmica, mecanismo de ação, metabolismo,
  absorção, meia-vida), que alimentam a página `/medicamento/[slug]`. Usa
  **DailyMed como fonte principal** (secção 12 CLINICAL PHARMACOLOGY para a
  farmacologia) + corroboração do Prontuário e PubMed. → Ver **secção 13**.
- **Fluxo 4 — Explicações longas fármaco-fármaco** (camada editorial de
  profundidade): preenche `summary_pro_*` (resumo profissional) e
  `explanation_*` (explicação longa, 3–5 frases com mecanismo e orientação)
  dos pares moderados/critical sem explicação, por ordem de fármacos com mais
  pares. Usa **DailyMed como fonte principal** + Prontuário. → Ver
  **secção 15**.

> **Fonte canónica do Fluxo 2:** prioriza-se o **EMC-UK (MHRA, medicines.org.uk)**
> como fonte primária de verdade para as três dimensões novas quando há
> divergência entre fontes. As restantes (Health Canada Product Monograph,
> DailyMed/FDA, LiverTox) servem para cobrir lacunas e corroborar.

---

## 1. Princípios

1. **Fontes de domínio público** — só fontes abertas que não violam direitos
   autorais (NIH/NLM: DailyMed, MedlinePlus, PubMed, LiverTox; EMA na UE).
   Nada de paywalls (ex.: NEJM) nem de credenciais/contas para contornar acesso.
2. **Citações reais e clicáveis** — cada par tem `source_pt`/`source_en` com
   URL verificado na API (setID do rótulo aprovado pela FDA). **É proibido
   inventar setIDs** — todos vêm da API e são revalidados.
3. **Migração idempotente e autossuficiente** — aplica-se uma vez; reaplicar
   é seguro (os pares já atualizados são re-escritos com valores idênticos).
4. **Severidade verificada clinicamente** — a severidade original do seed é
   confrontada com os rótulos/literatura; reclassificações (ex.: combinações de
   1.ª linha como ACEi+CCB rebaixadas para `none`) são justificadas no
   cabeçalho da migração e o texto (summary/management) é reenquadrado.
5. **Conteúdo clínico autorado** — os textos PT/EN (summary, mechanism,
   management, monitoring, red flags) são redigidos a partir de conhecimento
   farmacológico estabelecido e **ancorados/verificados** contra as fontes
   abertas citadas. A citação prova a fonte; não é extração automática.
6. **Prontuário Terapêutico como referência adicional** — o Prontuário do
   INFARMED (11.ª ed., 2012) é usado para **corroborar factos clínicos** e
   **citar bibliograficamente**, nunca como fonte de texto. O conteúdo PT/EN
   mantém-se sempre autoral; o Prontuário só é citado onde documenta o par
   (formato na secção 3.6).
7. **Sem pares artificiais** — os pares de uma família são escolhidos por
   relevância clínica documentada (Anexo 7 do Prontuário, rótulos FDA,
   literatura), não por quantidade. Se uma família tem poucas interações
   significativas (ex.: β-lactâmicos), gera-se um número pequeno de pares em
   vez de inflar com combinações sem suporte.
8. **Fonte canónica (Fluxo 2)** — para as dimensões alimento/bebida, doença e
   gestação, o **EMC-UK (MHRA)** é a fonte primária de verdade. Quando o EMC-UK
   e outra fonte (ex.: Health Canada) divergem, **vale o EMC-UK**; as outras
   fontes são usadas para cobrir o que o EMC-UK não documenta e para corroborar.
9. **Lacunas honestas** — se uma dimensão não está documentada em nenhuma fonte
   aberta (ex.: café na levotiroxina, enteral nutrition na carbamazepina), a
   omissão é registada na migração. Nunca se fabrica conteúdo para completar
   uma dimensão.

---

## 2. Fontes utilizadas

| Fonte | Uso | Acesso programático |
|---|---|---|
| **DailyMed (NIH/NLM)** | Rótulos aprovados pela FDA (equivalente ao RCM) — citação principal de **cada par fármaco-fármaco** (Fluxo 1) | ✅ API REST v2 pública |
| **EMC-UK (MHRA, medicines.org.uk)** | SmPC europeias aprovadas (EN) — **fonte canónica do Fluxo 2** (3 dimensões novas) | ✅ HTML estático, `/emc/product/{id}/smpc` |
| **Health Canada Product Monograph** | Monografias canadenses (partilham base regulatória europeia/americana) — **corroboração e cobertura de lacunas** no Fluxo 2 | ✅ DPD API JSON + PDF (`pdf.hres.ca/dpd_pm/{X}.PDF`) |
| **LiverTox (NIH/NLM)** | Hepatotoxicidade / doença hepática (apoio, sobretudo na dimensão doença) | ✅ Página pública `/books/n/livertox/{Name}/` |
| **MedlinePlus (NIH/NLM)** | Monografias de medicamentos (PT/EN) | ✅ Página pública |
| **PubMed (NIH/NLM)** | Literatura biomédica indexada (apoio clínico) | ✅ API/Página pública |
| **INFARMED** | RCM portugueses (Infomed) + **Prontuário Terapêutico (11.ª ed., 2012)** | ❌ Infomed protegido por WAF/Liferay → **referência manual apenas**; Prontuário = PDF público (ver 2.3) |
| **EMA (ue.europa.de portal)** | Fichas oficiais europeias | ⚠️ **Evitar:** portal JS-pesado / SPA; usar o espelho EMC-UK (smPC europeia) |
| **TGA (Austrália)** | Product Information australiana | ⚠️ Inacessível no ambiente de trabalho (rede); não bloqueado por licença |
| **WHO** | Guidelines / lista de medicamentos essenciais | ⚠️ POUCO útil para segurança (só lista/recomendação); não serve para dimensão de segurança |
| **DrugBank** | Catálogo de interações | ❌ **Não utilizar:** páginas públicas sem conteúdo (JS+login), downloads exigem conta e estão indisponíveis |

> **Recomendação do piloto multi-fonte (2026-08):** as fontes **EMC-UK e Health
> Canada Product Monograph** são as mais ricas e estáveis para as 3 dimensões
> novas, cobrindo alimento/bebida (toranja, álcool, vitamina K, cálcio/ferro,
> soja/fibra), doença (contraindicações + avisos) e gestação/lactação (PLLR).
> **DailyMed/FDA** continua a ser a fonte principal dos pares fármaco-fármaco.
> **DrugBank** foi testado e rejeitado (login/403/JS). **TGA** e **WHO** são
> opcionais e com limitações.

### API DailyMed (detalhe operacional)

- Endpoint v2 (lista): `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json?drug_name=<nome>&pagesize=200`
  - O parâmetro é **`drug_name`** (minúsculas, com underscore).
    `drugName`, `query`, `search`, `label` **são ignorados** pela API.
- Validação de um setID: `https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json?setId=<uuid>`
- Página legível por humanos:
  `https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=<uuid>`

### 2.1 EMC-UK (MHRA) — fonte canónica do Fluxo 2

- **Pesquisa** (devolve lista de produtos com IDs): 
  `https://www.medicines.org.uk/emc/search?q=<INN+inglês>`
- **SmPC completa** (HTML estático, parseável):
  `https://www.medicines.org.uk/emc/product/<id>/smpc`
- Secções relevantes do Fluxo 2 na SmPC:
  - **4.3 CONTRAINDICAÇÕES** — doença (contraindicações absolutas).
  - **4.4 AVISOS E PRECAUÇÕES** — doença (precauções) + fatores de risco.
  - **4.5 INTERAÇÕES** — alimento/bebida (toranja, álcool, cálcio/ferro…).
  - **4.6 GRAVIDEZ, FERTILIDADE E LACTAÇÃO** — gestação (teratogenicidade, folato, lactação).
- Se a pesquisa devolver um produto genérico de dose habitual, essa SmPC
  carrega a totalidade do conteúdo clínico aprovado (MHRA) — não precisa de ser
  a marca original, desde que seja o **mesmo princípio ativo**.

### 2.2 Health Canada — Product Monograph (corroboração)

- DPD API JSON (catálogo completo; **ignora filtros de query** — filtrar
  localmente por marca/DIN): `https://health-products.canada.ca/api/drug/drugproduct/?lang=en`
- Localizar `drug_code`/DIN na página DPD: 
  `https://health-products.canada.ca/dpd-bdpp/info.do?lang=en&code=<drug_code>`
- Product Monograph em PDF: `https://pdf.hres.ca/dpd_pm/<control>.PDF` (o valor
  `control` vem da página DPD; nem sempre é o DIN — resolver pela página).
- Secções: **CONTRAINDICAÇÕES**, **WARNINGS/PRECAUTIONS**, **Drug-Food
  Interactions**, **USE IN PREGNANCY/BREASTFEEDING (PLLR)**, **7.x Pregnancy/Lactation**.

### 2.3 Prontuário Terapêutico do INFARMED (11.ª ed., 2012)

- **Papel:** mapa das famílias terapêuticas e fonte bibliográfica de
  **referência adicional**. As fontes formais de cada par continuam a ser
  DailyMed/FDA (+ EMA/OMS); o Prontuário **corrobora** os factos clínicos e é
  **citado como referência adicional** onde documenta o par. Nunca fornece o
  texto PT/EN (conteúdo sempre autoral).
- **Estrutura útil:** capítulos por classe (ex.: 1.1.1 Penicilinas,
  1.1.2 Cefalosporinas, 1.1.7 Aminoglicosídeos, 1.1.1.1–1.1.1.4 subclasses) e
  o **Anexo 7 — "Interacções importantes"** (lista de pares clinicamente
  relevantes por família).
- **Acesso:** PDF público (ficheiro de texto `fontes_interacoes/prontuario_utf8.txt`
  no repositório para consulta offline).
- **Uso nas migrações 052–056:** inventário de fármacos da família,
  identificação de subclasses, e citação adicional nos pares que o anexo
  documenta (ex.: ceftazidima × estreptomicina — secção 1.1.7).

### 2.4 PubMed — apoio à farmacologia (Fluxo 3)

- **Papel:** quando o rótulo DailyMed não tem a secção 12 CLINICAL
  PHARMACOLOGY (caso dos **OTC**, ex.: ibuprofeno, omeprazol, antiácidos) ou
  quando a farmacocinética precisa de detalhe clínico, a farmacologia é
  autorada a partir de **revisões clássicas de farmacocinética** indexadas no
  PubMed (ex.: Davies NM, Clin Pharmacokinet 1998 — PMID 9515184, para o
  ibuprofeno) e resumos PharmGKB (PMC). A citação fica no campo
  `source_*` da `drug_pharmacology` com o PMID/PMC explícito.

---

## 3. Fluxo por família de fármacos (método atual — 052 a 056)

A partir da migração 052 o trabalho é organizado por **família terapêutica**
(antituberculares, azóis, β-lactâmicos…). O Prontuário Terapêutico serve de
mapa da família: cada capítulo lista os fármacos da classe e o **Anexo 7 —
"Interacções importantes"** lista os pares clinicamente relevantes.

### Passo 3.1 — Escolher a família e mapear as classes
- Ler o capítulo correspondente no Prontuário (ex.: 1.1.1 Penicilinas,
  1.1.2 Cefalosporinas, 1.1.7 Aminoglicosídeos) para inventariar os fármacos
  e as subclasses.
- Priorizar famílias com impacto real (antituberculares, antibacterianos,
  depois antirretrovirais, antiepilépticos, cardiovascular).

### Passo 3.2 — Selecionar fármacos com rótulo FDA aprovado
- As fontes formais mantêm-se **DailyMed/FDA (+ EMA/OMS)**. Só entram fármacos
  com rótulo aprovado disponível na DailyMed.
- **Nome INN em inglês** é obrigatório para a API DailyMed — nomes PT devolvem
  0 resultados.
- Usar o **filtro mono-ingrediente**: excluir produtos combinados
  (ex.: ampicilina+sulbactam, penicilina G benzatina+procaína) restringindo o
  título da SPL ao princípio ativo.
- Fármacos sem rótulo FDA (ex.: flucloxacilina) são **omitidos** — a omissão
  fica documentada no cabeçalho da migração.

### Passo 3.3 — Identificar parceiros já existentes
- Cruzar os fármacos da família com os já presentes em `public.drugs`
  (ex.: varfarina, alopurinol, estreptomicina) para formar pares com parceiros
  do seed.

### Passo 3.4 — Decidir os pares (sem pares artificiais)
- Os pares vêm da **relevância clínica documentada** (Anexo 7, rótulos,
  literatura), não de quantidade.
- Se a família tem poucas interações reais, gera-se poucos pares.
- Não marcar combinações intencionais (ex.: sinergia penicilina+aminoglicosídeo
  na endocardite) como interação adversa; não criar pares só para aumentar o
  número.

### Passo 3.5 — Obter e validar setIDs
- API DailyMed com `drug_name=<INN inglês>`.
- Revalidar cada setID (`?setId=`) → `n=1`.
- Confirmar as palavras-chave da interação (ex.: warfarin/prothrombin,
  allopurinol, aminoglycoside nephro/ototoxicity) na **página real** do rótulo
  (`drugInfo.cfm?setid=`).

### Passo 3.6 — Redigir a citação com referência adicional
- Forma base PT:
  `DailyMed/FDA (NIH/NLM) — rótulo aprovado {Nome PT}: <url> ; rótulo aprovado {Nome PT2}: <url>`
- Onde o Prontuário documenta o par, acrescentar:
  ` — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)`
- Espelho EN:
  `... — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)`
- Só citar o Prontuário onde ele realmente documenta (honestidade da fonte).

### Passo 3.7 — Gerar a migração (INSERT)
- Migração que **insere fármacos novos** em `public.drugs` e **pares** em
  `public.drug_interactions` (padrões 7.3/7.4), com `LEAST/GREATEST` canónico,
  `ON CONFLICT DO NOTHING` e `sort_order` seqüencial livre.
- Idempotente: reaplicar é seguro (UNIQUE `(drug_a_id, drug_b_id)`).

### Passo 3.8 — Validar e entregar
- Validação estrutural (secção 8). O utilizador aplica a migração manualmente
  no Supabase (o agente nunca executa migrações).

---

## 4. Fluxo passo a passo (método de citação UPDATE — 044/045/051)

> Referência ao método de verificação/citação que continua a aplicar-se à
> migração 051 e aos updates de `source_pt`/`source_en` em pares já existentes.

### Passo 1 — Escolher fármacos e pares
- Fármacos novos entram primeiro em `public.drugs` (ver schema na secção 6).
- Os pares são escolhidos por **relevância clínica** (combinações frequentes,
  risco real, prescrição comum em Angola/PT), não por quantidade.

### Passo 2 — Verificar slugs
- Confirmar que os `slug` usados existem em `public.drugs`. Um slug inexistente
  faz o `SELECT id` devolver NULL → a condição `WHERE` fica NULL → o UPDATE
  simplesmente não toca na linha (falha **silenciosa**). Sem erros, sem
  atualizações em massa, mas o par não é atualizado.

### Passo 3 — Obter os rótulos FDA (setIDs)
- Para cada fármaco, consultar a API DailyMed com `drug_name` e escolher um
  rótulo representativo (produto de dosagem habitual/mais comum).
- Acumular num **mapa `slug → setID`** que serve de fonte única de verdade
  para gerar o SQL (elimina erros de transcrição manual).

### Passo 4 — Validar os setIDs
- Revalidar **cada** setID na API (`?setId=`). Só entram no SQL os setIDs que
  resolveram na API.

### Passo 5 — Redigir as citações
- Formato PT:
  `DailyMed/FDA (NIH/NLM) — rótulo aprovado {Nome PT}: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=<uuid> ; rótulo aprovado {Nome PT}: https://...`
- Espelho EN:
  `DailyMed/FDA (NIH/NLM) — approved {Name EN} label: https://... ; approved {Name EN} label: https://...`

### Passo 6 — Classificar a severidade
- `critical` / `moderate` / `minor` / `none`, conforme os rótulos e literatura.
- **Rebaixamentos** (ex.: ACEi + bloqueador dos canais de cálcio → `none`,
  por ser combinação de 1.ª linha) exigem: justificação no cabeçalho da
  migração, reenquadramento do summary e esvaziamento de mechanism/
  monitoring/red_flags (campos `''`).

### Passo 7 — Gerar a migração
- Seguir o padrão SQL da secção 6.
- **Regra de ouro:** o `WHERE` é **independente da ordem dos ids** —
  `LEAST(..., ...) = LEAST((id A), (id B)) AND GREATEST(..., ...) = GREATEST((id A), (id B))`.
  A versão original que fixava um fármaco em `LEAST` e outro em `GREATEST`
  falhava silenciosamente em ~metade dos pares (os ids UUID são aleatórios).

### Passo 8 — Validar e aplicar
- Validação estrutural (secção 8) antes de aplicar no Supabase.
- Aplicar a migração (uma vez), revalidar com as queries de verificação.

---

## 5. Tabelas do fluxo (resumo dos passos)

| Passo | Ação | Verificação |
|---|---|---|
| 1 | Escolher fármacos + pares | relevância clínica |
| 2 | Confirmar slugs em `drugs` | `SELECT slug FROM public.drugs` |
| 3 | Buscar rótulos FDA | API DailyMed `drug_name` |
| 4 | Validar setIDs | API `setId=` |
| 5 | Redigir citação PT/EN | formato fixo com URLs reais |
| 6 | Classificar severidade | rótulos + literatura; justificar rebaixamentos |
| 7 | Gerar SQL | padrão canónico + WHERE independente da ordem |
| 8 | Validar + aplicar | greps estruturais + queries de verificação |

---

## 6. Schema (migração 043)

### `public.drugs` — colunas relevantes

`id UUID PK`, `slug TEXT UNIQUE`, `name_pt`, `name_en`, `class_pt`, `class_en`,
`aliases TEXT[]`, `status ('draft'|'published')`, `sort_order INT`,
`is_archived`, `created_at`, `updated_at`.

### `public.drug_interactions` — constraints

- `UNIQUE (drug_a_id, drug_b_id)`
- `CHECK (drug_a_id < drug_b_id)` — pares **canónicos**
- `severity CHECK IN ('critical','moderate','minor','none')`
- Colunas de conteúdo: `summary_pt/en` (**resumo do público leigo**),
  `summary_pro_pt/en` (resumo **profissional**), `explanation_pt/en`
  (explicação longa por par), `mechanism_pt/en`, `management_pt/en`,
  `monitoring_pt/en`, `red_flags_pt/en` — as colunas `summary_pro_*` e
  `explanation_*` foram adicionadas na migração 079
- Colunas de citação: `source_pt/en`, `source_url`
- RLS: `admin_all` (authenticated admin) + `anon_read` (só `published` e não arquivado)

> Nota: `source_url` é uma coluna única de link; as citações principais vivem em
> `source_pt`/`source_en` (texto com URLs embutidos).

### `public.drug_pharmacology` — secção Farmacologia (1:1 com drugs)

- `drug_id UUID UNIQUE REFERENCES drugs(id) ON DELETE CASCADE` — uma linha por
  fármaco (upsert por `drug_id`)
- Cinco subsecções PT/EN (texto corrido, parágrafos):
  `pharmacodynamics_pt/en`, `mechanism_pt/en`, `metabolism_pt/en`,
  `absorption_pt/en`, `half_life_pt/en`
- Citação: `source_pt/en` (DailyMed secção 12; PubMed/PharmGKB quando OTC)
- Estado: `status ('draft'|'published')`, `is_archived`, `archived_at/by`,
  `updated_by`, `created_at`, `updated_at`
- RLS: `admin_all` + `anon_read` (só `published` e não arquivado)
- Tabela criada na migração 086; conteúdo alargado nas 088–096

### `public.drug_profiles` — perfil editorial do fármaco (1:1 com drugs)

- `drug_id UUID UNIQUE REFERENCES drugs(id) ON DELETE CASCADE` — um perfil por
  fármaco (upsert por `drug_id`)
- Overview (toggle Público | Profissionais na ficha):
  `overview_public_pt/en` (tom leigo) e `overview_pro_pt/en` (tom técnico)
- Secções da ficha (bullets separados por `\n`, renderizados como lista):
  `indications_pt/en`, `side_effects_pt/en`, `precautions_pt/en`
- Citação: `source_pt/en`
- Estado: `status ('draft'|'published')`, `is_archived`, `archived_at/by`,
  `updated_by` (quem guardou pela última vez), `created_at`, `updated_at`
- RLS: `admin_all` + `anon_read` (só `published` e não arquivado)
- Tabela criada na migração 079; colunas de conteúdo na 080; `updated_by` na 082

---

## 7. Padrões SQL da migração

### 7.1 UPDATE de citação (o caso comum)

```sql
UPDATE public.drug_interactions
SET
  source_pt = 'DailyMed/FDA (NIH/NLM) — rótulo aprovado Enalapril: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=<uuid> ; rótulo aprovado Espironolactona: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=<uuid>',
  source_en = 'DailyMed/FDA (NIH/NLM) — approved Enalapril label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=<uuid> ; approved Spironolactone label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=<uuid>',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'enalapril'), (SELECT id FROM public.drugs WHERE slug = 'espironolactona'));
```

### 7.2 UPDATE de reclassificação de severidade

```sql
UPDATE public.drug_interactions
SET
  severity = 'none',
  summary_pt = '...',
  summary_en = '...',
  mechanism_pt = '', mechanism_en = '',
  monitoring_pt = '', monitoring_en = '',
  red_flags_pt = '', red_flags_en = '',
  management_pt = '...', management_en = '...',
  source_pt = '...', source_en = '...',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'captopril'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'captopril'), (SELECT id FROM public.drugs WHERE slug = 'amlodipina'));
```

### 7.3 INSERT de fármaco novo (método por família, quando o fármaco ainda não existe)

```sql
INSERT INTO public.drugs (slug, name_pt, name_en, class_pt, class_en, aliases, status, sort_order)
VALUES
  ('metronidazol', 'Metronidazol', 'Metronidazole', 'Antibiótico (nitroimidazol)', 'Antibiotic (nitroimidazole)', ARRAY['flagyl'], 'published', 10);
```

### 7.4 INSERT de par novo (quando o par ainda não existe)

```sql
INSERT INTO public.drug_interactions (drug_a_id, drug_b_id, severity,
  summary_pt, summary_en, mechanism_pt, mechanism_en,
  management_pt, management_en, monitoring_pt, monitoring_en,
  red_flags_pt, red_flags_en, source_pt, source_en, status)
SELECT
  LEAST(a.id, b.id), GREATEST(a.id, b.id),
  'moderate',
  '...', '...', '...', '...', '...', '...', '...', '...', '...', '...',
  'DailyMed/FDA (NIH/NLM) — rótulo aprovado ...: https://...', 'DailyMed/FDA (NIH/NLM) — approved ... label: https://...',
  'published'
FROM public.drugs a, public.drugs b
WHERE a.slug = 'x' AND b.slug = 'y'
ON CONFLICT (drug_a_id, drug_b_id) DO NOTHING;
```

> A canonicalização `LEAST/GREATEST` nas colunas é **obrigatória** no INSERT
> por causa do `CHECK (drug_a_id < drug_b_id)`. O `ON CONFLICT DO NOTHING`
> evita duplicar pares já existentes.

### 7.5 Citação-completa-de-exemplo (modelo byte-por-byte)

> **Modelo canónico** para qualquer sessão nova. Usa o par **varfarina ×
> ibuprofeno** com setIDs reais validados na API DailyMed. Uma sessão nova deve
> replicar **exatamente** esta forma (incluindo separadores `; `, o travessão
> `—`, os prefixos e a ordem dos rótulos: primeiro o parceiro com o rótulo do
> próprio fármaco na citação do par, depois o segundo). Não varia o texto.

SetIDs reais (já validados):
- Varfarina: `541c9a70-adaf-4ef3-94ba-ad4e70dfa057`
- Ibuprofeno: `14515409-736f-4119-b6a0-cb19ee2e948e`

Forma **PT** (exatamente):
```text
DailyMed/FDA (NIH/NLM) — rótulo aprovado Warfarina: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; rótulo aprovado Ibuprofeno: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e
```

Forma **EN** (exatamente):
```text
DailyMed/FDA (NIH/NLM) — approved Warfarin label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=541c9a70-adaf-4ef3-94ba-ad4e70dfa057 ; approved Ibuprofen label: https://dailymed.nlm.nih.gov/dailymed/drugInfo.cfm?setid=14515409-736f-4119-b6a0-cb19ee2e948e
```

Com **referência adicional** do Prontuário (onde o par está documentado no
Anexo 7 / capítulo), acrescentar no fim (PT / EN):
```text
 — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)
```
```text
 — with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)
```

Regras do modelo:
- **Ordem dos rótulos**: a mesma dos slugs na condição (não tem de seguir
  LEAST/GREATEST); mantém-se a ordem «primeiro fármaco citado, segundo fármaco»,
  consistente em PT e EN.
- **Separadores**: ` ; ` (espaço-ponto-e-vírgula-espaço) entre rótulos.
- **Nomes**: usar o nome PT no `rótulo aprovado {Nome PT}` e o nome EN no
  `approved {Name EN} label:` (ex.: Warfarina/Warfarin, Ibuprofeno/Ibuprofen).
- **Travessão**: ` — ` (em-dash) após «(NIH/NLM)» em ambas as línguas.
- **Nunca** trocar `setid` por outra capitalização — o parâmetro é
  minúsculo: `?setid=`.
- SetIDs **só** de fonte validada na API (nunca à mão — ver lição 2, secção 9).

### 7.6 INSERT por junção com VALUES (perfis / dimensões — padrão obrigatório)

Quando o INSERT seleciona de um `JOIN (VALUES ...)`, a condição de junção
**`ON d.slug = v.slug` é obrigatória**. Sem ela, o parser consome o
`ON CONFLICT` como condição do JOIN (erro `42601 syntax error at or near "DO"`)
e, mesmo que passasse, seria um CROSS JOIN (cada linha do VALUES cruzaria com
todos os fármacos). Padrão usado nos perfis (079/081) e nas 3 dimensões
(061–069):

```sql
INSERT INTO public.drug_profiles
  (drug_id, overview_public_pt, overview_public_en, status)
SELECT d.id, v.overview_public_pt, v.overview_public_en, 'published'
FROM public.drugs d
JOIN (VALUES
  ('warfarina', '...', '...'),
  ('ibuprofeno', '...', '...')
) AS v(slug, overview_public_pt, overview_public_en)
ON d.slug = v.slug            -- OBRIGATÓRIO: junção explícita
ON CONFLICT (drug_id) DO NOTHING;
```

---

## 8. Verificação

### 8.1 Validação estrutural (antes de aplicar)

```bash
# 32 UPDATEs no ficheiro de verificação
grep -c '^UPDATE public.drug_interactions' <migracao.sql>

# Todos os UPDATEs têm WHERE (forma nova, independente da ordem)
grep -c '= LEAST((SELECT id FROM public.drugs WHERE slug' <migracao.sql>

# NENHUMA ocorrência da forma antiga (bug que falhava silenciosamente)
grep -c 'WHERE LEAST(drug_a_id, drug_b_id) = (SELECT id' <migracao.sql>   # → 0

# Contagem de terminadores por declaração
grep -c ';$' <migracao.sql>
```

### 8.2 Após aplicar no Supabase

```sql
-- Total de pares com citação DailyMed (esperado: nº de pares na migração)
SELECT count(*) FROM public.drug_interactions WHERE source_pt LIKE 'DailyMed/FDA%';

-- Lista completa de pares com severidade (diagnóstico)
SELECT a.slug AS drug_a, b.slug AS drug_b, di.severity,
       LEFT(di.source_pt, 40) AS source_prefix
FROM public.drug_interactions di
JOIN public.drugs a ON a.id = LEAST(di.drug_a_id, di.drug_b_id)
JOIN public.drugs b ON b.id = GREATEST(di.drug_a_id, di.drug_b_id)
ORDER BY 1, 2;
```

### 8.3 Revalidar a cache do website (após aplicar no SQL editor)

Migrações aplicadas **diretamente no SQL editor do Supabase não passam pelas
Server Actions do admin** e, por isso, **não invalidam a cache ISR** — a página
`/interacoes` usa `revalidate = 3600` (1 h). Para o website mostrar os dados
novos em segundos, chamar o endpoint de revalidação on-demand:

```bash
# Tag (invalida todas as páginas que usam a tag 'interacoes')
curl "https://<site>/api/revalidate?secret=$REVALIDATE_SECRET&tag=interacoes"

# Path específico (alternativa)
curl "https://<site>/api/revalidate?secret=$REVALIDATE_SECRET&path=/pt/interacoes"
```

- O `REVALIDATE_SECRET` vive no `.env.local` (dev) e nas variáveis de ambiente
  da Vercel (produção).
- Whitelist de tags/paths em `app/api/revalidate/route.js` — alargar lá quando
  houver novos módulos.
- Sem o secret → 401; tags/paths fora da whitelist → 400; >20 pedidos/min → 429.

---

## 9. Lições aprendidas (gotchas)

1. **`drug_name`** é o parâmetro correto da API DailyMed; os restantes são
   ignorados e devolvem a lista inteira (resultados errados).
2. **Nunca escrever setIDs à mão.** SetIDs fictícios parecem válidos
   (UUID com a forma certa) mas não resolvem. Tudo vem da API e é revalidado.
3. **O `WHERE` tem de ser independente da ordem dos ids.** Fixar um fármaco no
   `LEAST` e o outro no `GREATEST` faz a condição dar FALSE quando os UUIDs
   estão ao contrário → ~metade dos pares não é atualizada, sem erro.
4. **INFARMED não é acessível por API** (WAF/Liferay, sem API pública). A
   alternativa oficial em português é a **EMA**. O INFARMED fica na lista de
   fontes como referência manual (portal), não como fonte automatizada.
5. **Migração idempotente**: reaplicar é seguro — desejável para correções.
6. **A API DailyMed exige o nome INN em inglês.** Nomes em português (ex.:
   "ceftriaxona") devolvem 0 resultados; usar o INN inglês ("ceftriaxone").
7. **Filtrar produtos combinados.** A busca pode devolver associações
   (ex.: ampicilina+sulbactam, penicilina G benzatina+procaína). Só são
   aceites rótulos **mono-ingrediente** — restringir o título da SPL ao
   princípio ativo e revalidar.
8. **Não inventar pares por família.** Fármacos com poucas interações reais
   (ex.: β-lactâmicos) geram poucos pares documentados. Combinações
   intencionais (ex.: sinergia penicilina+aminoglicosídeo) não são interações
   adversas — a omissão é explicada no cabeçalho da migração.
9. **`JOIN (VALUES ...)` sem condição de junção quebra o `ON CONFLICT`.** Um
   `INSERT ... SELECT ... JOIN (VALUES ...) AS v(...)` **sem** `ON d.slug = v.slug`
   faz o parser interpretar o `ON CONFLICT` como a condição do JOIN → erro
   `42601 syntax error at or near "DO"`; e, se passasse, seria um CROSS JOIN.
   A condição é obrigatória (padrão 7.6). Aconteceu na migração 079.

---

## 10. Fase 2 — famílias e fármacos candidatos

Trabalho feito por **família terapêutica** (fluxo da secção 3). Famílias já
concluídas: antimaláricos (052/053), antituberculares (054), azóis (055),
β-lactâmicos — penicilinas e cefalosporinas (056).

Ranking proposto para as próximas famílias (a confirmar antes de gerar a
migração):

1. **Antirretrovirais** (relevância clínica alta)
2. **Antiepilépticos** (fenitoína, valproato, carbamazepina — muitos pares
   com fármacos já presentes)
3. **Cardiovascular** (metoprolol, lítio, contraceptivos orais)

Cada fármaco novo exige: INSERT em `drugs`, pares clinicamente relevantes com
os fármacos já existentes (sem pares artificiais), setIDs DailyMed validados
(INN em inglês, rótulo mono-ingrediente) e classificação de severidade
justificada.

---

## 11. (reservado — expansão futura de famílias fármaco-fármaco)

---

## 12. Fluxo 2 — As 3 dimensões novas (alimento/bebida, doença, gestação)

> Este fluxo **não cria pares fármaco-fármaco**. Adiciona, para fármacos **que
> já existem** em `public.drugs`, interações de:
> (A) **alimento/bebida**, (B) **doença/condição**, (C) **gestação/lactação**.
> É um pedido separado do Fluxo 1 e **aditivo** — não toca em `drug_interactions`.

### 12.1 Fonte canónica e papel das fontes

- **EMC-UK (MHRA)** = **fonte primária de verdade** para as 3 dimensões.
- **Health Canada Product Monograph** e **DailyMed/FDA** = corroboração e
  preenchimento de lacunas que o EMC-UK não cobre (ex.: soja/fibra na
  levotiroxina só aparece na Health Canada).
- **LiverTox** = apoio à dimensão **doença** (hepatotoxicidade).
- Quando EMC-UK e outra fonte **divergem** (ex.: metformina-gravidez: EMC-UK
  «pode ser considerado» vs Health Canada «contraindicada»), **vale o EMC-UK**
  e a divergência pode ser anotada na migração.

### 12.2 Passo a passo

1. **Escolher o fármaco** já presente em `public.drugs` (slug confirmado).
2. **Obter a SmPC EMC-UK** (`/emc/search?q=<INN ing>` → `/emc/product/{id}/smpc`).
3. **Corroborar/cobrir lacunas** com Health Canada Monograph ou DailyMed
   quando o EMC-UK não documenta.
4. **Extrair por dimensão**:
   - **Alimento/bebida** → secções 4.5 (interações) + 4.4 (fatores que afetam INR/níveis).
   - **Doença** → secções **4.3 (contraindicações)** + **4.4 (avisos/precauções)**.
   - **Gestação/lactação** → secção **4.6** (teratogenicidade, folato, lactação, contracepção).
5. **Redigir conteúdo clínico autoral PT/EN** (nunca copiar o texto da fonte).
6. **Citar** a fonte real com URL verificado (formato na secção 12.4).
7. **Gerar a migração** (INSERT) nas tabelas próprias — secção 12.5.
8. **Validar e entregar** (o utilizador aplica manualmente).

### 12.3 Severidade por dimensão

- **Alimento/bebida**: `critical` / `moderate` / `minor` / `none` (ex.:
  vitamina K alimentar vs varfarina = alta relevância; álcool→acidose na
  metformina = moderate/critical).
- **Doença**: tipo `'contraindication'` (severidade `critical`) vs
  `'precaution'` (severidade `moderate`).
- **Gestação**: campo `pregnancy_risk` com valores normalizados
  (`'contraindicated'`, `'caution'`, `'no_data'`) + texto por trimestre/lactação.

### 12.4 Formato de citação (source_pt / source_en)

Base PT:
`EMC-UK (MHRA) — SmPC aprovada {Nome PT}: {url smpc}`
Espelho EN:
`EMC-UK (MHRA) — approved SmPC {Name EN}: {url}`
Onde outra fonte corroborou/colmatou, acrescentar:
` — corroboração: Health Canada Product Monograph: {url}` / EN `— corroborated by Health Canada Product Monograph: {url}`

> Só citar uma fonte onde ela realmente documenta (honestidade da fonte).

### 12.5 Schema das 3 tabelas novas

```sql
-- 1. Medicamento ↔ alimento/bebida
create table public.drug_food_interactions (
  id bigint generated always as identity primary key,
  drug_id uuid not null references public.drugs(id),
  entity_slug text not null,          -- 'vitamina_k' | 'sumo_toranja' | 'alho' ...
  entity_pt text not null,            -- 'Vitamina K (alimentar)'
  entity_en text not null,
  severity text not null,             -- critical | moderate | minor | none
  mechanism_pt text, mechanism_en text,
  advice_pt text, advice_en text,
  source_pt text, source_en text,
  sort_order int default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index on public.drug_food_interactions (drug_id, entity_slug);

-- 2. Medicamento ↔ doença/condição
create table public.drug_disease_interactions (
  id bigint generated always as identity primary key,
  drug_id uuid not null references public.drugs(id),
  condition_slug text not null,
  condition_pt text not null, condition_en text not null,
  interaction_type text not null,     -- 'contraindication' | 'precaution'
  severity text not null,             -- critical (contraind) | moderate (precaução)
  reason_pt text, reason_en text,
  advice_pt text, advice_en text,
  source_pt text, source_en text,
  sort_order int default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create unique index on public.drug_disease_interactions (drug_id, condition_slug);

-- 3. Medicamento ↔ gestação/lactação (1:1 por fármaco)
create table public.drug_pregnancy_info (
  id bigint generated always as identity primary key,
  drug_id uuid not null unique references public.drugs(id),
  pregnancy_category text,            -- 'contraindicated' | 'caution' | ...
  risk_pt text, risk_en text,         -- resumo de risco
  trimester_pt text, trimester_en text,-- por trimestre
  lactation_pt text, lactation_en text,-- aleitamento
  contraception_pt text, contraception_en text, -- se existir
  source_pt text, source_en text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

> Estas tabelas **referenciam `drugs.id`** mas **não tocam** em `drug_interactions`.
> São **aditivas**, alinhadas com os princípios de RLS (admin_all / anon_read)
> e de conteúdo autoral + citação das secções 1 e 6.

---

## 13. Fluxo 3 — Perfis de fármaco + farmacologia (drug_profiles + drug_pharmacology)

> Fluxo separado e aditivo. Cria/atualiza a ficha editorial de cada fármaco
> (`drug_profiles`, 1:1 com `drugs`): overview (público/profissionais),
> **indicações**, **efeitos secundários comuns** e **precauções**, PT/EN,
> exibidos na página `/medicamento/[slug]` com o toggle Público | Profissionais;
> e a secção **Farmacologia** (`drug_pharmacology`, 1:1 com `drugs`):
> farmacodinâmica, mecanismo de ação, metabolismo, absorção e meia-vida
> (ver 13.6). Não toca em `drug_interactions` nem nas tabelas do Fluxo 2.

### 13.1 Fontes e método

- **DailyMed/FDA (NIH/NLM)** = fonte principal: secções **INDICATIONS AND
  USAGE**, **ADVERSE REACTIONS**, **CONTRAINDICATIONS** e **WARNINGS AND
  PRECAUTIONS** do rótulo aprovado (mesma validação de setIDs do Fluxo 1,
  secção 3.5 — INN em inglês, rótulo mono-ingrediente).
- **Rótulos OTC** (ex.: omeprazol) têm secções próprias (Purpose/Use/Warnings);
  usar como estão e completar as indicações de prescrição com o Prontuário
  quando aplicável (citar ambos).
- **Prontuário Terapêutico (11.ª ed., 2012)** = corroboração dos factos
  clínicos e citação adicional (mesmo papel do Fluxo 1, secção 2.3).
- **Conteúdo autoral**: resumir/adaptar, nunca copiar o texto do rótulo.

### 13.2 Passo a passo

1. Confirmar o slug em `public.drugs` (o perfil é 1:1 — se o fármaco não
   existir, INSERT em `drugs` primeiro).
2. Obter e validar o setID na API DailyMed.
3. Descarregar o rótulo e extrair as secções (INDICATIONS, ADVERSE REACTIONS,
   CONTRAINDICATIONS/WARNINGS).
4. Corroborar cada facto no Prontuário (tudo deve ser verificável).
5. Redigir PT/EN:
   - `overview_public` (2–3 frases, tom leigo) e `overview_pro` (classe,
     indicações formais, farmacologia — tom técnico);
   - `indications`, `side_effects`, `precautions` — **bullets separados por
     `\n`** (renderizados como lista na página); incluir no fim dos efeitos
     uma linha «Procure ajuda imediata se…».
6. Citar (formato na secção 13.3) e gerar a migração (padrão 7.6).
7. Validar (greps estruturais) e entregar — o utilizador aplica manualmente
   no Supabase.

### 13.3 Formato de citação

Base PT:
`DailyMed/FDA (NIH/NLM) — rótulo aprovado {Nome PT}: <url drugInfo.cfm?setid=…>`
Espelho EN:
`DailyMed/FDA (NIH/NLM) — approved {Name EN} label: <url>`
Onde o Prontuário corrobora, acrescentar no fim (igual ao Fluxo 1, secção 3.6):
` — com referência adicional: Prontuário Terapêutico do INFARMED (11.ª ed., 2012)`
/ EN `— with additional reference: Prontuário Terapêutico do INFARMED, INFARMED (11th ed., 2012)`.

### 13.4 Estado e histórico

- `status ('draft'|'published')` decide a visibilidade pública; `is_archived`
  é soft-delete. No admin, **guardar um perfil arquivado volta a torná-lo
  visível** (`is_archived = false`) e regista `updated_by` (quem editou pela
  última vez).

### 13.5 Migrações e cobertura atual

- **079**: cria a tabela + colunas `summary_pro_*/explanation_*` em
  `drug_interactions` + 6 perfis piloto (warfarina, ibuprofeno, ramipril,
  espironolactona, sotalol, furosemida) + par novo warfarina × ibuprofeno.
- **080**: colunas `indications_*/side_effects_*/precautions_*` + 5 perfis
  completos.
- **081**: lote 2 — 13 fármacos (digoxina, amiodarona, ciprofloxacina,
  metronidazol, carbamazepina, fenitoina, valproato, metformina, levotiroxina,
  atorvastatina, amlodipina, omeprazol + furosemida completada).
- **082**: `updated_by` (rastreio de quem guardou).
- **084**: coluna `atc_code` em `drugs` (padrão `FROM (VALUES) AS v(slug,
  atc_code)`).
- **086**: tabela `drug_pharmacology` + 6 primeiros (farmacologia dos piloto
  da 079).
- **088–096**: lotes de **perfil completo + farmacologia** — 30+26+30+30+30
  (incl. os de 0 pares), até **todos os fármacos com perfil e farmacologia**
  (182/182 na BD; ver auditoria em `docs/AUDITORIA_LACUNAS.md`).
- **132**: perfis dos 2 fármacos adicionados depois (benzilpenicilina-benzatina,
  piperacilina-tazobactam).
- **133**: publica todos os perfis/farmacologias em `draft` (a RLS anónima só
  expõe `published`).

### 13.6 Farmacologia (drug_pharmacology) — método

A secção **Farmacologia** da ficha (`/medicamento/[slug]`) tem cinco campos
PT/EN (texto corrido): **farmacodinâmica**, **mecanismo de ação**,
**metabolismo**, **absorção** e **meia-vida**.

1. Obter e validar o setID na API DailyMed (mesma regra do Fluxo 1 — INN
   inglês, rótulo mono-ingrediente).
2. Extrair da secção **12 CLINICAL PHARMACOLOGY** do rótulo: subsecções
   *Pharmacodynamics*, *Mechanism of Action*, *Metabolism*,
   *Absorption*, *Elimination/Half-life*.
3. **Rótulos OTC sem secção 12** (ex.: ibuprofeno, omeprazol, antiácidos):
   autorar a partir de revisões clássicas de farmacocinética no **PubMed**
   (PMID) e resumos PharmGKB (PMC) — ver secção 2.4. Nunca inventar valores.
4. Redigir PT/EN como **parágrafos corridos** (não bullets) — cada campo
   2–5 frases com os valores concretos do rótulo (picos, meias-vidas,
   percentagens de ligação, vias metabólicas e CYP envolvidos).
5. Citar: `DailyMed/FDA (NIH/NLM) — rótulo aprovado {Nome PT}, secção 12
   Clinical Pharmacology: <url>` / EN `— approved {Name EN} label, section 12
   Clinical Pharmacology: <url>`; para OTC usar `PubMed — … (PMID …);
   PharmGKB summary: <url>` (mesmo padrão PT/EN).
6. Gerar a migração com o padrão 7.6 (`JOIN (VALUES ...) ON d.slug = v.slug`,
   `ON CONFLICT (drug_id) DO NOTHING`) e `status = 'published'`.

---

## 14. Exemplo de piloto validado (2026-08)

> Resultado do teste multi-fonte que fundamenta a escolha EMC-UK. Fármacos
> testados: varfarina (DailyMed), atorvastatina, carbamazepina, levotiroxina,
> metformina (EMC-UK + Health Canada + LiverTox). Todos confirmaram as 3
> dimensões em fontes abertas citáveis, com divergências ocasionais entre
> fontes (metformina/levotiroxina na gravidez) que o EMC-UK resolve como
> canónica.

---

## 15. Fluxo 4 — Explicações longas fármaco-fármaco (camada editorial)

> Fluxo separado e aditivo. Não cria pares nem toca nas dimensões: preenche a
> **camada de profundidade** dos pares `drug_interactions` que já existem e
> estão publicados — `summary_pro_pt/en` (resumo profissional, 1–2 frases) e
> `explanation_pt/en` (explicação longa, 3–5 frases com mecanismo e orientação
> prática). Alimenta a secção «Explicação» da calculadora `/interacoes` e da
> ficha `/medicamento/[slug]`.

### 15.1 Âmbito e priorização

- Preenche os pares **sem** `explanation_*` (a coluna veio vazia nas migrações
  de seed 044–069).
- Ordem por **prioridade clínica**: primeiro os `critical`, depois os
  `moderate`, por **fármaco com mais pares em falta** (o mesmo fármaco cobre
  vários pares numa migração), depois `minor`/`none` quando sobrar.
- Uma migração = um fármaco (ou um pequeno grupo) com os seus N pares, cada
  um um `UPDATE` independente.

### 15.2 Fontes e método

- **DailyMed/FDA (NIH/NLM)** = fonte principal: secções **DRUG INTERACTIONS**,
  **WARNINGS AND PRECAUTIONS** e **CLINICAL PHARMACOLOGY** dos rótulos
  aprovados dos dois fármacos do par (setIDs já citados no `source_pt` do par —
  reutilizar, não revalidar do zero).
- **Prontuário Terapêutico (11.ª ed., 2012)** = corroboração dos factos
  clínicos e citação adicional (mesmo papel do Fluxo 1).
- **Conteúdo autoral**: a explicação é redigida com base no conhecimento
  farmacológico estabelecido e **ancorada** nos rótulos citados — nunca copiar
  o texto da fonte.

### 15.3 Passo a passo

1. Consultar a BD: pares do fármaco com `explanation_pt = ''`, agrupados por
   severidade e parceiro.
2. Para cada par, verificar no rótulo dos dois fármacos a secção de interações
   e ancorar o mecanismo (ex.: inibição do CYP3A4, quelação, QT aditivo,
   sinergia antiplaquetária).
3. Redigir PT/EN:
   - `summary_pro_*`: 1–2 frases, tom profissional, com a ação prática
     (ex.: «Vigiar o INR»);
   - `explanation_*`: 3–5 frases — contexto do mecanismo, consequência
     clínica, grupos de risco e orientação prática (dose, monitorização,
     alternativa). Não usar `\n` (texto corrido).
4. Gerar a migração com o **padrão 7.1** (UPDATE com `LEAST/GREATEST`
   canónico, `updated_at = now()`), `SET summary_pro_pt/en,
   explanation_pt/en` — um UPDATE por par (ver 15.5).
5. Validar (greps estruturais, secção 8) e entregar — o utilizador aplica
   manualmente no Supabase.

### 15.4 Migrações e cobertura atual

- **089/100**: padrão estabelecido (UPDATE com LEAST/GREATEST).
- **097–098**: 47 + 44 pares moderados dos fármacos com mais pares.
- **100–131**: lotes por fármaco (digoxina, amiodarona, claritromicina,
  rifampicina, ibuprofeno, antiácidos, ciprofloxacina, omeprazol, aspirina,
  atorvastatina, cetoconazol, furosemida, prednisolona, sertralina, tramadol,
  cotrimoxazol, cloroquina, fluconazol, hidroclorotiazida, isoniazida,
  itraconazol, quinina, ritonavir/voriconazol/clopidogrel, β2/teofilina/sotalol,
  antiepiléticos, vancomicina/aminoglicosídeos, eritromicina+anti-histamínicos,
  IECA/ARA, levotiroxina, azatioprina) + minor/none (111).
- **134**: explicações dos pares novos da benzilpenicilina-benzatina.
- **175/176/180/183**: explicações profissionais (summary_pro + explanation)
  dos pares do QUADRO 2 — 10 críticos (180) e os 34 restantes (183), fechando
  a cobertura editorial a 551/551 pares.

### 15.5 Exemplo (padrão 7.1 com explicação)

```sql
UPDATE public.drug_interactions
SET
  summary_pro_pt = 'Diclofenac + prednisolona: risco aditivo de úlcera e hemorragia gastrointestinal. Considerar gastroproteção nos doentes de risco.',
  summary_pro_en = 'Diclofenac + prednisolone: additive risk of peptic ulcer and gastrointestinal bleeding. Consider gastroprotection in at-risk patients.',
  explanation_pt = 'Os AINEs, como o diclofenac, aumentam o risco de eventos gastrointestinais graves (hemorragia, ulceração e perfuração), e o rótulo do diclofenac identifica o uso concomitante de corticosteroides orais como fator que aumenta o risco de hemorragia GI. A prednisolona, por seu lado, tem a precaução de uso com cautela em doentes com úlcera péptica ativa ou latente. Em conjunto, o risco de úlcera, hemorragia e perfuração digestiva aumenta de forma aditiva, sobretudo em idosos, com história de úlcera/hemorragia ou em tratamentos prolongados. Considerar gastroproteção (inibidor da bomba de protões) nos doentes de risco, usar a menor dose eficaz de cada fármaco e vigiar sintomas digestivos.',
  explanation_en = 'NSAIDs such as diclofenac increase the risk of serious gastrointestinal events (bleeding, ulceration and perforation), and the diclofenac label identifies concomitant use of oral corticosteroids as a factor that increases the risk of GI bleeding. Prednisolone, in turn, carries a precaution to use with caution in patients with active or latent peptic ulcer. Together, the risk of ulcer, bleeding and digestive perforation increases additively, especially in the elderly, with a history of ulcer/bleeding or in prolonged treatment. Consider gastroprotection (proton pump inhibitor) in at-risk patients, use the lowest effective dose of each drug and monitor digestive symptoms.',
  updated_at = now()
WHERE LEAST(drug_a_id, drug_b_id) = LEAST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'))
  AND GREATEST(drug_a_id, drug_b_id) = GREATEST((SELECT id FROM public.drugs WHERE slug = 'diclofenac'), (SELECT id FROM public.drugs WHERE slug = 'prednisolona'));
```

> O `WHERE` é o canónico independente da ordem (secção 7.1/lição 3). O texto
> não usa `\n` — os `explanation_*` são parágrafos corridos (ao contrário dos
> bullets das `indications_*/side_effects_*` dos perfis).

---

## 16. Fluxo 5 — Pack CSV para o Airtable (espelho das migrações)

> Fluxo de **exportação**, não de pesquisa: gera os CSVs que alimentam a base
> Airtable de pesquisa a partir das migrações SQL — **sem tocar em conteúdo**.
> O manual completo de operação (importar, ligar, verificar, gotchas) vive em
> **`docs/FLUXO_PACK_AIRTABLE_ATUALIZACAO.md`** e no README do pack
> (`_temp/airtable-pack/README.md`). Esta secção é o resumo que amarra o pack
> aos padrões SQL dos fluxos 1–4.

### 16.1 Regra de ouro: migrações = fonte única de verdade

- O pack CSV é uma **projeção** das migrações para o Airtable. Editam-se os
  dados na pesquisa (ou na migração) e **regenera-se o pack** — nunca se edita
  o CSV à mão e se reimporta.
- O gerador faz um **replay de todas as migrações em ordem de ficheiro**
  (descoberta automática, sem lista fixa de números) com a semântica do
  Postgres: `INSERT` cria, `UPDATE` altera apenas os campos indicados.

### 16.2 Gerar o pack

```bash
python scripts/generate_airtable_pack.py
```

Escreve **8 ficheiros** em `_temp/airtable-pack/` (contagens atuais entre
parênteses):

| Ficheiro | Tabela no Airtable | Conteúdo | Registos |
|---|---|---|---|
| `01-farmacos.csv` | Fármacos | `drugs` + `atc_code` (084) | 191 |
| `02-fontes.csv` | Fontes | URLs únicas extraídas das citações | 410 |
| `03-interacoes-farmaco-farmaco.csv` | Interações Fármaco-Fármaco | `drug_interactions` (incl. `summary_pro_*`/`explanation_*`) | 436 |
| `04-interacoes-alimento-bebida.csv` | Interações Alimento/Bebida | Fluxo 2 | 319 |
| `05-doencas.csv` | Doenças | nomes de condições | 137 |
| `06-interacoes-doenca.csv` | Interações Doença | Fluxo 2 | 396 |
| `07-gravidez-lactacao.csv` | Gravidez/Lactação | Fluxo 2 | 191 |
| `08-perfil-farmacologia.csv` | Perfil e Farmacologia | `drug_profiles` + `drug_pharmacology` 1:1 por fármaco (Fluxo 3) | 184 |

### 16.3 Padrões SQL que o gerador reconhece

Para o gerador apanhar dados novos, as migrações têm de seguir os padrões dos
fluxos 1–4 (secções 7, 12.5, 13, 15):

- **Fármacos**: `INSERT INTO public.drugs ... VALUES` (7.3).
- **Pares fármaco-fármaco** (3 estilos): `INSERT ... VALUES` com
  `LEAST/GREATEST` (7.4); `INSERT ... SELECT ... FROM (VALUES ...) AS
  v(slug_a, slug_b, ...) JOIN drugs` (062–069); `INSERT ... SELECT ... FROM
  public.drugs a, public.drugs b WHERE a.slug='x' AND b.slug='y'` com literais
  (083/085/094). Os campos novos `explanation_*`/`summary_pro_*` são lidos nos
  três estilos e nos UPDATEs do Fluxo 4.
- **Dimensões (Fluxo 2)**: `INSERT ... SELECT d.id, v.* FROM drugs d JOIN
  (VALUES ...) AS v(slug, ...) ON d.slug = v.slug` (padrão 7.6).
- **Perfil + farmacologia (Fluxo 3)**: o mesmo padrão 7.6 para
  `public.drug_profiles` e `public.drug_pharmacology` — o gerador junta as
  duas numa linha por fármaco (8.ª tabela).
- **ATC**: `UPDATE public.drugs SET atc_code = v.atc_code FROM (VALUES ...) AS
  v(slug, atc_code) WHERE d.slug = v.slug` (084).
- **Correções**: `UPDATE` do campo (severidade, fonte, resumo, explicação) —
  o padrão 7.1 com `LEAST/GREATEST` independente da ordem.

### 16.4 Replay vs BD (divergência esperada)

O pack é um **replay das migrações em disco**, não um espelho da BD atual:

- Se uma migração existir no ficheiro mas **não tiver sido aplicada** à BD
  (ex.: 069/134 nesta BD, antes de serem aplicadas), os registos aparecem no
  pack mas não na BD.
- Se a BD tiver sido alterada à mão (ou por migração editada depois), o
  inverso também acontece.
- **Consequência prática**: ao auditar o pack, comparar com a BD (query de
  diagnóstico) e não assumir que as contagens batem certo — a fonte única de
  verdade é o conjunto de migrações, e qualquer divergência sinaliza ou uma
  migração não aplicada ou um desvio manual.

### 16.5 Importar e ligar (resumo)

O ciclo completo (importação por CSV, campos de ligação `farmaco_a`/`farmaco_b`
→ Fármacos, `doenca` → Doenças, ligador REST, verificação, gotchas do BOM e do
formato `["recXXXX"]`) está documentado passo-a-passo em
**`docs/FLUXO_PACK_AIRTABLE_ATUALIZACAO.md`** (secções 4–6) e no README do pack.

---

## 17. Fluxo 6 — Perfis de fármacos tópicos/locais (sem interações sistémicas)

> Fluxo **aditivo e independente** dos fluxos 1–5: cobre fármacos de aplicação
> tópica/local (nasais, otológicos, oftálmicos, dérmicos) que **não têm
> interações fármaco-fármaco sistémicas relevantes**, mas que merecem ficha
> completa no site (perfil, farmacologia, segurança na gravidez e dimensões
> aplicáveis) por terem procura real nas farmácias.
>
> A infraestrutura **já existe** — reutiliza as tabelas e o padrão 7.6 dos
> fluxos 2 e 3 (drug_profiles, drug_pharmacology, drug_food_interactions,
> drug_disease_interactions, drug_pregnancy_info). **Não cria tabelas novas.**

### 17.1 Motivação e âmbito

- O prontuário tem capítulos integralmente tópicos (14 — otorrinolaringológicos;
  15 — oftalmológicos; parte do 13 — dérmicos) cujas monografias declaram
  interações "Desconhecidas" ou as remetem para fármacos sistémicos de outros
  grupos. Pela regra do fluxo 1 ("sem pares artificiais"), **não entram em
  `drug_interactions`** — e essa ausência é correta, não uma lacuna.
- O que falta é a **ficha editorial**: quando um utilizador procura
  "mupirocina" ou "azelastina", deve encontrar o fármaco na BD com perfil,
  farmacologia e segurança — e, futuramente, as farmácias onde está
  disponível (estratégia Medicamentos + `pharmacy_stock` do bot WhatsApp).
- Alinhamento de negócio: muitos fármacos "procurados mas pouco encontrados"
  nas farmácias angolanas são produtos tópicos (pomada nasal de mupirocina,
  gotas otológicas, colírios) — terem ficha própria dá-lhes visibilidade e
  torna a ferramenta de farmácias útil para esta categoria.

### 17.2 Critérios de seleção

1. **Fármaco com monografia própria** no Prontuário Terapêutico (INFARMED,
   11.ª ed., 2012) num subgrupo tópico/local (ex.: 14.1.1 descongestionantes
   nasais, 14.1.3 anti-histamínicos tópicos, 14.2 otológicos, 15.x oftálmicos).
2. **Relevância de procura**: priorizar os que um utilizador angolano
   procuraria numa farmácia (mupirocina nasal, azelastina, levocabastina,
   ácido cromoglícico, xilometazolina, neomicina tópica, etc.).
3. **Rótulo/setID disponível** nas fontes permitidas (secção 2) para ancorar
   o conteúdo — senão, usar o Prontuário + EMC-UK com a regra do padrão 088
   (conteúdo autoral, nunca copiado, com a fonte citada).

### 17.3 Regras de conteúdo

- **`drug_interactions`: vazia salvo pares documentados.** Nunca criar pares
  artificiais por "parecer lógico" (ex.: anti-histamínico tópico × sedativo).
  Se um rótulo documentar uma interação sistémica relevante (ex.: descongestivo
  nasal × IMAO, nota explícita do prontuário), aí sim entra como par
  documentado — caso raro.
- **`drug_profiles` (1:1)**: overview público (o que é, para que serve, via de
  aplicação), indicações, efeitos locais (não sistémicos) e precauções — com
  ênfase em gravidez/aleitamento e em sinais de absorção sistémica excessiva
  (uso prolongado de descongestivos, corticosteróides tópicos).
- **`drug_pharmacology` (1:1)**: o campo `absorption_pt/en` é o mais
  importante — documentar explicitamente "absorção sistémica mínima" (ou o
  risco quando há, ex.: corticosteróides nasais em uso prolongado, gotas
  otológicas com perfuração timpânica). Mecanismo local e meia-vida sistémica
  (quando aplicável).
- **`drug_pregnancy_info` (1:1)**: sempre preencher — a segurança na gravidez
  de um tópico é informação de primeira linha (ex.: mupirocina "evitar",
  levocabastina "contraindicada nos 3 primeiros meses").
- **`drug_disease_interactions`**: só quando a fonte documenta (ex.:
  aminoglicosídeos otológicos × perfuração timpânica — ototoxicidade;
  descongestivos × doença cardiovascular).
- **`drug_food_interactions`**: normalmente vazia — não forçar entradas.

### 17.4 Fontes (mesmas regras da secção 2)

- **DailyMed/FDA** — rótulos de tópicos existem (mupirocina, azelastina,
  cromoglicato, neomicina/polimixina) e são a âncora preferida (setIDs
  validados na API, como nos fluxos 1–4).
- **EMC-UK (MHRA)** — particularmente útil para tópicos europeus cujos
  resumos (SmPC) cobrem absorção sistémica, gravidez e duração de uso;
  usada como corroboração ou fonte primária quando o rótulo FDA é pobre.
- **Health Canada** — corroboração (Product Monograph).
- **Prontuário Terapêutico (INFARMED)** — monografias PT (indicações,
  reações, contraindicações) e a fonte da seleção por grupo.
- Regra inegociável: **nada inventado** — cada número/frase tem correspondência
  na fonte citada; os textos PT/EN são autorais (nunca cópia literal).

### 17.5 Padrão SQL (reutiliza 7.6)

Mesmo padrão das migrações 137/164 — `INSERT ... SELECT d.id, v.* FROM
public.drugs d JOIN (VALUES ...) AS v(slug, ...) ON d.slug = v.slug` + `ON
CONFLICT (drug_id) DO NOTHING` (e `ON CONFLICT (drug_id, entity_slug)` /
`(drug_id, condition_slug)` nas dimensões), `status 'published'`:

1. `INSERT INTO public.drugs` — fármacos tópicos que ainda não existem
   (padrão 7.3, com `class_pt/en` indicando a via: "Antibiótico tópico (nasal)",
   "Anti-histamínico tópico (nasal)", etc.).
2. `drug_profiles` + `drug_pharmacology` (1:1) — padrão 7.6.
3. `drug_pregnancy_info` (1:1) — padrão 7.6.
4. `drug_disease_interactions` — só as documentadas (padrão 7.6).
5. `drug_interactions` — **omitida** (sem pares).

Aplicar na ordem: fármacos → perfis/farmacologia → dimensões. Idempotente.

### 17.6 Exemplo (grupo 14 — mupirocina nasal)

- `drugs`: slug `mupirocina`, class_pt "Antibiótico tópico (nasal)".
- `drug_profiles.indications_pt`: "Erradicação de portadores nasais de
  Staphylococcus aureus resistente à meticilina (MRSA)" (prontuário 14.1.5).
- `drug_pharmacology.absorption_pt`: absorção sistémica mínima pela mucosa
  nasal — uso local sem efeitos sistémicos relevantes (rótulo DailyMed).
- `drug_pregnancy_info`: evitar durante a gravidez e o aleitamento
  (prontuário: "Evitar durante a gravidez e o aleitamento").
- `drug_interactions`: sem entradas.

### 17.7 Estado e cobertura

- Os fármacos sistémicos dos grupos 13–16 já têm perfil completo (fluxos 2–4;
  migrações 137/164). Os tópicos dos grupos 13 (parte dérmica), 14 e 15
  **ainda não têm ficha** — é o backlog deste fluxo, por lotes (um grupo por
  migração, ex.: lote 1 = tópicos do grupo 14).
- Cada lote segue o mesmo ciclo dos fluxos 1–4: seleção → validação de fontes
  → migração → validação estrutural (secção 8.1) → aplicação manual no
  Supabase → revalidação da cache (secção 8.3).

---

## 18. Auditoria dos 12 fármacos sem par fármaco-fármaco (2026-08)

### 18.1 Contexto

Após o fecho do Fluxo 4 (explicações dos 551 pares, migração 183), a BD
ficou com **12 fármacos sem nenhum par em `drug_interactions`** (todos com
as outras 3 vertentes — doença, alimento, gravidez/aleitamento — preenchidas).
Esta secção regista a auditoria de cada um contra as fontes de referência
(Prontuário INFARMED Anexo 7, DailyMed/FDA, EMC-UK) e a decisão tomada:
**3 fármacos receberam pares reais (migração 184); 9 foram excluídos** por
não terem interações fármaco-fármaco documentadas nas fontes.

### 18.2 Resultado: 3 fármacos receberam pares (migração 184)

| Fármaco | Pares criados | Severidade | Fonte exata |
|---|---|---|---|
| **Acenocumarol** | × amiodarona, diclofenac, cimetidina, paracetamol, levotiroxina, propafenona, alopurinol | moderate | Prontuário QUADRO 2 — "Acenocumarol: V. Varfarina" + entrada Varfarina |
| | × clopidogrel, aspirina, cotrimoxazol | critical | idem (hemorragia aditiva) |
| **Micofenolato** | × colestiramina, ferro | moderate | Prontuário QUADRO 2 (resinas sequestradoras; Ferro) + DailyMed CellCept 7.1 |
| | × probenecida, rifampicina | moderate | DailyMed CellCept 7.1 (probenecida eleva MPAG 3×; indutores da glucuronidação reduzem MPA) |
| **Filgrastim** | × lítio | moderate | DailyMed Neupogen — "Drugs which may potentiate the release of neutrophils, such as lithium, should be used with caution" |

**Justificação do acenocumarol:** o QUADRO 2 remete explicitamente para a
varfarina ("Acenocumarol: V. Varfarina") — as interações documentadas da
varfarina aplicam-se aos derivados cumarínicos. A varfarina já tinha 62 pares
na BD; dos parceiros documentados na entrada Varfarina, 10 estão na BD e
foram replicados para o acenocumarol com a mesma severidade (critical para
clopidogrel/aspirina/cotrimoxazol — hemorragia aditiva; moderate para os
restantes).

**Justificação do micofenolato:** duas fontes independentes — o DailyMed
CellCept (secção 7.1: probenecida eleva a AUC do MPAG em 3×; fármacos que
induzem a glucuronidação, como a rifampicina, diminuem a exposição ao MPA) e
o Prontuário QUADRO 2 (resinas sequestradoras e ferro reduzem a absorção do
micofenolato).

**Justificação do filgrastim:** o rótulo DailyMed Neupogen documenta a
precaução com fármacos que potenciam a libertação de neutrófilos (lítio).

### 18.3 Resultado: 9 fármacos excluídos (sem interação FF documentada)

| Fármaco | Motivo da exclusão |
|---|---|
| **Aminoácidos** | Solução nutritiva — sem interações fármaco-fármaco clínicas documentadas nas fontes. |
| **Poractanto alfa** | Surfactante endotraqueal neonatal — sem interações sistémicas documentadas. |
| **Mupirocina** | Uso tópico com absorção sistémica mínima — sem interações FF nas fontes. |
| **Azelastina** | Via nasal/ocular tópica — sem interações sistémicas documentadas. |
| **Levocabastina** | Via nasal/ocular tópica — sem interações sistémicas documentadas. |
| **Nistatina** | Não absorvida por via oral — sem interações sistémicas. |
| **Butilbrometo de hioscina** | EMC-UK (Buscopan) não lista interações FF específicas (apenas efeito antimuscarínico aditivo teórico). |
| **Artesunato** | Interações FF não documentadas nas fontes (as de rifampicina/mefloquina pertencem ao arteméter/lumefantrina, não ao artesunato). |
| **Primaquina** | DailyMed/Health Canada: apenas interações genéricas (agentes hemolíticos, prolongamento do QT) — sem par específico com fármaco na BD (a quinacrina, o par clássico, não está na BD). |

### 18.4 Validação e estado

- **18 slugs usados na 184** — todos existem na BD (verificado por query).
- **Nenhum dos 15 pares existia antes** (cruzamento com `drug_interactions`
  antes da aplicação) — a 184 usa `ON CONFLICT (drug_a_id, drug_b_id) DO
  NOTHING`, por isso reaplicar é seguro.
- **setIDs DailyMed verificados** — CellCept `37241e87-4af4-4dc3-a1aa-ea6f20d8dc40`,
  Neupogen `97cc73cc-b5b7-458a-a933-77b00523e193` (nunca inventar fontes;
  secção 2).
- **Migração**: `supabase/migrations/184_pares_acenocumarol_micofenolato_filgrastim.sql`
  (15 pares; 3 critical + 12 moderate; padrão 7.4 com LEAST/GREATEST).
- **Estado pós-184**: 226 fármacos · 566 pares · 9 fármacos sem par
  (todos tópicos/não-sistémicos com justificação registada acima).

> **Nota de manutenção:** se um destes 9 fármacos ganhar futuro uso sistémico
> (ex.: azelastina oral, artesunato IV), reavaliar contra as fontes antes de
> adicionar pares. O mesmo se aplica à primaquina se a quinacrina (mepacrina)
> for adicionada à BD.

### 18.5 Fecho das vertentes doença e alimento (migrações 185 e 186)

Após a 184, uma auditoria de cobertura por vertente revelou lacunas nas
outras dimensões: **18 fármacos sem alimento** e **4 sem doença**. As
migrações 185 e 186 fecharam ambas (todos os fármacos já existiam na BD;
nenhuma depende de fármacos novos).

**Migração 185 — alimento (19 entradas, 18 fármacos):**

| Grupo | Fármacos | Entidade | Severidade |
|---|---|---|---|
| Sumo de toranja (CYP3A4) | diltiazem, verapamilo, tacrolimus, sirolimus, pimozida | `sumo_toranja` | moderate (5) |
| Jejum recomendado | micofenolato | `toma_em_jejum` | moderate (1) |
| Vitamina K + álcool | acenocumarol (2, "V. Varfarina") | `vitamina_k`, `alcool` | moderate (2) |
| Sem interação relevante | mupirocina, levocabastina, cetamina, cloranfenicol, ertapenem, indacaterol, ticagrelor, probenecida, eslicarbazepina, cimetidina, degarelix | `sem_interacao_alimentar` | none (11) |

Âncoras: DailyMed Cardizem/Verapamil + PubMed (Bailey et al.) p/ CCB;
DailyMed tacrolimus/sirolimus/pimozida (citações literais do rótulo);
DailyMed CellCept (jejum); Prontuário QUADRO 2 p/ acenocumarol; DailyMed
Brilinta/Zebinix ("with or without food"); EMC-UK Onbrez (indacaterol).
15 setIDs DailyMed reais verificados (incl. cimetidina Mylan
`06c0a509-026f-44e0-9975-a94a8de51d43`).

**Migração 186 — doença (8 entradas, 4 fármacos):**

| Fármaco | Condições | Fonte |
|---|---|---|
| Tacrolimus | `insuficiencia_renal`, `insuficiencia_hepatica` | DailyMed Prograf (Astellas) — "Dosage Modification for Patients with Renal/Hepatic Impairment" |
| Sirolimus | `insuficiencia_hepatica` (reduzir ~1/3), `insuficiencia_hepatica_grave` (reduzir ~1/2) | DailyMed Rapamune 8.6 |
| Indacaterol | `insuficiencia_hepatica_grave` (sem dados), `doenca_cardiovascular_grave`, `hipocaliemia` | EMC-UK Onbrez Breezhaler SmPC 4.2/4.4 |
| Azelastina | `insuficiencia_renal` (Cmax/AUC +70-75% com Clcr <50) | DailyMed Astelin "Special Populations" |

Todas `precaution`/`moderate` (nenhuma contraindicação nas fontes).

### 18.6 Estado final de cobertura (pós-184/185/186)

| Vertente | Registos | Fármacos cobertos | Em falta |
|---|---|---|---|
| **Fármaco-fármaco** | 566 pares | 217/226 | 9 (todos justificados — 18.3) |
| **Doença/condição** | 512 | **226/226** | **0** ✅ |
| **Alimento/bebida** | 359 | **226/226** | **0** ✅ |
| **Gravidez/aleitamento** | 226 | 226/226 | **0** ✅ |

**~216/226 fármacos (≈96%) com as 4 vertentes completas**; os 9 restantes
sem par FF são os tópicos/não-sistémicos com justificação individual na
secção 18.3. As migrações 184/185/186 usam todas `ON CONFLICT ... DO NOTHING`
— reaplicar é seguro.

---

## Referências

- Metodologia clínica + padrões SQL: este documento (secções 1–17).
- Fluxo do pack Airtable (importar/ligar/verificar): `docs/FLUXO_PACK_AIRTABLE_ATUALIZACAO.md`.
- Gerador: `scripts/generate_airtable_pack.py` · Manual operacional do pack:
  `_temp/airtable-pack/README.md` · Ligador: `_temp/airtable-pack/link_records_api.py`
  · Verificação: `_temp/airtable-pack/verify_links.py`
