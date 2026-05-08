# Guia: Emails com Resend + Supabase Edge Functions

## 🎯 Arquitetura Geral

```
Utilizador enche o formulário
            ↓
Clica "Confirmar Inscrição"
            ↓
Dados enviados ao Supabase
            ↓
INSERT na tabela "inscricoes"
            ↓
Database Trigger dispara
            ↓
Supabase Edge Function executada
            ↓
Edge Function chama Resend API
            ↓
Resend envia email para participante ✉️
```

---

## 1️⃣ Configurar Resend

### 1.1 Criar Conta

1. Aceda a [https://resend.com](https://resend.com)
2. Clique em **"Get Started"**
3. Crie conta com email (ex: seu_email@gmail.com)
4. Confirme o email

### 1.2 Obter API Key

1. Dashboard do Resend
2. Vá para **Settings** → **API Keys**
3. Copie a **API Key** (começa com `re_`)
4. Guarde num local seguro

### 1.3 Configurar Sender (Opcional)

Para usar domínio customizado (ex: noreply@conhecafarmacia.com):

1. **Resend → Domains**
2. Clique **"Add Domain"**
3. Insira: `conhecafarmacia.com`
4. Siga as instruções de DNS
5. Aguarde confirmação (~24h)

**Para testes, use email padrão do Resend:**

```
from: 'noreply@resend.dev'
// ou
from: 'Conheça Farmácia <onboarding@resend.dev>'
```

---

## 2️⃣ Criar Supabase Edge Function

### 2.1 Instalar CLI do Supabase

```bash
npm install -g supabase
```

### 2.2 Fazer Login

```bash
supabase login
```

### 2.3 Criar Function

```bash
supabase functions new send-inscription-email
```

Isto cria:

```
supabase/functions/send-inscription-email/index.ts
```

### 2.4 Implementar Function

Copie este código em `supabase/functions/send-inscription-email/index.ts`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getInscriptionEmailTemplate } from "../../../email-template.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

interface InscriptionPayload {
  record: {
    id: number;
    nome: string;
    email: string;
    telefone: string;
    profissao: string;
    origem_evento: string;
    evento_slug: string;
    created_at: string;
  };
}

