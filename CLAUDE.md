# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📋 Common Development Commands

### Development Server

```bash
# Start development server with hot-reload
npm run dev
# Opens at http://localhost:5173
```

### Production Build

```bash
# Build for production
npm run build
# Preview production build
npm run preview
```

### Code Formatting

```bash
# Format code with Prettier
npm run format
```

### Dependencies

```bash
# Install dependencies
npm install
```

## 🏗️ Project Architecture & Structure

### Core Technologies

- **Framework**: Vite (ES modules, hot module replacement)
- **Styling**: Tailwind CSS v4 (via `@tailwindcss/vite` plugin)
- **Backend**: Supabase (PostgreSQL, Auth, RLS, Edge Functions)
- **CMS**: Painel admin interno (src/admin/) para gerir artigos, eventos, lives
- **State Management**: Vanilla JavaScript (no framework)

### Key Directories & Files

```
├── index.html # Main HTML entry
├── main.js # Vite entry point
├── vite.config.js # Vite configuration
├── src/
│ ├── input.css # Tailwind CSS directives
│ ├── script.js # Global navigation, DOM utilities
│ ├── config.js # Supabase client (persistSession: true para admin)
│ ├── lib/
│ │ ├── api.js # API layer: getArticles(), getEvents(), getLives()
│ │ ├── fallback-data.js # Fallback para JSON local
│ │ ├── capacity-cache.js # Cache de capacidade (15s)
│ │ ├── polling.js # Polling de vagas (cleanup, visibility detection)
│ │ └── supabaseClient.js # Cliente Supabase partilhado
│ ├── admin/ # CMS Admin (gerir conteúdo)
│ │ ├── index.html # Login page
│ │ ├── dashboard.html # Stats e activity
│ │ ├── artigos/ # CRUD artigos
│ │ ├── eventos/ # CRUD eventos
│ │ ├── lives/ # CRUD lives
│ │ ├── lib/
│ │ │ ├── auth.js # Auth Supabase
│ │ │ ├── image-compressor.js # Compressão de imagens
│ │ │ └── audit-logger.js # Logging de ações
│ │ └── styles/ # CSS exclusivo do admin
│ ├── content/ # JSON catalogs (fallback)
│ │ ├── articles-catalog.json
│ │ ├── events-catalog.json
│ │ ├── lives-catalog.json
│ │ └── ARTICLE_GUIDELINES.md
│ ├── migrations/ # Backup e migrations de dados
│ └── detail-pages/
│     ├── article-detail.js # Renderização de artigo
│     ├── event-detail.js # Renderização de evento
│     └── live-detail.js # Renderização de live
├── public/ # Static assets
└── dist/ # Production build
```

### Data Flow (CMS + Supabase)

1. **Content Sources**: Supabase (primary) + JSON fallback (src/content/)
2. **API Layer**: `src/lib/api.js` normaliza dados (snake_case → camelCase)
3. **Rendering**: Detail pages usam `getEventBySlug()`, `getArticleBySlug()`, etc.
4. **Admin CMS**: Cria/edita conteúdo → Supabase → Site público (leitura)
5. **Fallback**: Se Supabase falhar, usa JSON local

### Supabase Integration

- **Configuration**: `src/config.js` (client-side), `src/lib/supabaseClient.js` (shared)
- **Tables**: `articles`, `events`, `lives`, `inscricoes`, `admin_users`, `audit_logs`
- **RLS**: Ativo em todas as tabelas (apenas admins escrevem, público lê publicado)
- **Edge Functions**: Validação de inscrições, email transacional
- **Auth**: Admins autenticados via Supabase Auth (persistSession: true obrigatório)

### Admin CMS

- **Acesso**: `/src/admin/index.html` — apenas utilizadores em `admin_users`
- **Funcionalidades**: CRUD completo para artigos, eventos, lives
- **Audit Logs**: Todas as ações registadas em `audit_logs`
- **Image Upload**: Compressão automática antes de upload para Supabase Storage

## ⚠️ Lições Aprendidas (Erros a Evitar)

### 1. Edição de Ficheiros JavaScript

**Problema**: Quando editar funções em ficheiros JS, garantir que:
- Todas as chaves de abertura têm correspondente de fecho
- Não deixar código incompleto no final do ficheiro
- Validar sintaxe com `node --check` antes de testar no browser

**Solução**: 
```bash
node --check src/event-detail.js  # Deve retornar vazio (sem erros)
```

### 2. Substituição de Funções em Ficheiros Existentes

**Problema**: Ao substituir funções inteiras, o padrão de busca pode não ser exato devido a:
- Diferenças de whitespace (espaços vs tabs)
- Linhas em branco a mais ou a menos
- Comentários adjacentes

**Solução**:
1. Ler o ficheiro completo primeiro
2. Identificar marcadores únicos (comentários JSDoc, assinaturas de função)
3. Usar Python para substituições complexas em vez de Edit tool
4. Validar com `node --check` após edição

### 3. Gerir Estado em Funções de Renderização

