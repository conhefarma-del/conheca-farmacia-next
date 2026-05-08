# Debug: Sincronização de Inscrições

## Problema

O número de vagas disponíveis não está a ser atualizado após uma inscrição bem-sucedida.

## O que foi alterado

### 1. `src/event-detail.js`

- Adicionado logging detalhado na função `getInscriptionCount()`
- Adicionado fallback para REST API se o cliente Supabase falhar
- Adicionada função `debugInscriptions()` para debugging no console
- Melhoria no tratamento de erros RLS

### 2. `src/inscription-logic.js`

- Adicionado logging do `evento_slug` e email antes da inserção
- Logging detalhado dos dados inseridos no Supabase

### 3. `src/events-logic.js`

- Adicionada função `debugInscriptions()` para debugging no console

## Como Debugar

### Passo 1: Verificar se as inscrições estão a ser guardas

1. Abra o **Supabase Dashboard** → **Table Editor** → tabela `inscricoes`
2. Verifique se:
   - As inscrições estão a ser guardas
   - O campo `evento_slug` contém o valor correto (ex: `001-farmacologia-clinica`)
   - O campo `email` está correto

### Passo 2: Testar no Browser Console

1. Abra a página do evento: `evento.html?id=001-farmacologia-clinica`
2. Abra o **Console do Navegador** (F12)
3. Execute:
   ```javascript
   debugInscriptions("001-farmacologia-clinica");
   ```
4. Verifique:
   - Se o count retorna o número esperado
   - Se há erros de RLS (código 42501)
   - Se o SQL está correto

### Passo 3: Verificar Políticas RLS

No **Supabase SQL Editor**, execute:

```sql
-- Verificar políticas da tabela inscricoes
SELECT * FROM pg_policies WHERE tablename = 'inscricoes';

-- Testar leitura direta
SELECT count(*) FROM inscricoes WHERE evento_slug = '001-farmacologia-clinica';

-- Verificar se há inscrições com slug diferente
SELECT evento_slug, count(*) FROM inscricoes GROUP BY evento_slug;
```

### Passo 4: Testar Inscrição

1. Abra `inscricao.html?evento=001-farmacologia-clinica`
2. Preencha o formulário com dados válidos
3. No console, verifique:
   ```
   📤 DADOS INSERÇÃO: {...}
   🔍 evento_slug: 001-farmacologia-clinica
   ✅ Inscrição salva com sucesso!
   ```
4. Volte para `evento.html?id=001-farmacologia-clinica`
5. Verifique se o número de vagas atualizou

### Passo 5: Verificar Logs no Evento

No console da página do evento, procure por:

```
🔍 Contando inscrições para: "001-farmacologia-clinica"
🔗 SUPABASE_URL: https://...
📡 A usar cliente Supabase...
📊 Tabela: inscricoes, Filtro: evento_slug = "001-farmacologia-clinica"
✅ Inscrições encontradas (Supabase): X
```

## Probleas Comuns

### 1. Erro RLS (42501)

**Sintoma:** `error.code === '42501'`

**Solução:** Criar política de leitura no Supabase:

```sql
CREATE POLICY "Permitir leitura de inscrições" ON inscricoes
FOR SELECT USING (true);
```

### 2. Slug Diferente no Banco

**Sintoma:** Query retorna 0 mas há inscrições

**Solução:** Verificar se o `evento_slug` no banco bate com o JSON:

```sql
SELECT DISTINCT evento_slug FROM inscricoes;
```

### 3. Cache do Navegador

**Sintoma:** Dados desatualizados

**Solução:**

- Hard refresh (Ctrl+Shift+R)
- Verificar se polling está a funcionar (30s)
- Testar em aba anônima

### 4. CORS ou Network Error

**Sintoma:** Erros de rede no console

**Solução:**

- Verificar se URL do Supabase está correta
- Verificar se API está acessível
- Testar em outra rede

## Funções de Debug Disponíveis

### `debugInscriptions(slug)`

Disponível em `evento.html` e `eventos.html`:

```javascript
// Na página do evento
debugInscriptions(); // Usa o slug da URL

// Slug específico
debugInscriptions("001-farmacologia-clinica");
```

## Próximos Passos

1. **Confirmar dados no banco** - O usuário deve verificar no Supabase Dashboard
2. **Testar query diretamente** - Usar SQL Editor no Supabase
3. **Verificar RLS** - Confirmar políticas de leitura
4. **Testar inscrição** - Fazer uma inscrição e ver logs
