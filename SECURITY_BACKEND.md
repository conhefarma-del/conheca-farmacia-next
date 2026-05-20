# Seguranca Backend — O Sentinela

> Diretrizes para edicao de **migracoes SQL, camada de Service (api.js), configuracao Supabase**.
> Consultar ANTES de criar ou editar ficheiros SQL ou a camada de dados.
> Auditoria completa: 32 vulnerabilidades corrigidas (2026-05-19).

---

## API Layer (src/lib/api.js)

### SEC-API-01 — Normalizacao camelCase
A funcao de resposta deve converter dados do backend para camelCase padronizado.

```javascript
export function normalizeArticle(row) {
  return {
    id: row.id || row.slug,
    slug: row.slug,
    title: row.title,
    excerpt: row.excerpt,
    image: row.image_url,
  };
}
```

### SEC-API-02 — Delete com Verificacao de Sessao
Todas as funcoes de eliminacao devem verificar sessao antes de executar.

```javascript
export async function deleteArticle(id) {
  const { data: { session } } = await supabaseClient.auth.getSession();
  if (!session) throw new Error('Unauthorized: login required');
  const { error } = await supabaseClient.from('articles').delete().eq('id', id);
  if (error) throw error;
}
```

### SEC-API-03 — SELECT Explicito sem Colunas Sensiveis
Tabelas com campos sensiveis devem usar select explicito.

```javascript
// PROIBIDO:
select('*').from('lives').eq('status', 'published')

// CORRETO:
select('id, slug, title, excerpt, category, date, time, platform, status')
  .from('lives').eq('status', 'published')
```

### SEC-API-04 — Cliente Supabase Centralizado
Nunca criar clientes duplicados com fallback hardcoded.

```javascript
// PROIBIDO:
import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
const supabase = createClient(url, key);

// CORRETO:
import { supabaseClient } from '../config.js';
```

---

## Row Level Security (RLS)

### SEC-SQL-01 — Nunca USING (true) para Dados Pessoais
Tabelas com dados pessoais devem restringir SELECT a admins.

```sql
-- PROIBIDO:
CREATE POLICY "public_select" ON inscricoes
  FOR SELECT USING (true);

-- CORRETO:
CREATE POLICY "Admins can read inscricoes" ON inscricoes
  FOR SELECT
  USING (EXISTS (SELECT 1 FROM admin_users WHERE admin_users.user_id = auth.uid()));
```

**Tabela de politicas corretas:**

| Tabela | INSERT | SELECT | UPDATE | DELETE |
|--------|--------|--------|--------|--------|
| articles | Admin | Public(published) + Admin | Admin | Admin |
| events | Admin | Public(published) + Admin | Admin | Admin |
| lives | Admin | Public(published) + Admin | Admin | Admin |
| inscricoes | Anon(validado) | Admin only | Nenhuma | Nenhuma |
| admin_users | Nenhuma | Admin only | Proprio | Nenhuma |
| audit_logs | Admin | Proprios | Nenhuma | Nenhuma |
| newsletter | Nenhuma | Admin only | Nenhuma | Nenhuma |
| event_registrations | Nenhuma | Admin only | Nenhuma | Nenhuma |

---

## Funcoes RPC

### SEC-SQL-02 — SECURITY DEFINER com Validacao
Funcoes RPC devem validar input e so atualizar conteudo publicado.

```sql
CREATE FUNCTION increment_view_count(article_slug TEXT)
RETURNS VOID AS $$
BEGIN
  IF article_slug IS NULL OR length(trim(article_slug)) = 0 THEN
    RAISE EXCEPTION 'Invalid slug';
  END IF;
  UPDATE articles SET view_count = view_count + 1
    WHERE slug = article_slug AND status = 'published';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

**Todas as funcoes RPC devem:**
- Validar slug/row_id nao vazio
- Validar ranges numericos (ex: seconds entre 1 e 3600)
- Atualizar apenas `status = 'published'`
- Usar `SECURITY DEFINER` (nao INVOKER)

---

## Constraints

### SEC-SQL-03 — NOT NULL e CHECK
Colunas obrigatorias devem ter NOT NULL. Colunas com valores fixos devem ter CHECK.

```sql
-- NOT NULL em colunas obrigatorias
ALTER TABLE articles ALTER COLUMN status SET NOT NULL;

-- CHECK em colunas com valores fixos
ALTER TABLE admin_users ADD CONSTRAINT admin_users_role_check
  CHECK (role IN ('editor', 'admin', 'superadmin'));
```

---

## INSERT Anonimo

### SEC-SQL-04 — Validacao de Formato
Politicas de INSERT devem validar formato de email, telefone e slug.

```sql
CREATE POLICY "Allow valid inscricoes" ON inscricoes
  FOR INSERT
  WITH CHECK (
    nome IS NOT NULL AND length(nome) >= 3
    AND email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    AND telefone IS NOT NULL AND length(telefone) <= 20
    AND evento_slug ~* '^[a-zA-Z0-9\-_]+$'
  );
```

---

## Colunas de Auditoria

### SEC-AUD-01 — Metadados de Gestao
Todas as tabelas de dados publicos devem conter:

```sql
published_at TIMESTAMPTZ,
created_at TIMESTAMPTZ DEFAULT NOW(),
updated_at TIMESTAMPTZ DEFAULT NOW()
```

---

## Checklist Backend

- [ ] RLS sem `USING (true)` em dados pessoais? (SEC-SQL-01)
- [ ] RPC com `SECURITY DEFINER` e validacao? (SEC-SQL-02)
- [ ] NOT NULL em colunas obrigatorias? (SEC-SQL-03)
- [ ] CHECK em colunas com valores fixos? (SEC-SQL-03)
- [ ] INSERT anonimo com validacao de formato? (SEC-SQL-04)
- [ ] SELECT explicito sem colunas sensiveis? (SEC-API-03)
- [ ] Delete com verificacao de sessao? (SEC-API-02)
- [ ] Cliente Supabase centralizado? (SEC-API-04)
- [ ] Colunas de auditoria (published_at, created_at, updated_at)? (SEC-AUD-01)

---

## Matriz Normativa — Backend

| ID | Area | Descricao |
|----|------|-----------|
| SEC-API-01 | API | Normalizacao camelCase |
| SEC-API-02 | API | Delete com verificacao de sessao |
| SEC-API-03 | API | SELECT explicito sem colunas sensiveis |
| SEC-API-04 | API | Cliente Supabase centralizado |
| SEC-SQL-01 | SQL | RLS sem USING (true) em dados pessoais |
| SEC-SQL-02 | SQL | RPC SECURITY DEFINER com validacao |
| SEC-SQL-03 | SQL | NOT NULL + CHECK constraints |
| SEC-SQL-04 | SQL | INSERT com validacao de formato |
| SEC-AUD-01 | Auditoria | Colunas published_at, created_at, updated_at |

---

## Ficheiros de Referencia

| Ficheiro | Funcao |
|----------|--------|
| `src/lib/api.js` | Camada de Service — normalizacao, CRUD |
| `src/config.js` | supabaseClient (unico ponto de acesso) |
| `src/migrations/010-fix-rls-policies-security.sql` | Padrao RLS correto |
| `src/migrations/011-fix-rpc-functions-security.sql` | Padrao RPC correto |
| `src/migrations/012-add-constraints-security.sql` | CHECK e NOT NULL constraints |