**Problema**: Adicionar botões "Show More/Show Less" requer:
- Referências a variáveis de estado (limite mobile/desktop)
- Event listeners que persistem após re-renderização
- Cuidado com resize handlers que podem quebrar estado

**Solução**:
- Evitar resize handlers que re-renderizam — pode quebrar estado de botões
- Se necessário, usar debounce e limpar estado antes de re-renderizar
- Manter referência a dados originais para re-renderização

### 4. Validação de Sintaxe Após Edição de Ficheiros JavaScript

**Problema**: Durante a implementação do botão "Show More" para palestrantes (2026-05-16), o ficheiro `src/event-detail.js` tinha um erro de sintaxe — faltava um fechamento `});` para o bloco `DOMContentLoaded`. O Vite falhava com erro `Expected '}' but found 'EOF'` e o build não compilava.

**Sintoma**: Erro no Vite: `[PARSE_ERROR] Error: Expected '}' but found 'EOF'` em `src/event-detail.js`

**Solução**:
1. Após qualquer edição em ficheiros JavaScript, validar sintaxe ANTES de testar no browser:
```bash
node --check src/event-detail.js  # Deve retornar vazio (sem erros)
```
2. Se houver erro, contar chaves `{` vs `}` para identificar blocos em falta:
```bash
python3 -c "content=open('src/event-detail.js').read(); print(f'Abertas: {content.count(\"{\")}, Fechadas: {content.count(\"}\")}')"
```
3. Adicionar fechamentos em falta no final do ficheiro
4. Validar novamente com `node --check`

**Prevenção**: Ao editar funções ou adicionar código, sempre:
- Contar blocos abertos vs fechados
- Validar sintaxe com `node --check` antes de fazer commit
- Verificar se `DOMContentLoaded` e `try/catch` estão devidamente fechados

### 5. Configuração de Auth para Admin

**Problema**: Ciclo infinito de login no admin se `persistSession: false`

**Solução**: `config.js` deve ter `persistSession: true` para admin CMS. Ver `memory:cms-admin-auth-fix.md`.

### 6. Edição de Ficheiros JavaScript - Adicionar Múltiplas Funções

**Problema**: Ao adicionar múltiplas funções num ficheiro JS, tentar usar Edit tool com strings longas pode falhar devido a:
- Diferenças de whitespace ou formatação
- Comments adjacentes não considerados
- Tamanho do padrão de busca muito longo

**Solução**:
1. Adicionar funções individualmente, uma de cada vez
2. Validar sintaxe com `node --check` após cada adição
3. Se Edit tool falhar, usar Python para adicionar código no final do ficheiro
4. Manter padrão de 2 espaços para indentação (consistente com o projeto)

**Prevenção**:
- Ler o ficheiro completo antes de editar
- Identificar o último bloco de código para saber onde adicionar
- Usar `wc -l` para verificar linha final do ficheiro

### 7. Edição de Ficheiros CSS - Especificidade e Variáveis

**Problema**: Ao adicionar CSS para novos componentes (ex: search results), é necessário:
- Usar variáveis CSS consistentes com o tema (ex: `var(--admin-text)`, `var(--admin-border)`)
- Manter especificidade adequada para sobrescrever estilos base
- Considerar dark mode (variáveis automáticas)

**Solução**:
1. Ler o CSS existente para identificar variáveis disponíveis
2. Adicionar novos estilos no final do ficheiro com comentário de secção
3. Testar em ambos os modos (claro/escuro) se aplicável

### 8. Import de Módulos em Ficheiros JavaScript

**Problema**: Ao criar novos módulos (ex: `search.js`), esquecer de:
- Exportar funções corretamente
- Importar dependências (ex: `supabaseClient`)
- Atualizar ficheiros que usam o módulo com o novo import

**Solução**:
1. Criar módulo com exportação nomeada: `export async function searchAllContent() {...}`
2. Importar dependências no topo: `import { supabaseClient } from '../config.js'`
3. Adicionar import nos ficheiros que usam: `import { searchAllContent } from '../lib/search.js'`
4. Validar sintaxe em todos os ficheiros modificados

### 9. Validação de Sintaxe em Cadeia

**Problema**: Múltiplos ficheiros JS modificados podem ter erros de sintaxe que só aparecem no runtime.

**Solução**:
Após editar múltiplos ficheiros JS, validar todos em sequência:
```bash
node --check src/lib/api.js
node --check src/lib/search.js
node --check src/admin/dashboard.js
```

**Prevenção**:
- Criar script de validação para rodar antes de commit
- Adicionar validação no pipeline de CI/CD se disponível

### 10. Edição de Ficheiros HTML - Estrutura e IDs

**Problema**: Ao modificar HTML, IDs de elementos (ex: `admin-search-input`) devem ser consistentes entre:
- HTML (onde o elemento é definido)
- JavaScript (onde o elemento é selecionado)
- CSS (onde o elemento é estilizado)

**Solução**:
1. Usar `grep` ou `Grep` tool para verificar consistência de IDs
2. Manter convenção de naming: `bloco-elemento-modificador` (ex: `admin-search-input`)
3. Validar que o elemento existe antes de adicionar funcionalidade JS