serve(async (req) => {
  // Apenas aceitar POST
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  try {
    const payload = (await req.json()) as InscriptionPayload;
    const { record } = payload;

    console.log("📧 Enviando email para:", record.email);
    console.log("Evento:", record.evento_slug);

    // Buscar nome do evento (você precisará adaptar isto)
    let nomeEvento = record.evento_slug;
    const eventos: Record<string, string> = {
      "001-farmacologia-clinica":
        "Workshop: Farmacologia Clínica Aplicada — Módulo III",
      "002-uso-racional-medicamentos":
        "Palestra: Uso Racional de Medicamentos para a Comunidade",
      "003-congresso-farmacia":
        "Congresso: Excelência em Cuidado Farmacêutico 2026",
      "004-live-covid-tratamento":
        "Live: COVID-19 e Novos Tratamentos — O que Mudou?",
      "005-webinar-interacoes-medicamentosas":
        "Webinar: Detecção e Prevenção de Interações Medicamentosas",
    };

    if (eventos[record.evento_slug]) {
      nomeEvento = eventos[record.evento_slug];
    }

    // Gerar template de email
    const htmlContent = getInscriptionEmailTemplate(
      record.nome,
      nomeEvento,
      record.created_at
    );

    // Enviar com Resend
    const resendResponse = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${RESEND_API_KEY}`,
      },
      body: JSON.stringify({
        from: "Conheça Farmácia <onboarding@resend.dev>", // Ou seu domínio configurado
        to: record.email,
        subject: "Confirmação de Inscrição - Conheça Farmácia 🎉",
        html: htmlContent,
        reply_to: "conhecerfarmacia@gmail.com",
      }),
    });

    const resendData = await resendResponse.json();

    if (!resendResponse.ok) {
      console.error("❌ Erro ao enviar email:", resendData);
      return new Response(JSON.stringify({ error: resendData.message }), {
        status: resendResponse.status,
      });
    }

    console.log("✅ Email enviado com sucesso! ID:", resendData.id);

    return new Response(
      JSON.stringify({
        success: true,
        message: "Email enviado",
        resend_id: resendData.id,
      }),
      {
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (error) {
    console.error("❌ Erro na Edge Function:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
    });
  }
});
```

### 2.5 Deploy da Function

```bash
supabase functions deploy send-inscription-email --project-id tbqsazriorqzexjwhekw
```

### 2.6 Configurar Secrets

```bash
supabase secrets set RESEND_API_KEY=re_XXXXX... --project-id tbqsazriorqzexjwhekw
```

---

## 3️⃣ Configurar Database Trigger

### 3.1 Criar Trigger via SQL

No Supabase SQL Editor, execute:

```sql
-- Criar função que dispara a Edge Function
CREATE OR REPLACE FUNCTION public.trigger_send_inscription_email()
RETURNS TRIGGER AS $$
BEGIN
  -- Chamar a Edge Function
  PERFORM net.http_post(
    url := 'https://tbqsazriorqzexjwhekw.supabase.co/functions/v1/send-inscription-email',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer YOUR_SERVICE_ROLE_KEY'
    ),
    body := jsonb_build_object(
      'record', row_to_json(NEW)
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Criar trigger na tabela inscricoes
DROP TRIGGER IF EXISTS inscription_email_trigger ON inscricoes;

CREATE TRIGGER inscription_email_trigger
AFTER INSERT ON inscricoes
FOR EACH ROW
EXECUTE FUNCTION trigger_send_inscription_email();
```

⚠️ **Importante:** Substitua `YOUR_SERVICE_ROLE_KEY` com a chave de serviço do Supabase:

- Supabase Dashboard → Settings → API Keys → `service_role` key

---

## 4️⃣ Testar Tudo

### 4.1 Teste Manual

```bash
# Chamar a Edge Function manualmente
curl -X POST https://tbqsazriorqzexjwhekw.supabase.co/functions/v1/send-inscription-email \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "record": {
      "id": 1,
      "nome": "Teste",
      "email": "seu_email@example.com",
      "evento_slug": "001-farmacologia-clinica",
      "created_at": "2026-04-18T16:47:00Z"
    }
  }'
```

### 4.2 Teste via Inscrição Real

1. Abra: `http://127.0.0.1:5500/inscricao.html?evento=001-farmacologia-clinica`
2. Preencha com seu email real
3. Envie
4. Verifique seu email (pode levar 1-2 minutos)

---

## 🐛 Troubleshooting

### Email não chega

1. **Verificar Logs:**
   - Supabase Dashboard → Functions → Logs
   - Procure por erros

2. **Verificar Resend:**
   - Resend Dashboard → Emails
   - Ver status dos emails enviados

3. **Verificar SPAM:**
   - Email pode estar em SPAM
   - Marcar como "Não é spam"

### Erro "Authorization failed"

- Usar `service_role` key (não anon key)
- Ter permissions corretas no Supabase

### Edge Function timeout

- Aumentar timeout em settings
- Verificar conexão com Resend

---

## 📋 Checklist Final

- [ ] Conta Resend criada
- [ ] API Key do Resend guardada
- [ ] CLI Supabase instalado
- [ ] Edge Function criada
- [ ] Secrets configurados (RESEND_API_KEY)
- [ ] Edge Function deployed
- [ ] Database Trigger criado
- [ ] Teste manual passou
- [ ] Teste de inscrição real funcionou
- [ ] Email recebido com sucesso

---

## 🎉 Resultado

Quando tudo estiver configurado:

1. Utilizador enche formulário em `inscricao.html`
2. Clica "Confirmar Inscrição"
3. Dados vão para Supabase
4. Trigger dispara Edge Function
5. Email é enviado automaticamente
6. Utilizador recebe email profissional com confirmação

✉️ **Pronto! Sistema automático de confirmação funcionando!**
