# Test Checklist - CMS Admin

## Authentication
- [ ] Login com email/password funciona
- [ ] Utilizador não-admin é rejeitado
- [ ] Logout funciona
- [ ] Sessão expira corretamente

## Artigos
- [ ] Listar artigos (todos, publicados, rascunho)
- [ ] Criar novo artigo
- [ ] Editar artigo existente
- [ ] Publicar/Despublicar artigo
- [ ] Excluir artigo
- [ ] Upload de imagem com compressão
- [ ] Preencher referências (array)
- [ ] Histórico de auditoria gravado

## Eventos
- [ ] Listar eventos
- [ ] Criar novo evento
- [ ] Editar evento
- [ ] Publicar/Despublicar evento
- [ ] Excluir evento

## Lives
- [ ] Listar lives
- [ ] Criar nova live
- [ ] Editar live
- [ ] Publicar/Despublicar live
- [ ] Excluir live

## Site Público
- [ ] Artigos.html mostra apenas publicados
- [ ] Artigo.html carrega conteúdo correto
- [ ] Eventos.html mostra apenas publicados
- [ ] Lives.html mostra apenas publicadas
- [ ] Fallback para JSON funciona se Supabase falhar

## Audit Logs
- [ ] Todas ações gravadas na tabela audit_logs
- [ ] Dashboard mostra atividade recente
- [ ] Utilizador correto registado

## Database Migration
- [ ] 001-create-tables.sql aplicado
- [ ] 002-create-audit-logs.sql aplicado
- [ ] 003-create-rls-policies.sql aplicado
- [ ] Backups criados em src/migrations/
- [ ] Dados migrados para Supabase

## Setup
- [ ] Utilizadores admin criados no Supabase Auth
- [ ] Tabela admin_users populada
- [ ] Storage buckets criados (article-images, event-images, live-images)
- [ ] RLS policies ativas

## Como Testar

### 1. Local Development
```bash
npm run dev
# Aceder a http://localhost:5173/src/admin/index.html
```

### 2. Supabase Setup
```bash
# No Supabase Dashboard:
# 1. SQL Editor → Aplicar migrations
# 2. Authentication → Users → Adicionar utilizadores
# 3. Database → admin_users → Inserir admins
# 4. Storage → Criar buckets
```

### 3. Migration
```bash
# Correr script de migração no browser:
import { runMigration } from './src/migrations/migrate-json-to-supabase.js';
await runMigration();
```
