# Fluxo de Reporte de Stock — Bot WhatsApp (especificação)

> **Estado:** especificação de design (v1.0) — nada implementado ainda.
> **Objetivo:** farmácias, depósitos e importadores **parceiros** reportam disponibilidade de fármacos pelo WhatsApp; o bot interpreta, valida contra a base de medicamentos do site e atualiza `pharmacy_stock` em tempo quase real.
> **Liga-se a:** `README.md` (stack da VPS) e à futura ferramenta "Onde encontrar" do site (ver análise de integração).

---

## 1. Princípios de desenho

1. **Quase tempo real, não tempo real.** As farmácias angolanas usam sistemas de ponto de venda locais (Naqsell, KuatelaSoft, PHC...) sem API pública. O WhatsApp é a camada universal: funciona com qualquer sistema, até com papel e caneta.
2. **Nunca inventar.** O bot só regista fármacos que existem na base de medicamentos do site (validação obrigatória). Texto livre não reconhecido vai para uma fila de revisão do admin, nunca para a BD.
3. **A frescura é a moeda de confiança.** Todo o stock público mostra `updated_at` + fonte (`whatsapp` / `api` / `import` / `admin`). Nunca se anuncia "tempo real" — mostra-se "reportado há 2 h".
4. **Só parceiros escrevem.** O número de WhatsApp tem de estar registado numa farmácia parceira para poder reportar.
5. **Respostas curtas e sem emojis** (padrão do projeto): o parceiro está ao balcão, a resposta tem de caber no ecrã de um telemóvel.

---

## 2. Visão geral do fluxo

```
                    ┌───────────────────────── VPS (Oracle) ─────────────────────────┐
                    │                                                                │
  Farmácia parceira │   Evolution API      n8n                       Site (Vercel)   │
  ── WhatsApp ───►  │   recebe msg ───►    webhook ─── HTTP POST ──►  /api/bot/stock- │
  (mensagem texto)  │   (messages.upsert)  filtra + autentica        report (route)  │
                    │       ▲                                        │               │
                    │       │                                        ├─ parse + match │
                    │       │                                        ├─ valida contra │
                    │       │                                        │  medicamentos  │
                    │       │                                        ├─ upsert        │
                    │       │                                        │  pharmacy_stock│
                    │       │                                        └─ respostas    │
                    │       │                                              │         │
                    │   sendText ◄───── resposta JSON ◄────────────────────┘         │
                    └───────┼────────────────────────────────────────────────────────┘
                            ▼
                  Confirmação ao parceiro (e aviso de erro, se houver)
```

**Decisão de arquitetura:** o **n8n só orquestra** (recebe, filtra, chama, responde). Toda a inteligência — parsing, validação contra a BD de medicamentos, desambiguação e upsert — vive no **site** (rota `/api/bot/stock-report`), porque é aí que estão o modelo de dados, o cliente Supabase e a infraestrutura de testes. Alternativa equivalente: Supabase Edge Function (a rota Next.js foi escolhida por ser o padrão já usado no projeto).

---

## 3. Regras de base

| Regra | Valor |
|---|---|
| Quem pode reportar | Apenas números em `pharmacies.whatsapp_phone` |
| Formato aceite | Só **texto** (áudio/imagem → resposta a pedir texto) |
| 1 número = 1 farmácia | MVP. Multi-farmácia por número fica para depois |
| Escrita aceite | Maísculas, minúsculas, com/sem acentos ("nao tenho" = "não tenho") |
| Quantidade | Opcional ("10 caixas de X") — o status é obrigatório, a qty é bónus |

---

## 4. Formato de mensagens (comandos)

### 4.1 Verbos de estado

