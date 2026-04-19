# 📅 Guia para Criação de Eventos

## Estrutura de um Evento

Os eventos são armazenados em `content/events-catalog.json` e contêm todos os dados necessários para renderização automática.

---

## 🔄 NOVO: Sistema de Sincronização de Vagas em Tempo Real

**⚠️ IMPORTANTE:** O campo `registered` no JSON é apenas um valor **inicial/padrão**. O número real de vagas é consultado **diretamente do Supabase** sempre que a página carrega.

### Como Funciona:

1. **Inscrição criada** → Dados guardados em tabela `inscricoes` do Supabase
2. **Página de evento carrega** → JavaScript consulta Supabase automaticamente
3. **Vagas sincronizadas** → Mostra número REAL de inscrições
4. **Se capacidade atingida** → Botão "Inscrever-me" fica desabilido com "Evento Completo"

### Exemplo:
```
Evento: Workshop (capacidade 40)
JSON diz: registered = 23 (desatualizado)
Supabase diz: 5 inscrições reais
Resultado na página: 40 - 5 = 35 vagas disponíveis ✓
```

---

## 🚫 NOVO: Proteção contra Inscrições Duplicadas

O sistema **bloqueia automaticamente** tentativas de inscrição duplicada:

- **Database**: UNIQUE constraint em `(email, evento_slug)`
- **Frontend**: Verifica antes de enviar
- **Resultado**: Mesma pessoa não pode inscrever-se duas vezes no mesmo evento

---

## 📸 Dimensões de Imagens

### Card de Evento (Página Eventos)
- **Proporção**: 16:9 (largura : altura)
- **Tamanho Recomendado**: **1280×720px**
- **Alternativas**:
  - 1600×900px (melhor qualidade)
  - 960×540px (arquivo menor)
  - 800×450px (mínimo aceitável)

**⚠️ Importante:** O CSS usa `object-cover`, portanto imagens que não respeitarem a proporção 16:9 serão cortadas nas laterais.

---

## 🎨 Estrutura de um Evento no JSON

```json
{
  "id": 11,
  "slug": "011-seu-evento",
  "title": "Workshop: Seu Título do Evento",
  "excerpt": "Resumo breve (2-3 linhas) que aparece no card de listagem",
  "category": "workshop",
  "categoryLabel": "Workshop",
  "date": "2026-06-15",
  "time": "09:00",
  "endTime": "13:00",
  "status": "upcoming",
  "location": "Luanda, Angola",
  "type": "presencial",
  "capacity": 50,
  "registered": 28,
  "host": {
    "name": "Nome do Apresentador",
    "role": "Cargo · Função",
    "organization": "Organização"
  },
  "image": "assets/content/articles/sua-imagem.png",
  "registrationLink": "#"
}
```

---

## 🏷️ Categorias Disponíveis

| ID | Categoria | Label | Cor |
|----|-----------|-------|-----|
| 1 | `workshop` | Workshop | 🟠 #ff6c23 |
| 2 | `palestra` | Palestra | 🟢 #0a844f |
| 3 | `congresso` | Congresso | ⬛ #002a32 |
| 4 | `live` | Live | 🔵 #006171 |
| 5 | `webinar` | Webinar | 🟣 #7c3aed |

---

## 🔄 Status Automático

O campo `status` é **calculado automaticamente** com base na data:
- Se `date >= hoje` → `"upcoming"` (Próximos Eventos)
- Se `date < hoje` → `"past"` (Eventos Passados)

**Você NÃO precisa preencher este campo manualmente** — ele será gerado pelo JavaScript.

---

