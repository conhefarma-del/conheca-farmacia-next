# Pack Airtable — Base de Pesquisa de Interações Medicamentosas

Pack CSV gerado automaticamente a partir das migrações SQL
(`scripts/generate_airtable_pack.py`). **As migrações são a fonte única de
verdade** — nunca edites os dados aqui e depois os migres para o site; edita
na base de pesquisa e, quando verificado, gera a migração a partir dela (ou
vice-versa, como no arranque atual).

## Conteúdo (8 tabelas)

| Ficheiro | Tabela no Airtable | Registos |
|---|---|---|
| `01-farmacos.csv` | **Fármacos** | 191 |
| `02-fontes.csv` | **Fontes** | 410 |
| `03-interacoes-farmaco-farmaco.csv` | **Interações Fármaco-Fármaco** | 436 |
| `04-interacoes-alimento-bebida.csv` | **Interações Alimento/Bebida** | 319 |
| `05-doencas.csv` | **Doenças** | 137 |
| `06-interacoes-doenca.csv` | **Interações Doença** | 396 |
| `07-gravidez-lactacao.csv` | **Gravidez/Lactação** | 191 |
| `08-perfil-farmacologia.csv` | **Perfil e Farmacologia** | 184 |

Dados atuais: fármacos de uso comum em Angola + antimaláricos + antituberculares
+ antifúngicos + antibacterianos + antirretrovirais (044–058), SNC/analgésicos
(062), cardiovasculares (063), hematologia (064), respiratórios (065),
digestivos (066), músculo-esqueléticas (067), antialérgicos (068) e nutrição
(069), com as 3 dimensões novas (alimento/doença/gravidez) para os fármacos de
todas as secções (061–069), e a camada editorial nova: explicações longas
fármaco-fármaco (`explicacao_pt/en` + `resumo_pro_pt/en` — 097–131), perfis
público/profissional + indicações/efeitos/precauções (`drug_profiles` —
079–096) e farmacologia completa (`drug_pharmacology` — 086–096), espelhadas
na 8.ª tabela.

## Como importar

1. **Cria a base** no Airtable: *Create a base* → *Start from scratch*.
2. Em cada tabela: *Add or import* → *Upload CSV* → escolhe o ficheiro.
   Renomeia cada tabela para o nome indicado na coluna **Tabela no Airtable**
   acima (o Airtable usa o nome do ficheiro por defeito).
3. **Campo primário**: a primeira coluna (`slug`) é a chave única de cada
   registo — mantém-na como primary field.
4. **Importa primeiro `Fármacos` e `Fontes`** (são os alvos das ligações) e só
   depois as tabelas de interações.

## Ligar os registos (relações)

O CSV não importa campos de ligação. Depois de importar tudo:

1. Cria os campos de ligação seguintes (tipo *Link to another record*):
   - Em **Interações Fármaco-Fármaco**: `farmaco_a` → Fármacos, `farmaco_b` → Fármacos
   - Em **Interações Alimento/Bebida**: `farmaco` → Fármacos
   - Em **Interações Doença**: `farmaco` → Fármacos, `doenca` → Doenças
   - Em **Gravidez/Lactação**: `farmaco` → Fármacos
   - Em **Perfil e Farmacologia**: `farmaco` → Fármacos

2. Liga em massa de uma das duas formas:

   **Opção A (recomendada) — script Python via API REST:**
   ```bash
   AIRTABLE_BASE_ID=appXXXX AIRTABLE_PAT=patXXXX python link_records_api.py        # pré-visualiza
   AIRTABLE_BASE_ID=appXXXX AIRTABLE_PAT=patXXXX python link_records_api.py --run  # aplica
   ```
   O token é criado em airtable.com/create/tokens com scopes
   `data.records:read`, `data.records:write` e `schema.bases:read`, com acesso
   só à base de pesquisa. **Revoga o token quando terminares** (fica visível no
   histórico da sessão). Verificação opcional: `verify_links.py` (mesmas env vars).

   **Opção B — extensão Scripting** (`LINK_RECORDS.js`): funciona, mas a
   extensão mostrou-se pouco fiável nesta base (leitura que pendura em
   `selectRecordsAsync`). Prefere a Opção A.

> Os campos `farmaco_a_slug`, `farmaco_b_slug`, `farmaco_slug` e `doenca_slug`
> são deliberadamente mantidos como texto: são a **chave de junção portável**
> para o NocoDB/Postgres e para gerar migrações. **Não os conviertas** em
> campos de ligação — a conversão apaga os slugs e quebra a junção.

### Gotchas descobertos na prática

- **BOM UTF-8 nos nomes dos campos primários**: os CSVs usam `utf-8-sig`, por
  isso a primeira coluna de cada tabela importada tem um carácter invisível
  (U+FEFF) no início do nome. O `link_records_api.py` lê o campo primário pela
  posição/esquema e não pelo nome, por isso é imune. Se reimportares manualmente,
  renomeia o campo primário para `slug` limpo (seleciona tudo e apaga antes de
  escrever).