| Estado | Palavras-chave (normalizadas) | Exemplos |
|---|---|---|
| **Disponível** | `tenho`, `temos`, `ha`, `tem`, `disponivel`, `chegou`, `reposto`, `em stock`, `com stock` | "tenho amoxicilina 500mg" · "chegou ibuprofeno 400mg" |
| **Esgotado** | `nao tenho`, `nao temos`, `nao ha`, `sem stock`, `esgotado`, `acabou`, `faltou`, `zerado`, `s/ stock` | "esgotado amoxicilina" · "nao tenho paracetamol" |
| **Listar** | `stock`, `lista`, `meu stock`, `o que tenho` | "stock" → lista atual da farmácia |
| **Ajuda** | `ajuda`, `help`, `comando` | "ajuda" → instruções |
| **Cancelar** | `cancelar`, `esquecer` | limpa uma desambiguação pendente |

> **Ordem de deteção obrigatória:** negativos **primeiro** ("nao tenho" contém "tenho"). Sem verbo explícito, o bot pede confirmação em vez de assumir (evita o erro "amoxicilina 500mg" sozinho ser lido como disponível quando o parceiro queria dizer esgotado).

### 4.2 Formato dos itens

```
VERBO + item [, item, item ...]

item  = nome [dosagem] [forma]
ex.:  tenho amoxicilina 500mg comprimido, paracetamol 500mg
```

Separação de itens: `,` `;` `/` `+` e quebras de linha. O " e " só parte **se** cada segmento resultante tiver dosagem ou forma — senão "amoxicilina e acido clavulanico" fica um único produto (correto, é um só fármaco).

---

## 5. Parsing

### 5.1 Normalização

```
1. minúsculas
2. remover acentos/diacríticos (á→a, ç→c, ã→a...)
3. colapsar espaços e cortar pontuação das pontas
4. mapa de abreviaturas: "s/ stock"→"sem stock", "n/ tenho"→"nao tenho"
```

### 5.2 Deteção de intenção (por ordem)

1. `cancelar` → limpa pendentes
2. `ajuda|help|comando` → ajuda
3. `stock|lista|meu stock|o que tenho` → listagem
4. Regex **negativa** → estado `unavailable`
5. Regex **positiva** → estado `available`
6. Sem verbo → resposta de confirmação: *"Tens ou não tens «X»? Responde 'tenho' ou 'nao tenho'."*

### 5.3 Extração de itens

- Remover o verbo e o texto de estado do início.
- Partir por `,` `;` `/` `+` e novas linhas.
- ` e ` parte apenas se cada segmento tiver dose **ou** forma (ver 4.2).
- Item vazio ou só pontuação é descartado.

### 5.4 Dosagem e forma

| Componente | Regra | Exemplo |
|---|---|---|
| **Dose** | `(\d+[.,]?\d*)\s*(mg\|g\|mcg\|ug\|ml\|ui\|%)` — normaliza para mg quando aplicável (g→×1000, mcg→÷1000; ml/UI/% ficam) | "500mg", "0,5 g" → `500 mg` |
| **Forma** | `comprimido\|comp\|cp`, `capsula\|cap`, `xarope`, `suspensao\|susp\|sol`, `pomada\|creme`, `gotas`, `ampola`, `injetavel\|inj\|iv`, `supositorio`, `adesivo`, `inalador\|spray`, `colirio`, `gel` | "comp" → `comprimido` |
| **Nome** | o que sobra, aparado | "amoxicilina" |

Exemplo: `amoxicilina 500mg comprimido` → `{ nome: "amoxicilina", dose: "500 mg", forma: "comprimido" }`.

---

## 6. Validação contra a base de medicamentos

A base canónica é a tabela de medicamentos do site (mesma que alimenta a ferramenta Medicamentos). **Só fármacos ativos** (publicados, não arquivados) são elegíveis.

### 6.1 Pontuação de correspondência

Nomes normalizados da mesma forma que 5.1. Score por candidato:

| Score | Condição |
|---|---|
| 1.00 | nome + dose + forma iguais |
| 0.97 | nome + dose iguais (forma ausente na mensagem ou na BD) |
| 0.95 | nome igual, dose ausente na mensagem |
| 0.90 | prefixo do nome (≥ 4 caracteres) + dose igual |
| 0.85 | Jaro-Winkler ≥ 0.85 no nome + dose igual |
| 0.80 | Jaro-Winkler ≥ 0.85 no nome, dose ausente |

### 6.2 Regras de decisão