## 📝 Campos Obrigatórios

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | número | ID único incremental |
| `slug` | texto | URL-friendly identifier (ex: `001-farmacologia`) |
| `title` | texto | Título do evento (máx 80 caracteres) |
| `excerpt` | texto | Resumo breve (máx 150 caracteres) |
| `category` | texto | Uma das categorias acima (minúscula) |
| `categoryLabel` | texto | Label visual da categoria |
| `date` | data | Formato `YYYY-MM-DD` |
| `time` | hora | Formato `HH:MM` (24h) |
| `endTime` | hora | Formato `HH:MM` (24h) |
| `location` | texto | Localização ou "Online" |
| `type` | texto | `"presencial"` ou `"online"` |
| `capacity` | número | Número máximo de participantes |
| `registered` | número | **NOTA:** Valor inicial apenas. Número real é consultado do Supabase |
| `host` | objeto | { name, role, organization } |
| `image` | caminho | Localização da imagem (proporção 16:9) |
| `registrationLink` | URL | Link de inscrição (pode ser `"#"` por enquanto) |

---

## 👤 Informação do Apresentador

```json
"host": {
  "name": "João Pedro",
  "role": "Farmacêutico · Palestrante",
  "organization": "UNILA"
}
```

- **name**: Nome completo do apresentador
- **role**: Cargo e função (use · como separador)
- **organization**: Instituição ou empresa

---

## 📄 Páginas Relacionadas

### **eventos.html** - Lista de Eventos
- Mostra eventos com filtros (Temporal e Categoria)
- Vagas sincronizadas em tempo real ✓
- Botão bloqueado se completo ✓
- Cada card mostra: "X vagas disponíveis" ou "Evento completo"

### **evento.html?id=X** - Detalhe de Evento (NOVO)
- Página dedicada a cada evento
- Card "Vagas Disponíveis" com barra de progresso
- Informação do apresentador (host)
- Eventos relacionados (mesma categoria)
- Sincronização com Supabase ✓

### **inscricao.html?evento=XXX** - Formulário de Inscrição (NOVO)
- Formulário com validação completa
- Bloqueia duplicatas automaticamente
- Email de confirmação enviado automaticamente
- Campos: Nome, Email, Telefone, Profissão, Origem

---

## ✅ Antes de Publicar

1. ✔️ Imagem com proporção 16:9 (1280×720px recomendado)
2. ✔️ Título claro e conciso (máx 80 caracteres)
3. ✔️ Excerpt com 2-3 linhas máximo (máx 150 caracteres)
4. ✔️ Categoria correta (minúscula)
5. ✔️ Data em formato `YYYY-MM-DD`
6. ✔️ Hora em formato 24h (`HH:MM`)
7. ✔️ Type é `"presencial"` ou `"online"`
8. ✔️ Capacity > 0 (vagas disponíveis)
9. ✔️ Host com name, role, organization
10. ✔️ Imagem guardada em `assets/content/articles/`
11. ✔️ **Testar em eventos.html** - filtros e sincronização funcionam
12. ✔️ **Testar em evento.html** - vagas sincronizadas corretamente
13. ✔️ **Testar inscrição** - formulário valida e email é enviado

---

## 🚀 Fluxo de Adição de Novo Evento

1. **Preparar imagem**: 1280×720px, proporção 16:9
2. **Guardar imagem**: `assets/content/articles/seu-evento.png`
3. **Adicionar ao JSON**: Copiar template acima e preencher
4. **Verificar campos**: Todos os campos obrigatórios preenchidos
5. **Testar em eventos.html**:
   - Filtro temporal (Próximos/Passados)
   - Filtro por categoria
   - Card exibe corretamente
   - Vagas sincronizadas com Supabase ✓
6. **Testar em evento.html?id=X**:
   - Título, imagem, detalhes carregam
   - Vagas mostram número real (não JSON)
   - Barra de progresso funciona
7. **Testar inscrição**:
   - Clique "Inscrever-me"
   - Formulário abre em inscricao.html?evento=XXX
   - Preencher com dados válidos
   - Confirmação de inscrição exibida
   - Email recebido com sucesso

---

## 📊 Eventos Atuais

Total de eventos: **10**