- **Valor de campo de ligação**: nesta base, a API aceita **apenas** o formato
  `["recXXXX"]` (array de IDs). O formato `[{"id":"recXXXX"}]` da documentação
  devolve `INVALID_RECORD_ID: [object Object]`.
- **Nomes dos campos de ligação**: `farmaco_a`, `farmaco_b`, `farmaco`,
  `doenca` — exatos, sem acentos. Verificar com o dry-run (imprime um AVISO se
  algum faltar, listando os campos de ligação existentes).

## Convenções

- **`estado`**: `publicado` (verificado e espelhado do site) / `rascunho` /
  `em_verificacao` / `verificado`. Quando migrares para NocoDB/Supabase, só o
  que estiver `publicado` (ou `verificado` e pronto) flui.
- **`severidade`**: `critical` / `moderate` / `minor` / `none` — mesmos valores
  do CHECK do Supabase.
- **`pregnancy_category`**: `contraindicated` / `caution` / `compatible`.
- **`tipo_interacao`**: `contraindication` / `precaution`.
- **`fonte_pt`/`fonte_en`**: citação completa com URL. A tabela **Fontes** foi
  derivada destas strings (uma por URL único) — preenche `acessado_em` quando
  verificares uma fonte.
- **`atc`**: preenchido para os fármacos com código conhecido (146/191 — a
  migração 084 só cobriu os fármacos que existiam na altura; os restantes ficam
  vazios até serem mapeados).
- **`explicacao_pt/en` + `resumo_pro_pt/en`** (Interações Fármaco-Fármaco): as
  explicações longas e o resumo profissional da camada editorial 097–131.
  403/436 pares têm explicação; os 33 sem são os pares das migrações 069/134
  (nutrição + benzilpenicilina) que nunca receberam UPDATE de explicação.

## Regenerar o pack

```bash
python scripts/generate_airtable_pack.py
```

O script faz um **replay de todas as migrações em ordem de ficheiro** — não há
lista fixa de números, por isso novas migrações (062, 065, … com numerção com
saltos) são apanhadas automaticamente. A semântica é a do Postgres:

- `INSERT INTO public.drugs` / `public.drug_interactions` / das 3 novas
  dimensões → **cria** (chave = slug / par de slugs / drug+entity / drug+condition / drug).
- `UPDATE public.drug_interactions` → **altera apenas os campos indicados**.

Para o gerador apanhar novos dados, mantém esses padrões nas futuras migrações:

- Fármacos: `INSERT ... VALUES`.
- Pares fármaco-fármaco (3 estilos suportados):
  `INSERT ... VALUES` com `LEAST/GREATEST` + `(SELECT id FROM public.drugs
  WHERE slug = '…')`, **ou** `INSERT ... SELECT ... FROM (VALUES …) AS
  v(slug_a, slug_b, …) JOIN public.drugs a ON a.slug = v.slug_a …` (migrações
  062–069), **ou** `INSERT ... SELECT ... FROM public.drugs a, public.drugs b
  WHERE a.slug = 'x' AND b.slug = 'y'` com literais na lista SELECT (migrações
  083/085/094). A severidade pode vir como coluna `v.severity` ou como literal
  na lista SELECT — ambos são lidos.
- Novas dimensões: `INSERT INTO <tabela> (...) SELECT d.id, v.* FROM drugs d
  JOIN (VALUES …) AS v(slug, …) ON d.slug = v.slug ON CONFLICT … DO NOTHING`.
- Perfil editorial + farmacologia: `INSERT INTO public.drug_profiles /
  public.drug_pharmacology (...) SELECT d.id, v.* FROM drugs d JOIN (VALUES …)
  AS v(slug, …) ON d.slug = v.slug …` — o gerador junta as duas tabelas numa
  única linha por fármaco na 8.ª tabela.
- Códigos ATC: `UPDATE public.drugs SET atc_code = v.atc_code FROM (VALUES …)
  AS v(slug, atc_code) WHERE d.slug = v.slug` (migração 084).
- Correções de conteúdo: `UPDATE` do campo (severidade, fonte, resumo,
  explicação, …).

Depois de atualizar a base do Airtable faz-se o mesmo de sempre: exporta os CSVs
de novo e substitui os dados (ou usa a API quando quiseres automatizar).

## Nota sobre a IA do Airtable

A IA do Airtable pode ajudar a **organizar** (resumir, categorizar, preencher
descrições, formatar). Não a uses para **gerar conteúdo clínico novo**: a base
espelha dados já verificados nas migrações (EMC-UK, FDA DailyMed, Health
Canada, WHO) e qualquer conteúdo clínico autorado tem de manter a mesma regra
de fontes públicas + verificação manual antes de publicar.
