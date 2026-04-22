# 💊 Conheça Farmácia — Portal de Educação e Gestão Clínica

[![Security: Verified](https://img.shields.io/badge/Security-Security--First-green?style=flat-square)](#arquitetura-de-segurança)
[![Database: Supabase](https://img.shields.io/badge/Database-Supabase-3ECF8E?style=flat-square&logo=supabase)](https://supabase.com)
[![Framework: Vite](https://img.shields.io/badge/Framework-Vite-646CFF?style=flat-square&logo=vite)](https://vitejs.dev)

O **Conheça Farmácia** é uma plataforma dedicada a promover o papel clínico do farmacêutico no ecossistema de saúde. Este projeto integra uma gestão robusta de inscrições em eventos científicos e um catálogo de artigos técnicos, focado na integridade dos dados e na experiência do profissional de saúde.

---

## 🚀 Visão Geral

Este WebApp foi construído sob o paradigma **"Security-First"**, garantindo que informações sensíveis de profissionais (como nomes, e-mails e registos) sejam tratadas com os mais altos padrões de proteção moderna.

### Funcionalidades Principais

- 📰 **Catálogo de Artigos**: Conteúdo técnico em Markdown com renderização segura (DOMPurify)
- 🎓 **Gestão de Eventos**: Inscrições em workshops, palestras e congressos com sincronização de vagas
- 🔐 **Proteção de Dados**: Validação em duas camadas (frontend + Edge Function backend)
- 📧 **Email Transacional**: Confirmações automáticas via Resend
- 🛡️ **Anti-Spam**: Honeypots invisíveis + rate limiting (5s frontend, 5/60s backend)
- 🔄 **Sincronização Real-Time**: Vagas atualizam diretamente do Supabase

---

## 🛠️ Stack Tecnológica

| Componente | Tecnologia | Propósito |
|-----------|-----------|----------|
| **Frontend** | HTML5, TailwindCSS, JavaScript (ES6+) | Interface e lógica de cliente |
| **Bundler** | Vite.js | Performance otimizada e HMR |
| **Backend** | Supabase (PostgreSQL, Auth, Edge Functions) | Banco de dados e API serverless |
| **Segurança** | DOMPurify | Sanitização de XSS |
| **Email** | Resend | Transações de email |
| **Deployment** | Netlify | Hospedagem estática e CI/CD |

---

## 🛡️ Arquitetura de Segurança (O Diferencial)

O projeto foi submetido a auditorias de segurança (Red Team) para implementar:

### 1. **Default Deny (RLS — Row Level Security)**
Todas as tabelas no Supabase utilizam *Row Level Security*. Utilizadores anónimos têm permissão estrita apenas para `INSERT` em tabelas específicas:
```sql
-- Exemplo: Tabela inscricoes
CREATE POLICY "allow_insert_inscricoes" 
  ON inscricoes FOR INSERT 
  WITH CHECK (
    length(nome) <= 255 AND 
    length(email) <= 255 AND 
    length(telefone) <= 20
  );
```

### 2. **Sanitização Universal**
Implementação de `DOMPurify` para limpar qualquer conteúdo Markdown/HTML antes da renderização, prevenindo ataques de *Cross-Site Scripting* (XSS):
```javascript
const htmlContent = DOMPurify.sanitize(markedParsed, {
  ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br', 'h1', 'h2', 'a', 'img'],
  ALLOWED_ATTR: ['href', 'src', 'alt', 'title']
});
```

### 3. **Isolamento de Segredos**
Chaves de API e URLs sensíveis são geridas exclusivamente via variáveis de ambiente (`.env`), nunca expostas no código fonte:
```javascript
// ❌ PROIBIDO
const ANON_KEY = "eyJhbGc..."; // Hardcoded

// ✅ CORRETO
const ANON_KEY = process.env.SUPABASE_ANON_KEY;
if (!ANON_KEY) throw new Error("Configure .env");
```

### 4. **Anti-Spam & Rate Limiting**
Proteção de formulários com múltiplas camadas:
- **Honeypot invisível**: Campo oculto que bots tentam preencher
- **Rate Limiting Frontend**: Máximo 1 inscrição a cada 5 segundos
- **Rate Limiting Backend**: Edge Function limita a 5 requests/IP/minuto

### 5. **Validação em Duas Camadas**

| Camada | Validação |
|--------|-----------|
| **Frontend** | Regex (email RFC 5322, telefone Angola/Intl), maxLength, whitelist |
| **Backend** | Edge Function revalida tudo + rate limiting + honeypot check |
| **Database** | RLS Policies + UNIQUE constraints |

### 6. **Mensagens de Erro Seguras**
Sem divulgação de informação técnica ao utilizador:
```javascript
// ❌ PROIBIDO
showError("Erro 23505: UNIQUE constraint violation");

// ✅ CORRETO
showError("Já tem uma inscrição neste evento. Se tem dúvidas, contacte-nos.");
```

---

## 📂 Estrutura de Pastas

```text
/conheca-farmacia
├── .github/                      # Workflows de CI/CD e automação
│   └── workflows/                # GitHub Actions (testes, deploy)
│
├── supabase/                     # Configurações de DB e Edge Functions
│   ├── migrations/               # Ficheiros DDL para schema
│   ├── functions/                # Edge Functions (validate-inscription, etc.)
│   └── seed.sql                  # Dados iniciais
│
├── src/                          # Código fonte principal
│   ├── assets/                   # Branding e recursos visuais
│   │   ├── content/              # Imagens de artigos e eventos
│   │   ├── icons/                # Ícones SVG
│   │   ├── images/               # Imagens gerais
│   │   └── logo/                 # Logos da marca
│   │
│   ├── content/                  # Catálogos JSON + Guidelines
│   │   ├── articles-catalog.json # Lista de artigos
│   │   ├── events-catalog.json   # Lista de eventos
│   │   ├── ARTICLE_GUIDELINES.md # Guia para criar artigos
│   │   └── EVENT_GUIDELINES.md   # Guia para criar eventos
│   │
│   ├── lib/                      # Configurações de SDKs
│   │   └── supabaseClient.js     # Cliente Supabase (SSR/Node.js)
│   │
│   └── scripts/                  # Lógica de negócio
│       ├── config.js             # Configuração Supabase (browser)
│       ├── inscription-logic.js  # Lógica de inscrição
│       ├── inscription-handler.js# Handler de botões
│       ├── articles-logic.js     # Renderização de artigos
│       ├── article-detail.js     # Detalhe de artigo individual
│       ├── events-logic.js       # Renderização de eventos
│       ├── event-detail.js       # Detalhe de evento individual
│       └── script.js             # Inicialização geral
│
├── .env.example                  # Template para variáveis de ambiente
├── .env.local                    # ⚠️ NUNCA commit (variáveis reais)
├── .gitignore                    # Proteção de ficheiros sensíveis
├── package.json                  # Dependências do projeto
├── vite.config.js                # Configuração Vite
│
├── index.html                    # Página inicial
├── artigos.html                  # Listagem de artigos
├── artigo.html                   # Detalhe de artigo
├── eventos.html                  # Listagem de eventos
├── evento.html                   # Detalhe de evento
├── inscricao.html                # Formulário de inscrição
├── sobre.html                    # Página "Sobre"
│
└── README.md                     # Esta documentação

```

---

## 🚀 Quick Start

### Pré-requisitos
- Node.js 16+ e npm
- Conta Supabase (https://supabase.com)
- GitHub para deployments

### 1. Clonar Repositório
```bash
git clone https://github.com/seu-user/conheca-farmacia.git
cd conheca-farmacia
```

### 2. Instalar Dependências
```bash
npm install
```

### 3. Configurar Variáveis de Ambiente
```bash
cp .env.example .env.local
# Editar .env.local com as credenciais do Supabase
```

### 4. Iniciar Servidor de Desenvolvimento
```bash
npm run dev
```

Abrir http://localhost:5173

---

## 📊 Tabelas Supabase

### `inscricoes`
Armazena inscrições em eventos. Campos:
- `id` (UUID, PK)
- `nome` (VARCHAR(255))
- `email` (VARCHAR(255))
- `telefone` (VARCHAR(20))
- `profissao` (VARCHAR(100))
- `origem_evento` (VARCHAR(100))
- `evento_slug` (VARCHAR(255), FK)
- `created_at` (TIMESTAMP)

**RLS Policies:**
- ✅ `INSERT`: Permitido (com validação)
- ❌ `SELECT`: Bloqueado para anónimos
- ❌ `UPDATE`: Bloqueado para anónimos
- ❌ `DELETE`: Bloqueado para anónimos

### `users` (Supabase Auth)
Utilizadores autenticados (admin, editors).

---

## 📝 Como Adicionar Novo Artigo

1. **Preparar imagem**: 900×600px (proporção 3:2)
2. **Guardar em**: `src/assets/content/articles/seu-artigo.png`
3. **Editar**: `src/content/articles-catalog.json`
```json
{
  "id": 10,
  "slug": "010-novo-artigo",
  "title": "Seu Título",
  "excerpt": "Resumo breve",
  "category": "profissionais",
  "categoryLabel": "Para Profissionais",
  "author": { "name": "Maria Lima", "role": "Farmacêutica", "avatar": "ML", "avatarBg": "#0a844f" },
  "date": "2026-04-19",
  "readTime": 8,
  "image": "assets/content/articles/seu-artigo.png",
  "content": "## Conteúdo em Markdown aqui..."
}
```
4. **Testar**: Abrir `artigos.html` e verificar renderização

📖 **Leia**: [content/ARTICLE_GUIDELINES.md](src/content/ARTICLE_GUIDELINES.md) para detalhes completos.

---

## 📅 Como Adicionar Novo Evento

1. **Preparar imagem**: 1280×720px (proporção 16:9)
2. **Guardar em**: `src/assets/content/articles/seu-evento.png`
3. **Editar**: `src/content/events-catalog.json`
```json
{
  "id": 11,
  "slug": "011-workshop-novo",
  "title": "Workshop: Seu Título",
  "excerpt": "Resumo breve",
  "category": "workshop",
  "categoryLabel": "Workshop",
  "date": "2026-05-20",
  "time": "09:00",
  "endTime": "13:00",
  "location": "Luanda, Angola",
  "type": "presencial",
  "capacity": 50,
  "registered": 0,
  "host": { "name": "João Pedro", "role": "Farmacêutico", "organization": "UNILA" },
  "image": "assets/content/articles/seu-evento.png",
  "registrationLink": "#"
}
```
4. **Testar**: Abrir `eventos.html` e verificar sincronização de vagas

📖 **Leia**: [content/EVENT_GUIDELINES.md](src/content/EVENT_GUIDELINES.md) para detalhes completos.

---

## 🧪 Testes de Segurança

### Validação do Formulário
```bash
# Teste com dados malicioso (ex: <script>alert('XSS')</script>)
# Sistema deve:
# 1. ✅ Sanitizar no frontend
# 2. ✅ Rejeitar no Edge Function
# 3. ✅ Bloquear no RLS (se passar)
```

### Rate Limiting
```bash
# Submeter 6 inscrições em rápida sucessão
# Frontend: Bloqueia após 1 submissão (5s cooldown)
# Backend: Bloqueia após 5 submissões/minuto (429 Too Many Requests)
```

### Proteção contra Duplicatas
```bash
# Inscrever-se 2x com o mesmo email no mesmo evento
# Sistema deve: "Já tem uma inscrição neste evento"
```

---

## 🔍 Auditorias de Segurança

### Realizado
- ✅ Análise de XSS em renderização Markdown
- ✅ Validação de RLS Policies (Supabase)
- ✅ Rate limiting (frontend + backend)
- ✅ Proteção contra inscrições duplicadas
- ✅ Remoção de console.log verbosos (information disclosure)
- ✅ Mensagens de erro genéricas (sem stack traces)
- ✅ Sanitização com DOMPurify (whitelist de tags)

### Recomendações Futuras
- 🔜 Implementar CAPTCHA para formulários públicos
- 🔜 Audit logs para rastreabilidade de modificações
- 🔜 Integração com WAF (Web Application Firewall)
- 🔜 Penetration testing anual

---

## 📧 Contacto & Suporte

- **Email**: conhecerfarmacia@gmail.com
- **Issues**: https://github.com/seu-user/conheca-farmacia/issues
- **Documentação**: Consulte as Guidelines em `src/content/`

---

## 📄 Licença

Este projeto é distribuído sob a licença MIT. Veja `LICENSE` para detalhes.

---

**Desenvolvido com ❤️ para promover a excelência clínica farmacêutica.**