| Situação | Condição | Ação |
|---|---|---|
| **Aceite direto** | melhor score ≥ 0.97 | atualiza + confirmação normal |
| **Aceite com canónico** | melhor score 0.90–0.96 | atualiza + confirmação mostra o nome canónico da BD ("recebido: 'amoxilina 500mg'") |
| **Ambiguidade** | 2.º melhor ≥ melhor − 0.05 **e** ≥ 0.85 | não atualiza; lista numerada (ver 6.3) |
| **Não reconhecido** | melhor < 0.90 | não atualiza; resposta + log para revisão admin |

> **Regra anti-invenção:** se a mensagem traz dose e a BD só tem outra dose do mesmo nome ("amoxicilina 500mg" vs só "Amoxicilina 250mg"), **não** se regista com dose aproximada — cai em "não reconhecido" e o admin decide (ou cria o fármaco em falta).

### 6.3 Desambiguação interativa

Quando há vários candidatos próximos, o bot responde:

```
Encontrei várias correspondências para "amoxil":
1) Amoxicilina 500 mg
2) Amoxicilina + Ácido Clavulânico 500 mg
3) Amoxicilina xarope
Responde com o número (ou "cancelar").
```

- O estado fica em `stock_report_pending` com o item e o estado (disponível/esgotado) pretendidos.
- Resposta `1|2|3` → resolve e atualiza; resposta fora → pergunta de novo; `cancelar` → limpa.
- **Timeout de 15 min** — expirado, a resposta é ignorada e o item volta a "não reconhecido".

---

## 7. Atualização de `pharmacy_stock` (upsert)

```sql
INSERT INTO pharmacy_stock (pharmacy_id, drug_id, status, qty, source, updated_at)
VALUES ($1, $2, $3, $4, 'whatsapp', now())
ON CONFLICT (pharmacy_id, drug_id)
DO UPDATE SET
  status     = EXCLUDED.status,
  qty        = EXCLUDED.qty,
  source     = 'whatsapp',
  updated_at = now();
```

- **qty opcional:** "tenho 10 caixas de X" → regex `(\d+)\s*(caixas|embalagens|unidades)?\s*de`.
- Um report "esgotado" substitui o estado anterior (não há histórico de estados por agora — fica nos logs).
- Nada disto é visível publicamente sem passar pela query pública do site (RLS só de leitura anónima).

---

## 8. Confirmações e respostas do bot

| Situação | Resposta do bot |
|---|---|
| Sucesso (1 item) | `OK — Amoxicilina 500 mg: disponivel. Atualizado agora.` |
| Sucesso (vários) | `OK — 2 itens atualizados: Amoxicilina 500 mg (disponivel), Paracetamol 500 mg (esgotado).` |
| Parcial | `... Nao reconheci: "xarope azul". Se era para "Amoxicilina xarope", envia "tenho amoxicilina xarope".` |
| Nome canónico | `OK — atualizei Amoxicilina 500 mg (recebido: "amoxilina 500mg").` |
| Ambiguidade | lista numerada (ver 6.3) |
| Sem correspondência | `Nao encontrei "x" na nossa base. Envia o nome comercial ou a dosagem.` |
| Sem verbo | `Tens ou nao tens "amoxicilina 500mg"? Responde "tenho" ou "nao tenho".` |
| Número não registado | `Este numero nao esta registado como farmacia parceira.` (e aviso ao admin) |
| Áudio/imagem/documento | `Envia por texto, por favor.` |
| Listagem | `O teu stock atual (5 itens): Amoxicilina 500 mg (disponivel, ha 2 h), ...` |

### Diálogos de exemplo

**Diálogo 1 — report normal, 2 itens:**
```
Farmácia:  tenho amoxicilina 500mg, paracetamol 500mg
Bot:       OK — 2 itens atualizados: Amoxicilina 500 mg (disponivel),
           Paracetamol 500 mg (disponivel). Atualizado agora.
```

**Diálogo 2 — esgotado + desconhecido:**
```
Farmácia:  esgotado amoxicilina, e xarope azul
Bot:       OK — Amoxicilina 500 mg (esgotado). Nao reconheci: "xarope azul".
```

