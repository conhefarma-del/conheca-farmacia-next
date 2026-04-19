# Guia de Validação de Formulário de Inscrição

## ✅ Validações Implementadas

### 1. **Nome Completo**
- ✓ Obrigatório
- ✓ Mínimo 3 caracteres
- ✓ Feedback: "Nome deve ter pelo menos 3 caracteres"

### 2. **Email**
- ✓ Obrigatório
- ✓ Formato válido (regex: `^[^\s@]+@[^\s@]+\.[^\s@]+$`)
- ✓ Feedback: "Email inválido"

### 3. **Telefone**
- ✓ Obrigatório
- ✓ Formato válido:
  - Começa com +244 OU 244 OU apenas número
  - Deve ter 9 dígitos após o prefixo
  - Exemplos válidos:
    - `+244 925 696 002`
    - `244925696002`
    - `925 696 002`
- ✓ Feedback: "Telefone deve ser um número válido (+244 925 696 002 ou 925 696 002)"

### 4. **Profissão**
- ✓ Obrigatório
- ✓ Deve selecionar uma opção
- ✓ Feedback: "Selecione uma profissão"

### 5. **Como ouviu sobre o evento**
- ✓ Obrigatório
- ✓ Deve selecionar uma opção
- ✓ Feedback: "Selecione como ouviu sobre este evento"

### 6. **Honeypot (Anti-spam)**
- ✓ Campo oculto que não deve ser preenchido
- ✓ Bloqueia bots que preenchem campos ocultos

---

## 🧪 Testando o Formulário

### Teste 1: Submissão Válida
1. Abra: `http://127.0.0.1:5500/inscricao.html?evento=001-farmacologia-clinica`
2. Preencha:
   - Nome: "João Silva" (mínimo 3 caracteres)
   - Email: "joao@example.com" (formato válido)
   - Telefone: "+244 925 696 002" (formato válido)
   - Profissão: "Farmacêutico"
   - Como ouviu: "Instagram"
3. Clique em "Confirmar Inscrição"
4. **Resultado esperado:** Mensagem de sucesso com confirmação de email

### Teste 2: Validação - Nome curto
1. Preencha Nome: "Jo" (menos de 3 caracteres)
2. Clique em "Confirmar Inscrição"
3. **Resultado esperado:** Erro: "Nome deve ter pelo menos 3 caracteres"

### Teste 3: Validação - Email inválido
1. Preencha Email: "email-invalido" (sem @)
2. Clique em "Confirmar Inscrição"
3. **Resultado esperado:** Erro: "Email inválido"

### Teste 4: Validação - Telefone inválido
1. Preencha Telefone: "123456" (menos de 9 dígitos)
2. Clique em "Confirmar Inscrição"
3. **Resultado esperado:** Erro: "Telefone deve ser um número válido..."

### Teste 5: Validação - Campos vazios
1. Deixe Profissão vazia (valor padrão)
2. Clique em "Confirmar Inscrição"
3. **Resultado esperado:** Erro: "Selecione uma profissão"

### Teste 6: Múltiplos erros
1. Preencha:
   - Nome: "Jo" (curto)
   - Email: "email-invalido"
   - Telefone: "123"
   - Deixe Profissão vazia
2. Clique em "Confirmar Inscrição"
3. **Resultado esperado:** Todos os erros listados:
   ```
   Por favor, corrija os seguintes erros:

   • Nome deve ter pelo menos 3 caracteres
   • Email inválido
   • Telefone deve ser um número válido...
   • Selecione uma profissão
   ```

---

## 🔄 Fluxo Completo

### 1. **Validação no Frontend**
- Quando submete: verifica todos os campos
- Se algum está inválido: mostra erro específico
- Não permite enviar para servidor

### 2. **Se Válido: Envia para Supabase**
- Desabilita botão (estado: "A processar...")
- Conecta ao Supabase via `config.js`
- Insere dados na tabela `inscricoes`

### 3. **Trigger Automático**
- Database trigger dispara (configurado por você)
- Edge Function `send-inscription-email` é chamada
- Resend envia email de confirmação

### 4. **Feedback ao Utilizador**
- **Sucesso:** Mensagem com ícone ✓, oferece voltar para eventos
- **Erro:** Mensagem com ícone ⚠, oferece tentar novamente

---

## 📊 Console Logs (para debugging)

Abra DevTools (F12) e veja Console para logs detalhados:

```javascript
// Inicialização
🔧 Iniciando sistema de inscrição...
⏳ Aguardando Supabase...
✅ Supabase inicializado com sucesso

// Preenchimento
✓ Evento carregado: 001-farmacologia-clinica

// Submissão
📤 Iniciando submissão do formulário...
📋 Dados do formulário: {nome: "...", email: "...", ...}
🔗 Conectando ao Supabase...
📊 Status da resposta: 201
✅ Inscrição salva com sucesso!

// Erros
⚠️ Erros de validação:
• Nome deve ter pelo menos 3 caracteres
• Email inválido
```

---

## 🔒 Segurança

✅ **Honeypot Field:** Campo oculto que bloqueia bots
✅ **Validação Frontend:** Reduz carga do servidor
✅ **Validação Backend:** Supabase valida tipos de dados
✅ **RLS Policies:** Apenas inserts permitem dados públicos
✅ **Edge Function:** Service role key guardada de forma segura

---

## 📞 Suporte

Qualquer erro durante inscrição? Verifique:
1. Console (F12) para logs de erro
2. Supabase Dashboard → Logs → API
3. Resend Dashboard → Emails (para confirmar envio)
4. Spam folder (email pode estar lá)

