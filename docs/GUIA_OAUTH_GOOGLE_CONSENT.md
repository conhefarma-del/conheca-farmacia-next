# Guia — OAuth Consent Screen do Google com a marca "Conheça Farmácia"

**Objetivo:** fazer com que o ecrã de consentimento do Google mostre **"Conheça Farmácia"** (com logo e links teus) em vez de `tbqsazriorqzexjwhekw.supabase.co`.

> ⚠️ **Nota importante:** o login com Google **já funciona** no site, o que significa que já existe um projeto Google Cloud e um OAuth Client criados. Este guia serve para (a) encontrar esse projeto, (b) configurar o branding nele e (c) validar as credenciais. **Não vais criar nada novo além da configuração de branding** — criar um segundo projeto/cliente partia o login existente.

---

## Antes de começar (pré-requisitos)

- [ ] Acesso à conta Google que criou o login com Google no site (a mesma onde está o OAuth Client)
- [ ] Saber o **Client ID** atual: está no Supabase Dashboard → *Authentication → Providers → Google* (campo "Google Client ID", algo como `123456789-abc.apps.googleusercontent.com`) — serve para identificar o projeto certo
- [ ] O site `https://conhecafarmacia.com` acessível publicamente
- [ ] Email de suporte: `conhecerfarmacia@gmail.com`

---

## Passo 1 — Identificar o projeto Google Cloud correto

1. Abre <https://console.cloud.google.com> e inicia sessão com a conta dona do site.
2. No seletor de projetos (barra superior), procura o projeto associado ao login do site.
3. **Como confirmar que é o projeto certo:** vai a *APIs & Services → Credentials* e verifica se existe um **OAuth 2.0 Client ID** cujo valor corresponde ao Client ID que copiaste do Supabase.

> Se houver vários projetos, repete a verificação em cada um até encontrares o Client ID coincidente. **Todo o resto deste guia é feito nesse projeto.**

---

## Passo 2 — Abrir a plataforma Google Auth

O ecrã de consentimento vive agora em **Google Auth Platform** (não em "OAuth consent screen" antigo):

