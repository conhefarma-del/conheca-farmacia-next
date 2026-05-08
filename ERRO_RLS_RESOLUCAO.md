# Guia Completo: Erros RLS e Sua Resolução

## 🎯 Resumo Executivo

Três erros principais ocorreram durante as inscrições, cada um com causa raiz distinta:

| Erro                   | Código     | Causa                                          | Solução                                                |
| ---------------------- | ---------- | ---------------------------------------------- | ------------------------------------------------------ |
| RLS Violation          | 42501      | Políticas de RLS não aplicadas ao papel `anon` | Recriar políticas com `TO anon`                        |
| Unique Constraint      | 23505      | Email duplicado no mesmo evento                | Adicionar verificação de duplicata no cliente e server |
| insertedData undefined | JavaScript | Destructuring incompleto na resposta           | Usar biblioteca oficial Supabase                       |

---

## ❌ ERRO 1: RLS Violation (42501)

### 📍 Quando Ocorreu

- Primeira tentativa de inscrição com novo email
- Erro: `new row violates row-level security policy for table "inscricoes"`

### 🔍 Diagnostico Passo-a-Passo

#### 1. Verificar se RLS está ativado

```bash
# Executar no Supabase Dashboard > SQL Editor
SELECT tablename, rowsecurity
FROM pg_tables
WHERE tablename = 'inscricoes';
```

**Resultado esperado:** `rowsecurity = true`

#### 2. Verificar políticas existentes

```bash
SELECT policyname, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'inscricoes';
```

**O que procurar:**

- ✅ Política de INSERT existe?
- ✅ Está aplicada ao papel correto (anon/authenticated)?
- ✅ Permissão (WITH CHECK) está correta?

#### 3. Verificar grants (permissões)

```bash
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public' AND table_name = 'inscricoes';
```

**Procurar por:** `anon` com `INSERT` privilege

### 🐛 Causa Raiz

**Problema 1: Políticas aplicadas ao papel errado**

```sql
-- ❌ ERRADO - Aplicada ao "public"
CREATE POLICY "allow_insert" ON inscricoes
FOR INSERT WITH CHECK (true);
-- Roles: {public}

-- ✅ CORRETO - Aplicada ao "anon"
CREATE POLICY "allow_anon_insert" ON inscricoes
FOR INSERT TO anon
WITH CHECK (true);
-- Roles: {anon}
```

**Motivo:**

- Quando usa `VITE_SUPABASE_ANON_KEY`, você está autenticado como papel `anon`
- A política precisa ser específica para esse papel
- Sem `TO anon`, a política é aplicada ao papel padrão `public`

**Problema 2: Políticas duplicadas interferindo**

- Havia múltiplas políticas para a mesma ação
- Postgres executa TODAS as políticas permissivas
- Se uma falha, a requisição é rejeitada

### ✅ Solução

**Passo 1: Remover políticas antigas/duplicadas**

```sql
DROP POLICY IF EXISTS "Permitir inscrições de qualquer um" ON inscricoes;
DROP POLICY IF EXISTS "Permitir leitura para autenticados" ON inscricoes;
DROP POLICY IF EXISTS "allow_public_insert" ON inscricoes;
DROP POLICY IF EXISTS "admin_select_all" ON inscricoes;
DROP POLICY IF EXISTS "public_insert_only" ON inscricoes;
```

**Passo 2: Recriar políticas com papel correto**

```sql
-- POLÍTICA 1: INSERT para usuários não autenticados (anon)
CREATE POLICY "allow_anon_insert" ON inscricoes
FOR INSERT
TO anon
WITH CHECK (true);

-- POLÍTICA 2: SELECT para admin (authenticated)
CREATE POLICY "allow_authenticated_read" ON inscricoes
FOR SELECT
TO authenticated
USING ((SELECT auth.role()) = 'authenticated');
```

**Passo 3: Verificar resultado**

```sql
SELECT policyname, roles, cmd
FROM pg_policies
WHERE tablename = 'inscricoes'
ORDER BY policyname;
```

**Resultado esperado:**

```
policyname                  | roles            | cmd
allow_anon_insert          | {anon}           | INSERT
allow_authenticated_read    | {authenticated}  | SELECT
```

**Passo 4: Testar no SQL Editor**

```sql
-- Simular INSERT como anon
SET ROLE anon;
INSERT INTO inscricoes (nome, email, telefone, profissao, origem_evento, evento_slug)
VALUES ('Teste', 'teste@example.com', '925696002', 'farmaceutico', 'instagram', 'evento-slug');
RESET ROLE;

-- Verificar se foi inserido
SELECT * FROM inscricoes WHERE email = 'teste@example.com';
```

---

