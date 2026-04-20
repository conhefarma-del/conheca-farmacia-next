# 🚀 Configuração Vercel Concluída

## Problema Identificado

❌ **Erro 404 e falta de design (CSS não carregava)**

**Causa raiz:**
- O Vercel não estava executando o build do TailwindCSS
- Faltava reescrita de URLs para a SPA com múltiplos HTMLs
- Cache headers não estavam otimizados

---

## ✅ Solução Implementada

Criei dois ficheiros de configuração:

### 1. **vercel.json** ⚙️
```json
{
  "buildCommand": "npm run build",
  "installCommand": "npm install",
  "outputDirectory": ".",
  "framework": "static",
  "rewrites": [...],
  "headers": [...]
}
```

**O que faz:**
- ✅ Executa `npm run build` para compilar TailwindCSS antes de servir
- ✅ Reescreve URLs para os ficheiros HTML corretos
- ✅ Define cache headers para CSS e assets (para performance)
- ✅ Define security headers (X-Frame-Options, X-Content-Type-Options)

### 2. **.vercelignore** 📦
Exclui ficheiros desnecessários do build (documentação, testes, config local)
Reduz tamanho do deploy de ~50KB

---

## 🔄 Como Fazer Redeploy

### Opção 1: Push Automático (Recomendado)
```bash
git add vercel.json .vercelignore
git commit -m "feat: configurar Vercel com TailwindCSS build e rewrites"
git push origin main
```

**Vercel vai:**
1. Detectar mudanças no GitHub
2. Executar `npm install`
3. Executar `npm run build` (gera dist/output.css)
4. Servir os ficheiros com rewrites e cache headers
5. Deploy automático!

### Opção 2: Redeploy Manual no Vercel Dashboard
1. Aceda a https://vercel.com/dashboard
2. Selecione `conheca-farmacia`
3. Clique **"Redeploy"** (botão no canto superior direito)
4. Espere ~2-3 minutos

### Opção 3: Vercel CLI
```bash
npm install -g vercel
vercel --prod
```

---

## 🧪 Verificação Pós-Deploy

Após o redeploy, teste:

### ✅ CSS está carregando?
1. Abra https://seu-vercel-domain.vercel.app
2. Abra DevTools (F12)
3. Vá a **Network**
4. Procure por `output.css`
5. **Status deve ser 200** (não 404)

### ✅ Design está visível?
- Cards com shadows
- Cores (verde, azul, branco)
- Responsive layout
- Imagens com aspect ratio correto

### ✅ URLs funcionam?
- https://seu-vercel-domain.vercel.app/artigos
- https://seu-vercel-domain.vercel.app/eventos
- https://seu-vercel-domain.vercel.app/sobre
- Nenhuma deve dar 404

### ✅ Inscrição funciona?
- Clique "Inscrever-me" em qualquer evento
- Formulário deve abrir em `/inscricao`
- Validação deve funcionar

---

## 🔐 Variáveis de Ambiente (Opcional)

Se quiser adicionar variáveis de ambiente no Vercel (para .env):

1. No Vercel Dashboard, vá a **Settings** → **Environment Variables**
2. Adicione:
   ```
   SUPABASE_URL = https://tbqsazriorqzexjwhekw.supabase.co
   SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIs...
   ```

**Nota:** Atualmente estão hardcoded em `config.js` (funciona, mas menos seguro)

---

## 📊 O Que Mudou

| Antes | Depois |
|-------|--------|
| ❌ CSS não carregava | ✅ CSS compilado durante build |
| ❌ Erro 404 em URLs | ✅ Rewrites para HTML correto |
| ❌ Cache não otimizado | ✅ Cache headers (3600s para HTML, 1 ano para assets) |
| ❌ Sem security headers | ✅ Headers de segurança adicionados |

---

## 🆘 Se Ainda Tiver Problemas

### Problema: Ainda vê "404 Not Found"
```
1. Vercel Dashboard → seu-projeto
2. Deployments → Último deployment
3. Veja logs de build
4. Se houver erro: git push force redeploy
```

### Problema: CSS ainda não carrega
```
1. DevTools → Network → Procure output.css
2. Se status 404: verifique se dist/ está no .gitignore
3. Solução: git rm --cached dist/ && git add -f dist/output.css && git push
```

### Problema: Imagens quebradas
```
Verifique:
1. Paths dos assets são relativos (./assets/...)
2. Ficheiros existem localmente
3. Nomes exatos (case-sensitive em Linux/Vercel)
```

---

## 🎯 Resumo

✅ Problema identificado: TailwindCSS não era compilado  
✅ Solução implementada: vercel.json com build command  
✅ Otimizações adicionadas: cache headers + security headers  
✅ Próximo passo: Fazer git push e deixar Vercel fazer redeploy automático  

**O seu website deve estar online e funcional em ~3-5 minutos!** 🚀