**Diálogo 3 — sem verbo:**
```
Farmácia:  amoxicilina 500mg
Bot:       Tens ou nao tens "amoxicilina 500mg"? Responde "tenho" ou "nao tenho".
Farmácia:  nao tenho
Bot:       OK — Amoxicilina 500 mg (esgotado). Atualizado agora.
```

**Diálogo 4 — ambiguidade:**
```
Farmácia:  tenho amoxil
Bot:       Encontrei varias correspondencias para "amoxil":
           1) Amoxicilina 500 mg
           2) Amoxicilina + Acido Clavulanico 500 mg
           Responde com o numero (ou "cancelar").
Farmácia:  2
Bot:       OK — Amoxicilina + Acido Clavulanico 500 mg (disponivel). Atualizado agora.
```

---

## 9. Workflow no n8n (nós)

| # | Node | Configuração |
|---|---|---|
| 1 | **Webhook** | Path `/evolution-stock` · POST · ativo |
| 2 | **Filter** | `body.data.key.fromMe === false` **e** tipo de mensagem é texto (`conversation`); ignora status, áudio, edições, próprias mensagens |
| 3 | **Code (extrair)** | lê `remoteJid` (número) e o texto (`message.message.conversation`) |
| 4 | **HTTP Request** | `POST https://www.conhecafarmacia.com/api/bot/stock-report` · headers `X-Bot-Secret: <BOT_API_SECRET>` · body `{ "from": "<remoteJid>", "text": "<texto>" }` |
| 5 | **Loop / sendText** | para cada `reply` no JSON → Evolution API `POST /message/sendText/{instance}` com `{ number, text }` e header `apikey` |
| 6 | **Erro** | branch de erro: log no n8n + resposta genérica "Ocorreu um erro. Tenta de novo." |

> A Evolution API entrega o webhook com cabeçalho `X-Evolution-Api-Key` (quando configurado) — o n8n pode validar antes de processar. O `X-Bot-Secret` protege a rota do site contra chamadas que não vêm do n8n.

---

## 10. Segurança

| Camada | Medida |
|---|---|
| **Registo** | Só números em `pharmacies.whatsapp_phone` podem escrever stock (verificado no endpoint) |
| **Endpoint** | Rota `/api/bot/stock-report` exige `X-Bot-Secret` (env `BOT_API_SECRET` no **site**, não na VPS) |
| **Webhook** | Segredo da Evolution já na stack (`.env` da VPS) |
| **BD** | Anon (público) só lê `pharmacy_stock`; escritas só via service role, no servidor |
| **Rate limit** | Básico no endpoint (ex.: 30 mensagens/min por número) para evitar abuso |
| **Auditoria** | Todas as mensagens vão para `stock_report_log` (quem, o quê, resultado) |

---

## 11. Esquema de dados (tabelas novas)

```sql
-- Farmacias / depositos / importadores parceiros
pharmacies (
  id             uuid pk default gen_random_uuid(),
  name           text not null,
  type           text check (type in ('farmacia','deposito','importador')) default 'farmacia',
  whatsapp_phone text unique,            -- numero registado (o que reporta)
  location       text,
  contact        text,
  maps_url       text,
  is_partner     boolean default true,
  created_at     timestamptz default now()
);

-- Disponibilidade por farmacia + farmaco (liga aos medicamentos existentes)
pharmacy_stock (
  pharmacy_id  uuid references pharmacies(id) on delete cascade,
  drug_id      uuid references medicamentos(id) on delete cascade,
  status       text check (status in ('available','unavailable')) not null,
  qty          int,
  source       text check (source in ('whatsapp','api','import','admin')) not null,
  updated_at   timestamptz default now(),
  primary key (pharmacy_id, drug_id)
);

-- Estado de desambiguacao pendente
stock_report_pending (
  pharmacy_id  uuid primary key references pharmacies(id) on delete cascade,
  items        jsonb not null,           -- [{drug_text, status, candidates}]
  created_at   timestamptz default now(),
  expires_at   timestamptz not null      -- created_at + 15 min
);

-- Auditoria de todas as mensagens processadas
stock_report_log (
  id           bigint generated always as identity primary key,
  pharmacy_id  uuid references pharmacies(id),
  raw_text     text not null,
  parsed       jsonb,                    -- itens extraidos (nome, dose, forma)
  result       text not null,            -- ok / partial / unknown / rejected / ambiguous
  created_at   timestamptz default now()
);

-- (Fase 2) sinonimos / nomes comerciais
drug_aliases (
  drug_id  uuid references medicamentos(id) on delete cascade,
  alias    text not null,
  primary key (drug_id, alias)
);
```

