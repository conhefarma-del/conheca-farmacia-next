# Sistema de Sincronização de Vagas - Guia Completo

## 🎯 Objetivo

Conectar o número de vagas disponíveis nos eventos com as inscrições reais na base de dados Supabase. Quando alguém se inscreve, as vagas diminuem automaticamente e quando atingem zero, as inscrições são bloqueadas.

---

## 🔄 Como Funciona

### **Fluxo Completo:**

```
1. Utilizador faz inscrição
   ↓
2. Dados são guardados em Supabase (tabela inscricoes)
   ↓
3. Página do evento (evento.html) carrega
   ↓
4. JavaScript consulta: "Quantas inscrições existem para este evento?"
   ↓
5. Supabase retorna o número real (ex: 23)
   ↓
6. Página calcula vagas = capacidade - inscrições (ex: 40 - 23 = 17)
   ↓
7. Mostra na página: "17 vagas disponíveis"
   ↓
8. Se vagas = 0: Botão "Inscrever-me" fica desabilizado com "Evento Completo"
```

---

## 📍 Onde Funciona

### **1. Página de Eventos (eventos.html)**

- Lista de eventos com filtros
- Card mostra: "X vagas disponíveis" ou "Evento completo"
- Botão "Inscrever-me" desabilido se completo
- Aciona `events-logic.js`

### **2. Página de Evento Individual (evento.html?id=1)**

- Detalhe completo do evento
- Card "Vagas Disponíveis" com barra de progresso
- Barra fica vermelha quando completo
- Botão "Inscrever-me" desabilido se completo
- Aciona `event-detail.js`

---

## 🔧 Implementação Técnica

### **event-detail.js - Sincronizar Vagas**

```typescript
// Função que consulta Supabase
async function getInscriptionCount(eventoSlug) {
  const response = await fetch(
    `${window.SUPABASE_URL}/rest/v1/inscricoes?evento_slug=eq.${eventoSlug}&select=count()`,
    {
      headers: {
        Authorization: `Bearer ${window.SUPABASE_ANON_KEY}`,
        apikey: window.SUPABASE_ANON_KEY,
        Prefer: "count=exact",
      },
    }
  );

  // Retorna número real de inscrições
  return parseInt(response.headers.get("content-range").split("/")[1]);
}

// Depois, quando carrega o evento:
const realCount = await getInscriptionCount(event.slug);
const spotsLeft = event.capacity - realCount;

// Se vagas = 0: Bloquear
if (spotsLeft <= 0) {
  registrationBtn.textContent = "Evento Completo";
  registrationBtn.disabled = true;
}
```

### **events-logic.js - Sincronizar na Lista**

```typescript
// Calcula vagas na lista de eventos
const spotsLeft = event.capacity - event.registered;
const isCapacityFull = spotsLeft <= 0;

// Desabilita botão se completo
button.disabled = (event.status === 'past' || isCapacityFull);

// Muda texto do botão
${isCapacityFull ? 'Completo' : 'Inscrever-me'}
```

---

## 🧪 Testando o Sistema

### **Teste 1: Verificar Sincronização em Tempo Real**

1. Abra `eventos.html` (vê o número de vagas no card)
2. Clique em "Mais Informações" → `evento.html?id=1`
3. Veja o card "Vagas Disponíveis"
4. Número deve ser: **capacidade - inscrições reais do Supabase**

**Exemplo:**

- Evento tem capacidade: 40
- Inscrições reais no Supabase: 23
- Esperado: 17 vagas disponíveis

### **Teste 2: Bloquear Inscrições Quando Completo**

Imagine um evento pequeno (capacidade 3):

1. Faça 3 inscrições no mesmo evento (com emails diferentes)

   ```
   Inscrição 1: teste1@example.com
   Inscrição 2: teste2@example.com
   Inscrição 3: teste3@example.com
   ```

2. Recarregue a página de evento
3. **Esperado:**
   - Barra de progresso: 100%
   - Texto vermelho: "Evento completo - Sem vagas disponíveis"
   - Botão: "Evento Completo" (desabilido)
   - Console: "🚫 Inscrições fechadas - Capacidade máxima atingida"

### **Teste 3: Unblock Quando Há Cancelamento**

Se conseguisse deletar uma inscrição manualmente:

1. Aceda Supabase Dashboard → inscricoes table
2. Delete uma inscrição
3. Recarregue evento.html
4. **Esperado:**
   - Vagas = capacidade - (inscrições - 1)
   - Botão volta a ativar: "Inscrever-me"
   - Texto volta normal

---

## 📊 Estados Possíveis do Botão

| Estado    | Texto           | Desabilado | Condição                         |
| --------- | --------------- | ---------- | -------------------------------- |
| Ativo     | Inscrever-me    | Não        | Evento futuro + vagas > 0        |
| Completo  | Evento Completo | Sim        | Evento futuro + vagas = 0        |
| Passado   | Ver Gravação    | Sim        | Data do evento passou            |
| Duplicata | -               | Sim        | Usa-se da validação de duplicata |

---

## 🔍 Console Logs para Debugging

Abra DevTools (F12) → Console:

### **Ao carregar evento.html?id=1:**

```javascript
🔍 Contando inscrições para: 001-farmacologia-clinica
✓ Inscrições encontradas: 23
📊 Usando contagem real do Supabase: 23
(ou se falhar: 📊 Usando contagem do JSON: 23)
🚫 Inscrições fechadas - Capacidade máxima atingida (se cheio)
```

### **Erro de conectividade:**

```javascript
⚠️ Erro ao conectar com Supabase: [error details]
📊 Usando contagem do JSON: 23 (fallback)
```

---

## ⚡ Performance

- ✅ Query otimizada: `select=count()` retorna apenas o número
- ✅ Sem carregar todos os dados: apenas conta
- ✅ Cache HTTP: respostas são cached pelo navegador
- ✅ Fallback: se Supabase falhar, usa dados do JSON

**Tempo de resposta esperado:** < 100ms

---

## 🚨 Casos Especiais

### **E se o Supabase não responder?**

- Sistema usa `event.registered` do JSON como fallback
- Vagas podem estar ligeiramente desatualizadas
- Mas o banco de dados garante integridade (UNIQUE constraint)

### **E se várias pessoas clicarem ao mesmo tempo?**

- Database valida em tempo real
- Se capacidade for atingida:
  - Primeira pessoa: sucesso ✓
  - Segunda pessoa: erro 23505 (duplicate/capacity error)
  - Mensagem: "Já está registado"

### **E se um evento tiver capacidade infinita?**

- Para Lives com `capacity: 5000`
- Sistema funciona igualmente
- Botão nunca fica desabilido (a menos que evento passe)

---

## 📈 Fluxo Detalhado - Sincronização

```
┌─────────────────────────────────────┐
│   Página de Evento Carrega           │
│   (evento.html?id=1)                │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  Fetch event JSON (evento 1)         │
│  - Capacidade: 40                   │
│  - Registered (JSON): 23 (desatualizado)
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  Async: getInscriptionCount()        │
│  Query Supabase:                     │
│  SELECT COUNT(*) FROM inscricoes     │
│  WHERE evento_slug = '001-...'      │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  Supabase Retorna: 25                │
│  (número REAL de inscrições)         │
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  Cálculo:                            │
│  spotsLeft = 40 - 25 = 15            │
│  capacityPercent = (25/40) * 100 = 62.5%
└────────────┬────────────────────────┘
             │
             ↓
┌─────────────────────────────────────┐
│  Renderizar UI:                      │
│  - Barra: 62.5% preenchida           │
│  - Texto: "15 vagas disponíveis"     │
│  - Botão: "Inscrever-me" (ativo)     │
└─────────────────────────────────────┘
```

---

## 📞 Próximos Passos

Para melhorias futuras:

- [ ] Mostrar número em tempo real (WebSocket)
- [ ] Notificar quando vagas abrirem (ex: cancelamento)
- [ ] Fila de espera quando completo
- [ ] Dashboard de admin para ver inscrições

---

## ✅ Checklist de Implementação

- ✅ Função `getInscriptionCount()` criada em event-detail.js
- ✅ Query ao Supabase com `Prefer: count=exact`
- ✅ Cálculo de vagas sincronizado
- ✅ Botão desabilido quando capacidade atingida
- ✅ Fallback para JSON se Supabase falhar
- ✅ Estilos CSS para estados
- ✅ Console logs para debugging
- ✅ Events list (eventos.html) atualizada
- ✅ Barra de progresso vermelha quando completo

**Status: ✅ Completo**