| ID | Título | Categoria | Data | Status |
|----|--------|-----------|------|--------|
| 1 | Workshop: Farmacologia Clínica Aplicada | Workshop | 2026-05-24 | upcoming |
| 2 | Palestra: Uso Racional de Medicamentos | Palestra | 2026-06-08 | upcoming |
| 3 | Congresso: Excelência em Cuidado Farmacêutico 2026 | Congresso | 2026-07-15 | upcoming |
| 4 | Live: COVID-19 e Novos Tratamentos | Live | 2026-05-10 | upcoming |
| 5 | Webinar: Detecção de Interações Medicamentosas | Webinar | 2026-05-30 | upcoming |
| 6 | Workshop: Farmacocinética Aplicada na Prática | Workshop | 2026-06-20 | upcoming |
| 7 | Palestra: Legislação de Medicamentos em Angola | Palestra | 2026-04-12 | past |
| 8 | Live: Supportive Care em Oncologia | Live | 2026-04-05 | past |
| 9 | Congresso: 2025 — Recap | Congresso | 2026-03-20 | past |
| 10 | Webinar: Estratégias de Adesão | Webinar | 2026-03-15 | past |

---

## 💡 Dicas & Boas Práticas

### Sincronização de Vagas (NOVO)
- O JavaScript consulta Supabase quando a página carrega
- Número no JSON é apenas para fallback
- Se Supabase falhar, usa JSON como backup
- Vagas são atualizadas em TEMPO REAL ✓

### Bloqueio de Capacidade (NOVO)
- Se `vagas disponíveis <= 0` → Botão "Evento Completo" (desabilido)
- Se alguém conseguir duplicar inscrição → Erro 23505 (UNIQUE constraint)
- Mensagem clara: "Já está registado neste evento"

### URL-Friendly Slugs
- Use hífens para separar palavras
- Comece com ID em 3 dígitos: `001-`, `002-`, etc.
- Exemplo: `005-webinar-interacoes-medicamentosas`

### Datas Futuras
- Sempre use datas no futuro para "upcoming"
- Para eventos passados, use datas anteriores a hoje
- Hoje é 2026-04-19

### Organização de Imagens
- Use nomes descritivos: `farmacologia-clinica.png`
- Mantenha em `assets/content/articles/` (reutiliza pasta de artigos)
- Comprima imagens (máx 200KB por imagem)

### Teste Completo
Quando adicionar novo evento, teste:
```
eventos.html → Filtros funcionam?
evento.html?id=X → Vagas sincronizadas?
Clique "Inscrever-me" → Formulário valida?
inscricao.html → Email enviado?
```

---

## 🔧 Sincronização Técnica

### Como o Supabase Sincroniza Vagas:

```javascript
// evento.html carrega e executa:
const realCount = await getInscriptionCount(event.slug);
// Query: SELECT COUNT(*) WHERE evento_slug = 'XXX'
// Supabase retorna: número real de inscrições
spotsLeft = event.capacity - realCount; // Vagas recalculadas
```

### Proteção contra Duplicatas:

```javascript
// Antes de enviar inscrição:
const alreadyRegistered = await checkExistingInscription(email, evento_slug);
if (alreadyRegistered) {
  // Mostrar: "Já está registado neste evento"
  return;
}
```

---

## 🔐 Segurança de Inscrições e Dados

### 🛡️ Proteção Implementada

O sistema de inscrição de eventos inclui múltiplas camadas de segurança:

#### 1️⃣ **Proteção contra Duplicatas**
```
Base de Dados: Constraint UNIQUE em (email, evento_slug)
Resultado: Mesma pessoa NÃO pode inscrever-se 2x no mesmo evento
Mensagem ao utilizador: "Já tem uma inscrição neste evento com este endereço de email"
```

#### 2️⃣ **Proteção contra Bots (Honeypot)**
```
Sistema: Campo oculto que bots tentam preencher
Frontend: Valida se campo está vazio (invisível para humanos)
Backend: Edge Function valida novamente
Resultado: Bots são bloqueados automaticamente
```

#### 3️⃣ **Validação em Duas Camadas**

| Camada | Validação |
|--------|-----------|
| **Frontend** | Verificação de campos vazios, email, telefone, comprimento máximo |
| **Backend** | Edge Function valida NOVAMENTE todos os dados + rate limiting |
| **Database** | RLS Policies bloqueiam acesso não autorizado |

