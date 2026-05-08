# 🚀 Instruções de Push para GitHub

## Status Atual

✅ Repositório local inicializado  
✅ Commit criado (166 ficheiros)  
✅ Remote configurado: `https://github.com/bjaysh/conheca-farmacia.git`  
⏳ **Aguardando:** Autenticação e Push para GitHub

---

## 📋 O que Falta

1. **Criar repositório no GitHub** (se ainda não existe)
2. **Gerar Personal Access Token** para autenticação
3. **Fazer Push final**

---

## ✅ PASSO 1: Criar Repositório no GitHub

1. Abra https://github.com/new
2. Preencha com:
   - **Repository name:** `conheca-farmacia`
   - **Description:** `Plataforma de educação e gestão clínica farmacêutica`
   - **Visibility:** Public
   - ❌ **NÃO marque:** "Initialize with README", "Add .gitignore", "Choose license"
3. Clique **"Create repository"**

**Status:** ✅ Repositório deve estar em https://github.com/bjaysh/conheca-farmacia

---

## ✅ PASSO 2: Gerar Personal Access Token (PAT)

1. Vá a https://github.com/settings/tokens
2. Clique **"Generate new token"** → **"Generate new token (classic)"**
3. Preencha:
   - **Token name:** `git-push-conheca-farmacia`
   - **Expiration:** `90 days`
   - **Select scopes:** ☑️ `repo` (apenas este)
4. Clique **"Generate token"**
5. **⚠️ COPIE O TOKEN IMEDIATAMENTE** (aparece só uma vez!)

Exemplo do token (você verá algo assim):

```
ghp_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q
```

**Guarde este token num local seguro!**

---

## ✅ PASSO 3: Configurar Credenciais do Git

No PowerShell, execute:

```powershell
git config --global credential.username "bjaysh"
```

---

## ✅ PASSO 4: Fazer Push

No PowerShell, na pasta do projeto, execute:

```powershell
git push -u origin main
```

**O Git vai pedir:**

- **Username:** Deixe vazio (já configurado) ou digite `bjaysh`
- **Password:** Cole o token que você copiou no PASSO 2

---

## 🔐 Exemplo Completo de Autenticação

```powershell
# Terminal pedirá:
$ git push -u origin main

# Responda com:
# Username: bjaysh
# Password: ghp_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7q

# Se for bem-sucedido:
# Enumerating objects: 166, done.
# Counting objects: 100% (166/166), done.
# ...
# To https://github.com/bjaysh/conheca-farmacia.git
#  * [new branch]      main -> main
# Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## 🆘 Troubleshooting

### "fatal: repository not found"

❌ Repositório não foi criado no GitHub  
✅ Solução: Crie em https://github.com/new (PASSO 1)

### "fatal: Authentication failed"

❌ Token inválido ou expirado  
✅ Solução: Gere novo token em https://github.com/settings/tokens (PASSO 2)

### "remote already exists"

✅ Normal! Remote já está configurado:

```powershell
git remote -v
# origin  https://github.com/bjaysh/conheca-farmacia.git (fetch)
# origin  https://github.com/bjaysh/conheca-farmacia.git (push)
```

### "timeout ou demora muito"

⚠️ Com 166 ficheiros, pode levar alguns minutos  
✅ Deixe processar sem interromper

---

## ✨ Após Push Bem-Sucedido

Você verá algo como:

```
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

Então pode verificar em:

- 🌐 https://github.com/bjaysh/conheca-farmacia
- Todos os 166 ficheiros estarão no GitHub
- README.md estará visível na homepage do repositório

---

## 📝 Próximos Passos (Opcional)

Após push bem-sucedido:

1. **Enable GitHub Pages** (para deploy automático):
   - Settings → Pages → Source: `main` branch
   - Deploy em https://bjaysh.github.io/conheca-farmacia

2. **Adicionar webhook para Supabase** (se necessário)

3. **Proteger a branch main**:
   - Settings → Branches → Add rule para `main`

---

**Avise-me quando tiver concluído os PASSOS 1 e 2, e faço o resto! 🚀**
