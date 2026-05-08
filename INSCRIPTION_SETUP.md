# Guia de Configuração - Fluxo de Inscrição em Eventos

## 📋 O que foi implementado

### 1. **Página de Inscrição** (`inscricao.html`)

- Layout limpo e focado com formulário centralizado
- Formulário com campos:
  - Nome Completo (obrigatório)
  - Email (obrigatório)
  - Telefone (obrigatório)
  - Profissão (select com 6 opções)
  - Como ouviu sobre o evento (select com 6 opções)
  - Honeypot (anti-spam, oculto)
- Mensagens de sucesso e erro com animações smooth
- Design moderno e responsivo

### 2. **Scripts de Lógica**

#### `inscription-logic.js`

- Lê parâmetro `evento` da URL
- Valida honeypot para proteção contra bots
- Envia dados para Supabase tabela `inscricoes`
- Feedback em tempo real:
  - Botão muda para "A processar..." (disabled)
  - Desaparece o formulário suavemente
  - Aparece mensagem de sucesso animada
  - Em caso de erro, mostra mensagem específica

#### Atualizações aos scripts existentes

- **`events-logic.js`**: Botão "Inscrever-me" agora aponta para `inscricao.html?evento={slug}`
- **`event-detail.js`**: Botão de inscrição na página de detalhe também redireciona corretamente

### 3. **Estilos CSS**

- Formulário com validação visual (focus rings)
- Animações smooth (opacity + transform para 60 FPS)
- Botão de envio com estado "loading"
- Ícones de sucesso/erro com backgrounds coloridos

---

## 🔧 Configuração do Supabase

### Passo 1: Criar a Tabela

1. Aceda ao **Supabase Dashboard** → seu projeto
2. Vá para **SQL Editor**
3. Copie todo o conteúdo de `SUPABASE_MIGRATION.sql`
4. Copie e cole no SQL Editor
5. Clique em **Run** para executar

**Estrutura da tabela:**

```
inscricoes
├── id (BIGSERIAL PRIMARY KEY)
├── nome (TEXT)
├── email (TEXT)
├── telefone (TEXT)
├── profissao (TEXT)
├── origem_evento (TEXT)
├── evento_slug (TEXT)
├── created_at (TIMESTAMPTZ)
└── updated_at (TIMESTAMPTZ)
```

### Passo 2: Configurar Políticas de Segurança (RLS)

O script SQL já inclui:

- ✅ Política para INSERT sem autenticação (público pode inscrever-se)
- ✅ Política para SELECT apenas autenticados (admin pode ver inscrições)
- ✅ Índices para performance

### Passo 3: Verificar Credenciais do Supabase

Confirme que o arquivo `.env` está preenchido:

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anonima
```

---

## 🎯 Fluxo de Uso

### Para o Utilizador:

1. Utilizador clica em **"Inscrever-me"** na página de eventos (ou na lista)
2. É redirecionado para `inscricao.html?evento=slug-do-evento`
3. Preenche o formulário
4. Clica em **"Confirmar Inscrição"**
5. Se bem-sucedido:
   - Formulário desaparece suavemente
   - Mensagem de sucesso animada aparece
   - Botão "Voltar para Eventos" está disponível
6. Se houver erro:
   - Mensagem de erro com detalhes
   - Botão "Tentar Novamente" recarrega a página

### Para o Admin (Acompanhamento):

1. Aceda ao Supabase Dashboard
2. Vá para **Table Editor** → `inscricoes`
3. Veja todas as inscrições em tempo real
4. Filtre por `evento_slug`, `profissao`, `origem_evento`
5. Exporte dados em CSV se necessário

---

## 🔐 Segurança

### Anti-spam

- **Honeypot**: Campo oculto que bots preenchem automaticamente
- Se honeypot tem valor → inscrição é rejeitada
- Validação também no JavaScript

### Validação

- Email validado pelo `type="email"` do HTML5
- Telefone com `type="tel"`
- Campos obrigatórios garantem dados completos

### RLS (Row Level Security)

- Apenas anon key pode fazer INSERT
- Apenas users autenticados (admin) podem SELECT
- Nenhum user consegue DELETE ou UPDATE (seguro)

---

## 📊 Dados Recolhidos

| Campo           | Tipo      | Uso                    |
| --------------- | --------- | ---------------------- |
| `nome`          | texto     | Identificação          |
| `email`         | email     | Contacto direto        |
| `telefone`      | texto     | Contacto alternativo   |
| `profissao`     | select    | Segmentação de público |
| `origem_evento` | select    | Análise de marketing   |
| `evento_slug`   | texto     | Rastreamento de evento |
| `created_at`    | timestamp | Auditoria              |

---

## ✨ Animações e UX

### Estados do Botão:

```
Normal: "Confirmar Inscrição"
  ↓ (ao clicar)
Loading: "A processar..." (disabled)
  ↓ (sucesso ou erro)
Mostrar mensagem animada
```

### Transições:

- **Fade out do formulário**: 300ms
- **Fade in da mensagem**: 600ms (com easing ease-out)
- **Transform**: translateY (move 20px para cima)
- **Performance**: Usa `opacity` e `transform` para 60 FPS

---

## 📝 URLs de Referência

| Página           | URL                           | Parâmetro       |
| ---------------- | ----------------------------- | --------------- |
| Lista de Eventos | `/eventos.html`               | —               |
| Detalhe Evento   | `/evento.html?id=1`           | `id` (número)   |
| Inscrição        | `/inscricao.html?evento=slug` | `evento` (slug) |

**Exemplo:**

```
/inscricao.html?evento=001-farmacologia-clinica
/inscricao.html?evento=002-uso-racional-medicamentos
```

---

## 🐛 Troubleshooting

### "Erro ao conectar Supabase"

- Verifique `.env` tem URL e ANON_KEY corretos
- Confirme que a tabela `inscricoes` foi criada
- Verifique browser console para erro específico

### "Honeypot foi ativado"

- Bots estão a preencher o formulário
- Nenhuma ação é necessária (inscrição foi bloqueada)
- Monitore frequência em logs

### "Inscrição não aparece no Supabase"

- Verifique que RLS policies foram criadas corretamente
- Confirme que ANON_KEY tem permissão de INSERT
- Procure erros na coluna `created_at` (timestamp válido?)

---

## 📦 Ficheiros Criados/Modificados

### Novos Ficheiros:

- ✅ `inscricao.html` — Página de inscrição
- ✅ `inscription-logic.js` — Lógica de submissão
- ✅ `SUPABASE_MIGRATION.sql` — Script de criação de tabela

### Modificados:

- ✅ `events-logic.js` — Links de inscrição atualizados
- ✅ `event-detail.js` — Botão de inscrição na página de detalhe
- ✅ `src/input.css` — Estilos do formulário e animações
- ✅ `dist/output.css` — Recompilado com novos estilos

---

## 🚀 Próximos Passos Opcionais

1. **Email de confirmação** — Integrar com Supabase Functions + SendGrid/Resend
2. **Limite de vagas** — Verificar `inscricoes.count()` antes de permitir
3. **Dashboard admin** — Página protegida para ver inscrições em tempo real
4. **Export CSV** — Botão para descarregar inscrições em CSV
5. **Notificações** — Enviar email ao admin quando nova inscrição chegar
6. **Captcha** — Adicionar reCAPTCHA para proteção extra

---

**Tudo pronto para começar! 🎉**