#### 4️⃣ **Rate Limiting (Proteção contra Spam)**
```
Frontend: Máximo 1 inscrição a cada 5 segundos por utilizador
Backend: Máximo 5 pedidos por IP a cada 60 segundos
Resultado: Spam e DoS são prevenidos
```

#### 5️⃣ **Sanitização de Dados**
```
Nome: Máximo 255 caracteres, caracteres perigosos removidos
Email: Validação RFC 5322 + máximo 255 caracteres
Telefone: Validação para Angola e Internacional
Profissão: Limitada a valores pré-aprovados
Origem: Limitada a valores pré-aprovados
```

### 📋 Campos do Formulário de Inscrição

Quando um utilizador se inscreve, os dados guardados são:

| Campo | Tipo | Validação |
|-------|------|-----------|
| `nome` | Texto | 3-255 caracteres, sem scripts |
| `email` | Email | RFC 5322, máximo 255 caracteres |
| `telefone` | Telefone | Angola/Internacional, máximo 20 caracteres |
| `profissao` | Select | Whitelist: 15 valores pré-aprovados |
| `origem_evento` | Select | Whitelist: 8 valores pré-aprovados |
| `evento_slug` | Texto | Validado contra eventos-catalog.json |

### 🚫 Dados NÃO Recolhidos

- ❌ Password ou informação sensível
- ❌ Dados de cartão de crédito
- ❌ Informação médica
- ❌ Localização precisa (apenas "Luanda", "Online", etc.)

### 📧 Email de Confirmação

Quando inscrição é bem-sucedida:

1. **Email é enviado** através do Resend
2. **Contém**: Confirmação de inscrição + detalhes do evento
3. **Segurança**: Email é enviado servidor (não exposto ao frontend)
4. **Falha silenciosa**: Se email falhar, inscrição continua válida

### ✅ Checklist de Segurança para Novos Eventos

Antes de publicar novo evento:

1. ✔️ Verifique `capacity > 0` (vagas disponíveis)
2. ✔️ Imagem não contém malware (use stock photos confiáveis)
3. ✔️ Descrição do evento não contém links suspeitos
4. ✔️ Email do presentador é válido (para registro)
5. ✔️ Data e hora são realistas (não no passado distante)
6. ✔️ Local é específico e correto

### 🚨 Sinais de Alerta

Se receber inscrições suspeitas:

- **Muitas inscrições do mesmo IP** → Rate limiting bloqueou, mas continua investigar
- **Nomes com caracteres estranhos** → Sistema sanitizou, mas verifique
- **Emails com padrão suspeito** → Email inválido foi bloqueado
- **Honeypot ativado** → Bot foi detectado e bloqueado

### 💡 Boas Práticas

- ✅ Revise inscrições regularmente
- ✅ Notifique inscritos sobre cancelamento com antecedência
- ✅ Use Supabase dashboard para monitorar dados
- ✅ Backup regular de inscrições
- ✅ Deletar dados de utilizadores quando solicitado (GDPR)

### 🔍 Verificação de Segurança

Quando adicionar novo evento, o sistema automaticamente:

```
1. Valida estrutura JSON ✓
2. Verifica campos obrigatórios ✓
3. Valida formato de data ✓
4. Valida formato de imagem ✓
5. Sincroniza vagas com Supabase ✓
```

---

## 🔧 Sincronização Técnica & Segurança

### Como o Supabase Sincroniza Vagas:

```javascript
// evento.html carrega e executa:
const realCount = await getInscriptionCount(event.slug);
// Query: SELECT COUNT(*) WHERE evento_slug = 'XXX'
// Supabase retorna: número real de inscrições
spotsLeft = event.capacity - realCount; // Vagas recalculadas
```

### Proteção contra Duplicatas (Técnica):

```javascript
// Edge Function valida:
if (existingInscription(email, evento_slug)) {
  // Retorna 400 Bad Request
  return { error: 'Já registado' };
}
```

---

**Dúvidas sobre segurança? Contacte o administrador do sistema.**

**Dúvidas sobre conteúdo? Consulte o `content/events-catalog.json` para exemplos completos.**
