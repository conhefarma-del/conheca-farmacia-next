# Guia de Resolução - Inscrições não aparecem no Supabase

## 🧪 Passo 1: Executar Diagnóstico

1. Abra `http://127.0.0.1:5500/diagnostico.html`
2. Clique em **"Iniciar Testes"**
3. Verifique os resultados

---

## ❌ Se o diagnóstico falhar:

### Erro: "Tabela 'inscricoes' não encontrada"

**Solução:**
1. Aceda a [Supabase Dashboard](https://app.supabase.com/project/tbqsazriorqzexjwhekw)
2. Vá para **SQL Editor**
3. Copie todo o conteúdo de `SUPABASE_MIGRATION.sql`
4. Cole no SQL Editor
5. Clique em **Run**
6. Execute o diagnóstico novamente

---

### Erro: "RLS Policy error" ou "Política de segurança"

**Solução:**

O script SQL já cria as políticas corretas, mas verifique:

1. Aceda a Supabase Dashboard → **Authentication → Policies**
2. Procure pela tabela `inscricoes`
3. Deve haver 2 políticas:
   - ✅ **INSERT** - "Permitir inscrições de qualquer um"
   - ✅ **SELECT** - "Permitir leitura para autenticados"

Se não estiverem, execute:
```sql
-- Recrear políticas
DROP POLICY IF EXISTS "Permitir inscrições de qualquer um" ON inscricoes;
DROP POLICY IF EXISTS "Permitir leitura para autenticados" ON inscricoes;

CREATE POLICY "Permitir inscrições de qualquer um" ON inscricoes
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Permitir leitura para autenticados" ON inscricoes
  FOR SELECT
  USING (auth.role() = 'authenticated');
```

---

### Erro: "Chave ANON_KEY inválida"

**Solução:**

1. Verifique o arquivo `.env`:
   ```
   SUPABASE_URL=https://tbqsazriorqzexjwhekw.supabase.co
   SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

2. Compare com `config.js`:
   ```javascript
   const SUPABASE_CONFIG = {
       url: 'https://tbqsazriorqzexjwhekw.supabase.co',
       anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
   };
   ```

3. Se forem diferentes, atualize `config.js` com os valores corretos

---

## ✅ Se o diagnóstico passar:

1. Feche o diagnóstico
2. Tente inscrever-se em um evento real
3. Abra o console do navegador (**F12** → **Console**)
4. Procure por mensagens azuis (✅) indicando sucesso

---

## 🔍 Como verificar no Supabase

### Ver as inscrições:

1. Aceda a [Supabase Dashboard](https://app.supabase.com/project/tbqsazriorqzexjwhekw)
2. Vá para **Table Editor**
3. Procure pela tabela `inscricoes`
4. Deve listar todas as inscrições com:
   - ID
   - Nome
   - Email
   - Telefone
   - Profissão
   - Origem do evento
   - Evento slug
   - Data/hora de criação

---

## 📊 Console Debug

Abra **F12** (Developer Tools) e vá para **Console** para ver:

```
✅ Supabase library carregada
✅ Cliente Supabase inicializado
✓ Evento carregado: 001-farmacologia-clinica
📤 Iniciando submissão do formulário...
📋 Dados do formulário: {nome: "...", email: "...", ...}
🔗 Conectando ao Supabase...
✅ Inscrição salva com sucesso!
```

**Se vir mensagens de erro, copie-as e verifique a solução acima.**

---

## 🚀 Verificação Final

### Checklist:

- [ ] Tabela `inscricoes` criada no Supabase
- [ ] RLS ativado e políticas criadas
- [ ] Chaves `.env` corretas
- [ ] `config.js` atualizado
- [ ] Diagnostico passa todos os testes
- [ ] Console mostra mensagens de sucesso
- [ ] Dados aparecem na tabela Supabase

---

## 📞 Se ainda não funcionar:

1. **Verifique os logs no console (F12)**
2. **Tome uma screenshot do erro**
3. **Copie a URL do seu projeto Supabase**
4. **Execute o diagnóstico e copie o resultado**

---

## 💡 Troubleshooting Rápido

| Sintoma | Causa | Solução |
|---------|-------|---------|
| "Cannot read property 'from'" | Supabase não carregou | Aguarde 2-3 segundos |
| "Policy violation" | RLS incorreto | Recrie políticas |
| Inscrição salva mas sem dados | Formulário vazio | Valide campos required |
| Erro CORS | Problema de origem | Use HTTPS ou servidor |

---

## 🔄 Reset Completo (Se Nada Funcionar)

1. Aceda a Supabase → SQL Editor
2. Execute:
   ```sql
   DROP TABLE IF EXISTS inscricoes CASCADE;
   ```
3. Copie `SUPABASE_MIGRATION.sql` inteiro no SQL Editor
4. Clique Run
5. Execute o diagnóstico