## ❌ ERRO 2: Unique Constraint Violation (23505)

### 📍 Quando Ocorreu

- Tentativa de inscrição com email previamente registado no mesmo evento
- Erro: `Já tem uma inscrição neste evento com este endereço de email`

### 🔍 Diagnostico

#### 1. Identificar a constraint

```sql
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public' AND table_name = 'inscricoes';
```

**Procurar por:** `UNIQUE` constraints

#### 2. Ver quais colunas fazem parte da constraint

```sql
SELECT column_name
FROM information_schema.constraint_column_usage
WHERE constraint_schema = 'public'
  AND constraint_name = 'unique_email_evento';
```

**Resultado:** `email`, `evento_slug`

### 🐛 Causa Raiz

**Problema:** A constraint `unique_email_evento` impede duplicatas

- Combinação (email + evento_slug) deve ser única
- Quando inscreve-se 2x com mesmo email no mesmo evento, viola constraint
- PostgreSQL retorna erro 23505 (integrity constraint violation)

**Por que precisava ser tratado?**

- Erro 23505 é genérico - não diferencia a causa no cliente
- Usuário pode tentar inscrever-se novamente sem saber que já está registado
- Precisa feedback claro ANTES de tentar inserir

### ✅ Solução

**Estratégia 1: Verificação no Cliente (Frontend)**

Adicionar função no `inscription-logic.js`:

```javascript
// ==========================================
// CHECK FOR DUPLICATES: Verificar inscrição duplicada
// ==========================================
async function checkForDuplicateInscription(email, eventoSlug) {
  try {
    console.log(
      `🔍 Verificando inscrição duplicada para ${email} no evento ${eventoSlug}...`
    );

    const { data: existingInscriptions, error } = await window.supabase
      .from("inscricoes")
      .select("id", { count: "exact" })
      .eq("email", email)
      .eq("evento_slug", eventoSlug);

    if (error) {
      console.warn("⚠️ Erro ao verificar duplicata:", error);
      return false; // Não falhar silenciosamente
    }

    if (existingInscriptions && existingInscriptions.length > 0) {
      console.warn("⚠️ Inscrição duplicada detectada");
      return true; // Existe duplicata
    }

    console.log("✅ Nenhuma inscrição duplicada encontrada");
    return false;
  } catch (error) {
    console.error("❌ Erro ao verificar duplicata:", error);
    return false;
  }
}
```

**Onde usar no formulário:**

```javascript
// ANTES de tentar INSERT
const isDuplicate = await checkForDuplicateInscription(
  data.email,
  data.evento_slug
);
if (isDuplicate) {
  throw new Error(
    "Já tem uma inscrição neste evento com este endereço de email."
  );
}

// SÓ DEPOIS tentar INSERT
const { data: insertedData, error } = await window.supabase
  .from("inscricoes")
  .insert([data]);
```

**Estratégia 2: Verificação no Servidor (Edge Function)**

Na `validate-inscription` Edge Function, adicionar:

```typescript
// ==========================================
// VERIFICAR DUPLICATAS USANDO SUPABASE
// ==========================================
const supabaseUrl = Deno.env.get("SUPABASE_URL");
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

if (supabaseUrl && supabaseServiceKey) {
  const supabase = createClient(supabaseUrl, supabaseServiceKey);

  const { data: existingInscriptions, error: queryError } = await supabase
    .from("inscricoes")
    .select("id")
    .eq("email", email)
    .eq("evento_slug", evento_slug)
    .limit(1);

  if (!queryError && existingInscriptions && existingInscriptions.length > 0) {
    console.warn(`⚠️ Inscrição duplicada: ${email} no evento ${evento_slug}`);
    return new Response(
      JSON.stringify({
        error: "Já está registado neste evento com este email",
      }),
      {
        status: 409, // Conflict
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
}
```

**Por que 2 verificações?**

1. **Cliente:** Feedback imediato, melhor UX
2. **Servidor:** Segurança contra requisições diretas/manipuladas

---

## ❌ ERRO 3: insertedData is not defined

### 📍 Quando Ocorreu

- Após usar biblioteca oficial Supabase
- Erro: `insertedData is not defined`

### 🐛 Causa Raiz

**Problema:** Destructuring incompleto

```javascript
// ❌ ERRADO - Só pega o error
const { error } = await window.supabase.from("inscricoes").insert([data]);

// Depois tenta usar insertedData que nunca foi definida
console.log(insertedData); // ❌ ReferenceError
```

**Por que aconteceu?**

- Alterou o `config.js` para usar biblioteca oficial
- Esqueceu de atualizar o destructuring
- A biblioteca retorna `{ data, error }`

### ✅ Solução

**Corrigir destructuring:**