### 11. Criação de Ficheiros Novos

**Problema**: Criar ficheiros novos (ex: `search.js`) requer:
- Estrutura correta de módulo ES6
- exports nomeados para funções públicas
- imports corretos de dependências

**Solução**:
1. Usar Write tool para criar ficheiro com conteúdo completo
2. Validar sintaxe com `node --check`
3. Testar import noutro ficheiro para verificar exportação

### 12. Git - Lidar com Line Endings (CRLF vs LF)

**Problema**: No Windows, Git pode converter LF para CRLF, causando warnings:
```
warning: in the working copy of 'src/lib/api.js', LF will be replaced by CRLF
```

**Solução**:
1. Aceitar warning como normal no Windows (Git gerencia automaticamente)
2. Ou configurar repositório: `git config core.autocrlf true`
3. Não alterar line endings manualmente

### 13. Debounce em Event Listeners

**Problema**: Event listeners como `input` em search boxes disparam a cada caractere, causando:
- Múltiplas chamadas de API
- Performance degradada
- Rate limiting potencial

**Solução**:
```javascript
let debounceTimer;
searchInput.addEventListener('input', (e) => {
  clearTimeout(debounceTimer);
  debounceTimer = setTimeout(async () => {
    // Executar pesquisa
  }, 300); // 300ms de delay
});
```

### 14. XSS Protection em User Input

**Problema**: Mostrar conteúdo de pesquisa (títulos, nomes) pode injetar HTML malicioso.

**Solução**:
```javascript
function escapeHtml(text) {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
}
// Usar antes de inserir no DOM: escapeHtml(userInput)
```

### 15. Estrutura de Planos e Tasks

**Problema**: Planos de implementação (ex: `linear-fluttering-widget.md`) podem ter tasks desatualizadas ou funções já implementadas noutras versões.

**Solução**:
1. Ler ficheiro do plano para entender tasks
2. Verificar estado atual do código antes de implementar
3. Atualizar tasks com TaskCreate/TaskUpdate para tracking
4. Marcar tasks como completed quando terminado

### 16. Edição de Ficheiros JSON

**Problema**: Ficheiros JSON (ex: `package.json`, catalogs) são sensíveis a:
- Aspas duplas obrigatórias (não usar aspas simples)
- Comas trailing (último elemento não pode ter vírgula)
- Comentários não suportados (JSON não suporta `//` ou `/* */`)
- Indentação consistente (geralmente 2 espaços)

**Solução**:
1. Usar `JSON.parse()` para validar sintaxe antes de commit:
```bash
node -e "JSON.parse(require('fs').readFileSync('package.json'))"
```
2. Usar Prettier para formatar: `npm run format`
3. Validar no VSCode ou editor com linting JSON
4. Se necessário adicionar comentários, usar formato `.jsonc`

**Prevenção**:
- Nunca adicionar comentários em ficheiros JSON
- Verificar trailing commas antes de commit
- Usar `json` schema validation se disponível

### 17. Edição de Ficheiros Markdown (.md)

**Problema**: Ficheiros Markdown (ex: `CLAUDE.md`, `README.md`, `MEMORY.md`) podem ter:
- Links quebrados (caminhos incorretos)
- Formatação inconsistente (títulos, listas)
- Code blocks sem linguagem especificada

**Solução**:
1. Manter consistência com estilo existente
2. Usar `#` para títulos (não `## ` no início de linha)
3. Especificar linguagem em code blocks:
   ```markdown
   ```javascript
   // código aqui
   ```
   ```
4. Validar links com `grep` ou ferramenta online
5. Usar Prettier: `npm run format` formata Markdown também

**Prevenção**:
- Ler o ficheiro antes de editar para entender estrutura
- Manter mesmo estilo de formatação
- Links relativos: usar `/` para raiz do projeto

### 18. Edição de Ficheiros CSS - Estrutura e Especificidade

**Problema**: Ao adicionar CSS para novos componentes:
- Variáveis CSS podem não estar definidas no tema
- Especificidade pode não sobrescrever estilos existentes
- Dark mode pode não ser considerado

**Solução**:
1. Ler CSS existente para identificar variáveis (`var(--admin-*)`)
2. Adicionar comentários de secção para organização:
   ```css
   /* =============================================
      SEARCH RESULTS STYLES
      ============================================= */
   ```
3. Testar em ambos modos (claro/escuro)
4. Usar variáveis CSS para cores, espaçamentos, etc.

**Prevenção**:
- Manter dicionário de variáveis CSS disponíveis
- Seguir convenção de nomenclatura do projeto
- Verificar se existe utility class antes de criar CSS novo

### Important Notes

- **Development**: Must use `npm run dev` — direct file:// opening fails (ES modules)
- **CSS Injection**: Tailwind CSS injected via JavaScript during Vite dev
- **Routing**: Client-side via hash/fragment + programmatic navigation
- **Security**: DOMPurify for Markdown; RLS policies; no secrets in frontend
- **Admin Auth**: `persistSession: true` obrigatório em `config.js` para admin
