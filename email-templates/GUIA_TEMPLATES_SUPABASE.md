# Guia: Templates de Email — Supabase Auth

## Onde configurar

**Supabase Dashboard → Authentication → Email Templates**

Cada aba corresponde a um tipo de email. Copia e cola o conteúdo HTML de cada ficheiro.

## Variáveis suportadas pelo Supabase

| Variável | Descrição |
|----------|-----------|
| `{{ .ConfirmationURL }}` | Link de confirmação/login/reset |
| `{{ .Token }}` | Código OTP de 6 dígitos |
| `{{ .TokenHash }}` | Token hasheado (para links customizados) |
| `{{ .SiteURL }}` | URL do site configurada no Supabase |
| `{{ .Email }}` | Email do utilizador |

## Templates criados

### 1. Confirm Signup (Confirma a tua conta)
- **Ficheiro:** `supabase-confirm-signup.html`
- **Assunto:** `Confirma a tua conta - Conheça Farmácia`
- **Variáveis usadas:** `{{ .ConfirmationURL }}`
- **Descrição:** Email enviado quando o utilizador se regista com email/password. Pede confirmação de email e mostra benefícios da conta (guardados, anotações, perfil).

### 2. Magic Link (Entrar na tua conta)
- **Ficheiro:** `supabase-magic-link.html`
- **Assunto:** `Entrar na tua conta - Conheça Farmácia`
- **Variáveis usadas:** `{{ .ConfirmationURL }}`
- **Descrição:** Email de login sem palavra-passe. Link simples com aviso de expiração.

### 3. Reset Password (Recuperar palavra-passe)
- **Ficheiro:** `supabase-reset-password.html`
- **Assunto:** `Recuperar palavra-passe - Conheça Farmácia`
- **Variáveis usadas:** `{{ .ConfirmationURL }}`
- **Descrição:** Email de recuperação de acesso. Link para criar nova palavra-passe.

## Como aplicar

1. Abre o ficheiro do template (ex: `supabase-confirm-signup.html`)
2. Copia **todo o conteúdo HTML** (Ctrl+A, Ctrl+C)
3. No Supabase Dashboard → Authentication → Email Templates
4. Clica na aba do tipo de email correspondente
5. Apaga o conteúdo existente e cola o novo HTML
6. Substitui o texto do "Assunto" pelo indicado acima
7. Clica em **Save** para cada template
8. Repete para os 3 templates

## Notas importantes

- **Não alteres** as variáveis `{{ .ConfirmationURL }}` — são usadas pelo Supabase para gerar os links
- O template HTML é directo (sem Go templates complexos), compatível com todos os clientes de email
- Cores usadas: verde marca `#00493a` / `#0a844f`, cinza `#888888`, fundo `#fafafa`
- O logo carrega de `https://conhecafarmacia.com/logo/logo-principal-verde.png` (precisa de estar acessível)
- **Testa** com uma conta nova após configurar o SMTP para verificar que os emails chegam corretamente