1. No menu lateral: **☰ → Google Auth Platform**
   *(ou direto: <https://console.cloud.google.com/auth/branding>)*
2. Se aparecer **"Google Auth Platform not configured yet"**, clica em **Get Started** e preenche o assistente inicial:

| Campo | Valor |
|-------|-------|
| App name | `Conheça Farmácia` |
| User support email | `conhecerfarmacia@gmail.com` |
| Audience (User type) | **External** |
| Contact email | `conhecerfarmacia@gmail.com` |
| Política de dados | marcar "I agree…" → **Continue → Create** |

3. Se já estava configurado, segue diretamente para os separadores **Branding / Audience / Data Access** descritos abaixo.

---

## Passo 3 — Separador "Branding" (o coração do guia)

Vai a **Google Auth Platform → Branding** e preenche:

| Campo | Valor | Notas |
|-------|-------|-------|
| **App name** | `Conheça Farmácia` | É o nome que aparece no topo do ecrã de consentimento |
| **App logo** | Logótipo do site (120×120 px, PNG/JPG, <1 MB) | Aparece no ecrã e nos pedidos de acesso |
| **Application home page** | `https://conhecafarmacia.com` | Link "Home" do ecrã de consentimento |
| **Application Privacy Policy link** | `https://conhecafarmacia.com/politica-privacidade` ⚠️ confirma o slug real da página no site (footer → "Política de Privacidade") | Obrigatório para publicar |
| **Application Terms of Service link** | `https://conhecafarmacia.com/termos` ⚠️ só se a página existir; se não existir, cria-a antes ou deixa vazio quando permitido | Recomendado ter |

### Domínios autorizados

Na secção **Authorized domains** clica em **+ Add domain** e adiciona:

```
conhecafarmacia.com
```

> ❗ O Google **não aceita** `supabase.co` nem subdomínios alheios aqui — e não precisa: o domínio autorizado é o **teu**, porque é a tua marca que fica associada à app.

Clica **Save**.

---

## Passo 4 — Separador "Audience"

1. Em **Publishing status**, decide:
   - **Testing** — só utilizadores adicionados manualmente (até 100) conseguem entrar com Google. Adequado enquanto testas.
   - **In production** — qualquer pessoa pode entrar. ✅ **É isto que queres para um website público.**
2. Clica **Publish app** e confirma.

> 💡 **Sobre a verificação do Google:** as scopes usadas pelo login do site (`openid`, `email`, `profile`) são **não sensíveis**, portanto **não precisas do processo formal de verificação** nem de security assessment. Ao publicar em produção sem verificação, o Google mostra apenas um aviso genérico ("app não verificada") em alguns casos — mas como só pedes dados básicos de perfil, o fluxo funciona normalmente. Se algum dia pedires scopes sensíveis, aí sim será preciso submeter à verificação.

---

## Passo 5 — Validar o OAuth Client existente

Vai a **Google Auth Platform → Clients** (ou *APIs & Services → Credentials*) e abre o **OAuth Client ID** tipo **Web application** usado pelo site:

### Authorized JavaScript origins — deve conter:

```
https://conhecafarmacia.com
http://localhost:3000        ← só se fazes dev local com Google
```

### Authorized redirect URIs — deve conter exatamente:

```
https://tbqsazriorqzexjwhekw.supabase.co/auth/v1/callback
```

*(Este URI é fixo do Supabase — não se altera. É ele que faz a ponte, mas quem aparece no ecrã de consentimento é a tua marca configurada no Passo 3.)*

Se algo faltar, adiciona e clica **Save**.

---

## Passo 6 — Verificar o lado Supabase (5 minutos)

No **Supabase Dashboard** (<https://supabase.com/dashboard>) do projeto `tbqsazriorqzexjwhekw`:

### 6.1 Provider Google
*Authentication → Providers → Google*:
- ✅ Enabled
- Client ID e Client Secret preenchidos (os mesmos do Passo 5)
- **Save**

### 6.2 Configuração de URLs
*Authentication → URL Configuration*:

| Campo | Valor |
|-------|-------|
| **Site URL** | `https://conhecafarmacia.com` |
| **Redirect URLs** (allow list) | `https://conhecafarmacia.com/**` e `http://localhost:3000/**` (dev) |

> Sem o Site URL correto, após o login o utilizador podia voltar para um sítio errado — o código do site passa `redirectTo: origin/lang/perfil`, mas o Supabase só honra `redirectTo` que esteja na allow list.

---

## Passo 7 — Testar o resultado

1. Abre uma janela anónima e vai a `https://conhecafarmacia.com/entrar`
2. Clica **Continuar com Google**
3. ✅ **Esperado:** ecrã do Google com o logótipo, o nome **"Conheça Farmácia"**, email de suporte `conhecerfarmacia@gmail.com` e os links Home/Privacidade apontando ao teu domínio — **sem referência a `tbqsazriorqzexjwhekw.supabase.co`**
4. Completa o login e confirma que cais em `/perfil` autenticado

> 🔄 Se ainda vir o domínio supabase.co: força refresh com Ctrl+Shift+R, espera ~5 min (propagação da config) e repete. Confirma também que publicaste a app (*In production*) no Passo 4.

---

## Resumo visual do antes/depois

```
ANTES                                DEPOIS
┌───────────────────────────────┐    ┌───────────────────────────────┐
│ Escolher uma conta            │    │ Escolher uma conta            │
│ para continuar em             │    │ para continuar em             │
│ tbqsazrio…supabase.co         │    │ [logo] Conheça Farmácia       │
│                               │    │ conhecafarmacia.com           │
│ Consulte a Política de        │    │                               │
│ Privacidade e os Termos de    │    │ Privacidade • Termos • Home   │
│ Utilização de                 │    │ (todos apontando ao teu       │
│ tbqsazrio…supabase.co         │    │  domínio)                     │
└───────────────────────────────┘    └───────────────────────────────┘
```

---

## Checklist rápido

- [ ] Projeto GCP certo identificado (Client ID = o do Supabase)
- [ ] Branding: nome, logo, homepage, privacidade, termos
- [ ] `conhecafarmacia.com` em Authorized domains
- [ ] App publicada (**In production**)
- [ ] Redirect URI do Supabase presente no cliente OAuth
- [ ] Site URL + Redirect URLs corretos no Supabase
- [ ] Teste em janela anónima bem-sucedido

**Duração estimada:** 20–30 minutos · **Custo:** 0 €
