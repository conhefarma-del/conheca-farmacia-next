# Fluxo de Pesquisa e Adição de Interações Medicamentosas

Documento que descreve o método usado para **pesquisar, verificar e adicionar**
interações à calculadora de interações (`/interacoes`).

> **Três fluxos independentes.** O trabalho divide-se em **três pedidos
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
- **Fluxo 3 — Perfis de fármaco** (`drug_profiles`): a ficha editorial de cada
  fármaco (overview público/profissionais, indicações, efeitos secundários,
  precauções — PT/EN), que alimenta a página `/medicamento/[slug]`. Usa
  **DailyMed como fonte principal** + corroboração do Prontuário. → Ver
  **secção 13**.

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

## 13. Fluxo 3 — Perfis de fármaco (drug_profiles)

> Fluxo separado e aditivo. Cria/atualiza a ficha editorial de cada fármaco
> (`drug_profiles`, 1:1 com `drugs`): overview (público/profissionais),
> **indicações**, **efeitos secundários comuns** e **precauções**, PT/EN,
> exibidos na página `/medicamento/[slug]` com o toggle Público | Profissionais.
> Não toca em `drug_interactions` nem nas tabelas do Fluxo 2.

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

---

## 14. Exemplo de piloto validado (2026-08)

> Resultado do teste multi-fonte que fundamenta a escolha EMC-UK. Fármacos
> testados: varfarina (DailyMed), atorvastatina, carbamazepina, levotiroxina,
> metformina (EMC-UK + Health Canada + LiverTox). Todos confirmaram as 3
> dimensões em fontes abertas citáveis, com divergências ocasionais entre
> fontes (metformina/levotiroxina na gravidez) que o EMC-UK resolve como
> canónica.
