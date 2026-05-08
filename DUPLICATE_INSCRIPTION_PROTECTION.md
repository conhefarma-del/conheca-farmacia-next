# Proteção contra Inscrições Duplicadas

## 🔒 Como Funciona

A proteção contra inscrições duplicadas funciona em **duas camadas**:

### **1. Database (Supabase)**

- **UNIQUE Constraint:** `(email, evento_slug)`
- Impede inscrições duplicadas a nível de base de dados
- Garante integridade dos dados mesmo que o frontend seja contornado
- Error code: `23505` (duplicate key violation)

### **2. Frontend (Validação Prévia)**

- **Verificação antes de enviar:** Consulta a base de dados para ver se o email já está registado para o evento
- **Feedback imediato:** Mensagem clara ao utilizador
- **UX melhorada:** Evita requisições desnecessárias ao servidor

---

## 📊 Fluxo de Validação

```
Utilizador tenta inscrever-se
    ↓
Frontend valida campos (nome, email, telefone, etc)
    ↓
Frontend consulta: "Já existe inscrição com este email + evento?"
    ↓
┌──────────────────────────────────────┐
│ SIM - Já existe                      │
│ Mostrar: "Já está registado"         │
│ Blocar submissão ❌                   │
└──────────────────────────────────────┘
    │
    └──→ NÃO - Não existe
         Enviar para Supabase
             ↓
         Database valida constraint
         Se mesmo assim for duplicata → erro 23505
             ↓
         ✅ Inscrição guardada com sucesso
             ↓
         🔔 Trigger dispara email
```

---

## 🧪 Testando a Proteção

### Teste 1: Primeira Inscrição (Sucesso)

1. Abra: `http://127.0.0.1:5500/inscricao.html?evento=001-farmacologia-clinica`
2. Preencha:
   - Email: `teste@example.com`
   - Nome: `João Silva`
   - Telefone: `+244 925 696 002`
   - Profissão: Farmacêutico
   - Origem: Instagram
3. Clique "Confirmar Inscrição"
4. **Resultado:** ✅ Sucesso, email recebido

### Teste 2: Tentativa de Duplicata (Bloqueada)

1. **Mesma página, mesma URL**
2. Preencha **exatamente os mesmos dados**:
   - Email: `teste@example.com` (IGUAL)
   - Nome: `João Silva`
   - Telefone: `+244 925 696 002`
   - Profissão: Farmacêutico
   - Origem: Instagram
3. Clique "Confirmar Inscrição"
4. **Resultado esperado:**

   ```
   ❌ Erro: "Já está registado neste evento com este email.

   Se tem dúvidas, contacte-nos através de
   conhecerfarmacia@gmail.com ou +244 925 696 002"
   ```

### Teste 3: Mesmo Email, Evento Diferente (Permitido)

1. Abra: `http://127.0.0.1:5500/inscricao.html?evento=002-uso-racional-medicamentos`
2. Preencha:
   - Email: `teste@example.com` (IGUAL ao teste anterior)
   - Nome: `João Silva`
   - Telefone: `+244 925 696 002`
   - Profissão: Farmacêutico
   - Origem: Instagram
3. Clique "Confirmar Inscrição"
4. **Resultado esperado:** ✅ Sucesso (mesmo email em eventos diferentes é permitido)

### Teste 4: Email Diferente, Mesmo Evento (Permitido)

1. Abra: `http://127.0.0.1:5500/inscricao.html?evento=001-farmacologia-clinica`
2. Preencha:
   - Email: `outro@example.com` (DIFERENTE)
   - Nome: `Maria Santos`
   - Telefone: `+244 925 696 003`
   - Profissão: Enfermeiro
   - Origem: LinkedIn
3. Clique "Confirmar Inscrição"
4. **Resultado esperado:** ✅ Sucesso (emails diferentes no mesmo evento é permitido)

---

## 🔍 Console Logs (Debugging)

Abra DevTools (F12) → Console para ver logs:

**Quando verifica duplicata:**

```
🔍 Verificando inscrições existentes...
✓ Nenhuma inscrição duplicada encontrada

(ou)

⚠️ Inscrição duplicada encontrada: [{id: 123}]
❌ Tentativa de inscrição duplicada bloqueada
```

**Quando insere:**

```
🔗 Conectando ao Supabase...
📊 Status da resposta: 201
✅ Inscrição salva com sucesso!
```

---

## 📋 Resumo de Proteções

| Proteção              | Camada   | Tipo         | Resultado                 |
| --------------------- | -------- | ------------ | ------------------------- |
| Email + Evento UNIQUE | Database | Constraint   | Erro 23505 se duplicata   |
| Verificação previa    | Frontend | Query SELECT | Mensagem clara ao user    |
| Validação de campos   | Frontend | Regex        | Bloqueia dados inválidos  |
| RLS Policies          | Database | Segurança    | Controla acesso aos dados |
| Honeypot              | Frontend | Anti-spam    | Bloqueia bots             |

---

## 🚀 Comportamento Atual

✅ **Funcionando:**

- Primeira inscrição: Salva na base de dados ✓
- Email confirmação: Enviado automaticamente ✓
- Tentativa duplicata (mesmo email + evento): Bloqueada ✓
- Mesmo email em eventos diferentes: Permitido ✓
- Emails diferentes no mesmo evento: Permitido ✓

---

## 📞 Edge Cases

### E se o utilizador tentar contornar o frontend?

- A **Database Constraint** vai bloquear: erro 23505
- O frontend vai mostrar: "Já está registado"

### E se tiver múltiplos eventos?

- Um utilizador pode inscrever-se em quantos eventos quiser
- Apenas **uma inscrição por email por evento**

### E se mudar de email?

- Nova inscrição com novo email: ✅ Permitido
- A anterior mantém-se registada com o email antigo
