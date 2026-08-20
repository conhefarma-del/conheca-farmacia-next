# Template Boas-Vindas — Conta no Website

## Arquitetura

O email é enviado via **Edge Function** `send-newsletter-email` (Supabase), não diretamente pelo Brevo. O template está hardcoded na Edge Function como `getWelcomeAccountTemplate()`.

**Fluxo:**
```
Aluno cria conta (Google OAuth) → lib/actions/competition.js
  → chama Edge Function send-newsletter-email (type: 'welcome-account')
    → getWelcomeAccountTemplate(nome) gera o HTML
    → sendViaBrevo() envia via API Brevo
```

## Tipo na Edge Function

| Campo | Valor |
|-------|-------|
| `type` | `welcome-account` |
| `email` | email do utilizador (do Google OAuth) |
| `nome` | nome do utilizador (do Google OAuth `raw_user_meta_data.full_name`) |

## Variáveis do Template

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `${nome}` | Nome do utilizador (injetado na string template) | `Maria` |

## Como chamar a Edge Function

```js
// lib/actions/competition.js (após criar conta via Google)
const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

await fetch(`${SUPABASE_URL}/functions/v1/send-newsletter-email`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
    'x-client-info': 'next.js',
  },
  body: JSON.stringify({
    type: 'welcome-account',
    email: user.email,
    nome: user.raw_user_meta_data?.full_name || '',
  }),
})
```

## Notas técnicas

- **SVGs inline**: os 7 ícones Lucide SVG estão inline no HTML — funcionam em todos os clientes de email (Gmail, Outlook, Apple Mail)
- **Responsivo**: layout 600px (padrão email) com padding responsivo
- **Dark mode**: cores em hex direto — compatível com dark mode do Gmail/Apple Mail
- **Sem dependências externas**: tudo inline, sem fonts externas (system fonts)
- **List-Unsubscribe**: header RFC 8058 incluído no envio
- **Tags**: `['account', 'welcome-account']` (para analytics no Brevo)
- **From**: `info@conhecafarmacia.com` (diferente do newsletter que usa `newsletter@`)
