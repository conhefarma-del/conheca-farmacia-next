# Admin CMS - Conheça Farmácia

## Visão Geral

Painel administrativo para gerir conteúdo do site (artigos, eventos, lives).

## Acesso

- URL: `/src/admin/index.html`
- Autenticação: Supabase Auth
- Apenas utilizadores na tabela `admin_users` podem aceder

## Estrutura

```
src/admin/
├── index.html              # Página de login
├── dashboard.html          # Dashboard com stats
├── artigos/
│   ├── index.html          # Lista de artigos
│   ├── new.html            # Criar artigo
│   └── edit.html           # Editar artigo
├── eventos/
│   ├── index.html          # Lista de eventos
│   ├── new.html            # Criar evento
│   └── edit.html           # Editar evento
├── lives/
│   ├── index.html          # Lista de lives
│   ├── new.html            # Criar live
│   └── edit.html           # Editar live
├── styles/
│   └── admin.css           # CSS exclusivo do admin
├── lib/
│   ├── auth.js             # Autenticação Supabase Auth
│   ├── image-compressor.js # Compressão de imagens
│   └── audit-logger.js     # Logging de ações
├── admin-articles.js       # CRUD artigos
├── admin-events.js         # CRUD eventos
└── admin-lives.js          # CRUD lives
```

## Funcionalidades

### Artigos
- Criar, editar, publicar, excluir artigos
- Upload de imagens com compressão automática
- Workflow Rascunho → Publicado
- Referências bibliográficas

### Eventos
- Gerir eventos futuros
- Capacidade e inscrições
- Múltiplos anfitriões

### Lives
- Gerir transmissões ao vivo
- Links de acesso
- Materiais de apoio

## Audit Logs

Todas as ações são registadas na tabela `audit_logs`:
- CREATE, UPDATE, DELETE, PUBLISH, UNPUBLISH
- Utilizador, data/hora, valores anteriores e novos

## Migração de Dados

Para migrar de/para JSON:

```bash
# Backup (já feito)
src/migrations/backup-articles.json
src/migrations/backup-events.json
src/migrations/backup-lives.json

# Restaurar (se necessário)
# Ver script de migration
```

## Segurança

- RLS (Row Level Security) ativo em todas as tabelas
- Apenas admins podem criar/editar conteúdo
- Público lê apenas conteúdo publicado
- Senhas guardadas no Supabase Auth

## CSS

O CSS do admin é independente do site público:
- Carregado apenas nas páginas do admin
- Não afeta o site público
- Variáveis CSS para cores consistentes