---

## 12. Auditoria e tratamento de erros

- **Tudo é logado**: cada mensagem (bruta + parseada) vai para `stock_report_log` com o resultado.
- **Fila de revisão do admin**: os "não reconhecidos" aparecem no admin com o texto original e os candidatos próximos — o admin corrige, cria o fármaco em falta ou adiciona um alias.
- **Erros de infra**: se o endpoint do site estiver em baixo, o n8n responde erro genérico e loga; nada de stock é perdido porque o report vem sempre do WhatsApp (pode-se repetir).

---

## 13. Testes do parser (casos obrigatórios)

| # | Entrada | Esperado |
|---|---|---|
| 1 | `tenho amoxicilina 500mg` | available · amoxicilina 500 mg |
| 2 | `NAO TENHO paracetamol` | unavailable · paracetamol |
| 3 | `chegou ibuprofeno 400mg, naproxeno 250mg` | available ×2 |
| 4 | `esgotado amoxicilina, e xarope azul` | unavailable amoxicilina + unknown "xarope azul" |
| 5 | `tenho amoxil` | ambiguidade (Amoxicilina vs Amoxicilina+Clavulânico) |
| 6 | `tenho amoxicilina e acido clavulanico` | 1 item (não parte em "e" — sem dose/forma) |
| 7 | `amoxicilina 500mg` (sem verbo) | pede confirmação |
| 8 | `tenho` (só verbo) | pede itens |
| 9 | `stock` | listagem |
| 10 | `ajuda` | ajuda |
| 11 | `cancelar` | limpa pendentes |
| 12 | `tenho 10 caixas de amoxicilina 500mg` | available · qty 10 |
| 13 | `500 mg` vs `0,5 g` | mesma dose normalizada |
| 14 | número não registado | rejected + aviso admin |
| 15 | áudio/imagem | pede texto |

---

## 14. Fases de implementação

| Fase | Conteúdo | Onde |
|---|---|---|
| **A** | Parser puro (`lib/whatsapp/parse.js`) + testes · endpoint `/api/bot/stock-report` · migração das 4 tabelas · admin de farmácias + revisão de não-reconhecidos | repositório do site |
| **B** | Workflow no n8n (secção 9) + registo dos primeiros parceiros | VPS |
| **C** | Desambiguação, aliases (`drug_aliases`), qty e listagem de stock | site |
| **D** | **Alertas de disponibilidade**: utilizador subscreve fármaco → notificação (email/WhatsApp) quando o status mudar | site + bot |

**A Fase D é o fecho do ciclo comercial** (ver análise): o utilizador que procura um fármaco escasso subscreve e é avisado quando um parceiro o reporta — o "tempo real" passa a ser a velocidade do bot, não a da farmácia.

---

## 15. Decisões em aberto

1. **1 número = 1 farmácia** para sempre, ou precisamos de comando multi-farmácia (`FARMACIA X` / `TROCO DE FARMACIA`)?
2. O número do bot é **dedicado** (recomendado) ou um número existente da equipa?
3. Na fase inicial, permitir **nomes comerciais** não canónicos (com `drug_aliases`) ou obrigar ao genérico da base?
4. A **qty** aparece publicamente (ex.: "Disponível — 10 caixas") ou só o status disponível/esgotado?
5. Quem cria os números: a própria farmácia regista-se, ou o admin registra e comunica o comando "ajuda"?