```javascript
// ✅ CORRETO - Pega data E error
const { data: insertedData, error } = await window.supabase
  .from("inscricoes")
  .insert([data]);

// Agora insertedData está disponível
console.log(insertedData); // ✅ Funciona
```

---

## 🔧 Evolução da Solução Técnica

### Versão 1: Cliente Customizado (Problema)

```javascript
// config.js - Cliente REST manual
const supabaseClient = {
  from(tableName) {
    return {
      insert: async (data) => {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/${tableName}`, {
          method: "POST",
          headers: {
            /* ... */
          },
          body: JSON.stringify(data),
        });
        // Tratamento manual de erros e headers
      },
    };
  },
};
```

**Problemas:**

- ❌ Sem suporte automático para RLS
- ❌ Headers podem estar incompletos
- ❌ Tratamento de erros manual e propenso a falhas
- ❌ Sem validação de JWT

### Versão 2: Biblioteca Oficial (Solução)

```javascript
// config.js - Biblioteca oficial
import { createClient } from "@supabase/supabase-js";

const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: false },
  realtime: { params: { eventsPerSecond: 10 } },
});
```

**Benefícios:**

- ✅ Suporte completo para RLS e JWT
- ✅ Tratamento automático de headers
- ✅ Validação de erros robusto
- ✅ Mantido e atualizado pela Supabase
- ✅ Debugging melhorado

---

## 📚 Checklist para Diagnosticar RLS no Futuro

Se receber erro **42501** novamente:

```
[ ] 1. RLS está ativado?
    SELECT rowsecurity FROM pg_tables WHERE tablename = 'tabela';

[ ] 2. Políticas existem?
    SELECT * FROM pg_policies WHERE tablename = 'tabela';

[ ] 3. Políticas aplicadas ao papel correto?
    - anon para INSERT (usuários públicos)
    - authenticated para SELECT/UPDATE/DELETE (admin)

[ ] 4. Permissões estão corretas?
    SELECT * FROM information_schema.role_table_grants
    WHERE table_name = 'tabela';

[ ] 5. Testar direto no SQL Editor como anon:
    SET ROLE anon;
    INSERT INTO tabela VALUES (...);
    RESET ROLE;

[ ] 6. Usar biblioteca oficial Supabase no cliente
    import { createClient } from '@supabase/supabase-js';

[ ] 7. Verificar console do navegador (F12) para logs detalhados
```

---

## 🚀 Boas Práticas para Evitar Esses Erros

### 1. RLS em Todas as Tabelas Públicas

```sql
-- SEMPRE fazer isso em tabelas públicas
ALTER TABLE tabela ENABLE ROW LEVEL SECURITY;

-- Criar políticas por papel, não por usuário
CREATE POLICY "anon_insert" ON tabela
FOR INSERT TO anon WITH CHECK (true);

CREATE POLICY "admin_select" ON tabela
FOR SELECT TO authenticated USING (true);
```

### 2. Usar Biblioteca Oficial

```javascript
// ✅ Sempre fazer isso
import { createClient } from "@supabase/supabase-js";

// ❌ Nunca fazer cliente manual
const client = {
  from: () => {
    /* ... */
  },
};
```

### 3. Validação em Dois Níveis

```javascript
// Nível 1: Cliente (UX)
const isDuplicate = await checkForDuplicate();
if (isDuplicate) throw new Error("Já registado");

// Nível 2: Servidor (Segurança)
// Edge Function também verifica
```

### 4. Logs Detalhados

```javascript
// Sempre logar erros completos
if (error) {
  console.error("Erro:", error.code, error.message);
  console.error("Detalhes:", error.details);
  console.error("Hint:", error.hint);
  console.error("Resposta completa:", error);
}
```

### 5. Testar Políticas Antes de Deploy

```sql
-- No SQL Editor, simular cada cenário
SET ROLE anon;
INSERT INTO tabela (...) VALUES (...); -- Deve funcionar

SET ROLE authenticated;
SELECT * FROM tabela; -- Deve funcionar

RESET ROLE;
```

---

## 📞 Próximos Passos em Caso de Problema Similar

1. **Verificar erro exato:**
   - 42501 = RLS Violation
   - 23505 = Unique Constraint
   - 403 = Auth Failed
   - 404 = Not Found

2. **Consultar Supabase Logs:**
   - Dashboard > Logs > API
   - Dashboard > Logs > Database
   - Console do Navegador (F12)

3. **Teste isolado:**

   ```sql
   -- Executar diretamente no SQL Editor do Supabase
   SET ROLE anon;
   INSERT INTO inscricoes (...) VALUES (...);
   ```

4. **Contactar Supabase Support:**
   - Com código do erro
   - Com logs completos
   - Com SQL que falha
