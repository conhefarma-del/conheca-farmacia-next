# 📝 Guia para Criação de Artigos

## Estrutura de um Artigo

Os artigos são armazenados em `content/articles-catalog.json` e contêm todos os dados necessários para renderização automática.

---

## 📸 Dimensões de Imagens

### Card de Artigo (Página Artigos)

- **Proporção**: 3:2 (largura : altura)
- **Tamanho Recomendado**: **900×600px**
- **Alternativas**:
  - 1200×800px (melhor qualidade)
  - 750×500px (arquivo menor)
  - 600×400px (mínimo aceitável)

**⚠️ Importante:** O CSS usa `object-cover`, portanto imagens que não respeitarem a proporção 3:2 serão cortadas nas laterais.

---

## 🎨 Estrutura de um Artigo no JSON

```json
{
  "id": 10,
  "slug": "010-seu-artigo",
  "title": "Seu Título do Artigo",
  "excerpt": "Resumo breve (2-3 linhas) que aparece no card de listagem",
  "category": "profissionais",
  "categoryLabel": "Para Profissionais",
  "author": {
    "name": "Nome do Autor",
    "role": "Cargo · Função",
    "bio": "Biografia breve do autor",
    "avatar": "NA",
    "avatarBg": "#0a844f"
  },
  "date": "2026-04-20",
  "readTime": 10,
  "image": "assets/content/articles/sua-imagem.png",
  "content": "## Seu conteúdo aqui\n\nTexto em markdown..."
}
```

---

## 🏷️ Categorias Disponíveis

| ID  | Categoria       | Label              | Cor        |
| --- | --------------- | ------------------ | ---------- |
| 1   | `profissionais` | Para Profissionais | 🟠 #ff6c23 |
| 2   | `voce-sabia`    | Você Sabia?        | 🟢 #0a844f |
| 3   | `curiosidades`  | Curiosidades       | ⬛ #002a32 |
| 4   | `saude`         | Saúde e Informação | 🔵 #006171 |

---

## 👤 Avatares de Autor

Use iniciais do nome (ex: "Maria Lima" → "ML"). A cor de fundo deve estar em hexadecimal.

**Cores sugeridas:**

- Verde escuro: `#00493a`
- Verde médio: `#0a844f`
- Azul petróleo: `#006171`
- Azul escuro: `#002a32`
- Laranja: `#ff6c23`

---

## 📚 Referências Bibliográficas

Artigos técnicos podem incluir uma secção de referências para citar fontes científicas, estudos ou documentos relevantes.

### Estrutura no JSON

Adicione o campo `references` (opcional) no artigo:

```json
{
  "id": "001-genericos-similares",
  "slug": "001-genericos-similares",
  "title": "A diferença entre Genéricos e Similares",
  "references": [
    "Agência Europeia de Medicamentos. (2025). Directriz sobre Medicamentos Genéricos. Documento EMA/123/2025.",
    "Organização Mundial da Saúde. (2024). Boas Práticas de Fabricação de Produtos Farmacêuticos. Technical Report Series, No. 996.",
    "Lima, M. (2023). Bioequivalência em Medicamentos: Guia Prático. Revista Farmacêutica, 45(3), 112-128."
  ]
}
```

### Diretrizes para Referências

| Critério       | Descrição                               |
| -------------- | --------------------------------------- |
| **Formato**    | Lista de strings (array JSON)           |
| **Quantidade** | Sem limite máximo (recomenda-se 3-10)   |
| **Estilo**     | APA, Vancouver ou similar (consistente) |
| **Conteúdo**   | Apenas fontes verificáveis e relevantes |

### Como é Renderizado

A secção de referências:

- Só aparece se o artigo tiver o campo `references` preenchido
- É exibida após o conteúdo do artigo e antes dos artigos relacionados
- Cada referência é numerada automaticamente (1., 2., 3., ...)
- O número é destacado em verde (`#0a844f`)

### Exemplo de Estrutura Completa

```json
{
  "id": "001-genericos-similares",
  "slug": "001-genericos-similares",
  "title": "A diferença entre Genéricos e Similares",
  "excerpt": "Entenda as principais distinções entre medicamentos genéricos e similares.",
  "category": "voce-sabia",
  "categoryLabel": "Você Sabia?",
  "author": {
    "name": "Maria Lima",
    "role": "Farmacêutica · Autora",
    "bio": "Especialista em farmacologia clínica.",
    "avatar": "ML",
    "avatarBg": "#00493a"
  },
  "date": "2026-04-15",
  "readTime": 8,
  "image": "/content/articles/genericos-similares.png",
  "references": [
    "Agência Europeia de Medicamentos. (2025). Directriz sobre Medicamentos Genéricos. EMA/123/2025.",
    "OMS. (2024). Boas Práticas de Fabricação de Produtos Farmacêuticos. Technical Report Series, No. 996."
  ],
  "content": "## O que são medicamentos genéricos?\n\nTexto do artigo..."
}
```

---

## 📝 Conteúdo em Markdown

O conteúdo aceita sintaxe markdown padrão:

```markdown
## Título Secção

Parágrafo normal.

### Subsecção

Texto com **negrito**, _itálico_ e `código inline`.

- Ponto 1
- Ponto 2
- Ponto 3

> Citação em destaque

[Link externo](https://exemplo.com)
```

---

## ✅ Antes de Publicar

1. ✔️ Imagem com proporção 3:2 (900×600px recomendado)
2. ✔️ Título claro e conciso
3. ✔️ Excerpt com 2-3 linhas máximo
4. ✔️ Categoria correta
5. ✔️ Autor com bio e avatar
6. ✔️ Data em formato `YYYY-MM-DD`
7. ✔️ ReadTime estimado (palavras/200 ≈ minutos)
8. ✔️ Conteúdo bem estruturado em markdown
9. ✔️ Referências formatadas (se aplicável)

---

## 🚀 Fluxo de Adição de Novo Artigo

1. **Preparar imagem**: 900×600px, proporção 3:2
2. **Guardar imagem**: `assets/content/articles/seu-artigo.png`
3. **Adicionar ao JSON**: Copiar template acima e preencher
4. **Escrever conteúdo**: Em markdown
5. **Adicionar referências**: Se aplicável, incluir campo `references` com 3-10 fontes
6. **Testar**: Abrir `artigos.html` e clicar no novo artigo
7. **Verificar**: Imagem completa, texto legível, links funcionando, referências formatadas

---

## 🏠 Artigos em Destaque na Página Inicial

Os artigos exibidos na seção "Artigos em Destaque" da página inicial (`index.html`) são **cards estáticos hardcoded em HTML**, diferentes dos artigos dinâmicos da página `artigos.html`.

### Para adicionar, substituir ou modificar esses cards:

1. **Edite o arquivo**: `index.html`
2. **Localize a seção**: `<section id="artigos">` (aproximadamente linha 82)
3. **Dentro da div**: `<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">`
4. **Cada card segue esta estrutura simplificada**:

```html
<article class="article-card">
  <img
    src="PATH/TO/IMAGE.png"
    alt="TÍTULO DO ARTIGO"
    class="article-card-img"
  />
  <div class="article-card-content">
    <h3 class="article-card-title">TÍTULO DO ARTIGO</h3>
    <a href="#" class="article-card-link">Ler mais <span>→</span></a>
  </div>
</article>
```

5. **Substitua**:
   - `PATH/TO/IMAGE.png`: caminho relativo da imagem (ex: `assets/content/articles/nova-imagem.png`)
   - `TÍTULO DO ARTIGO`: título que aparecerá no card
   - Mantenha o `href="#"` como placeholder (a funcionalidade de link pode ser implementada separadamente)

### ⚠️ Importante:

- Estas alterações **não afetam** a página `artigos.html` ou o sistema dinâmico de artigos
- Para que o card funcione como um link real, você precisará implementar a rota destino separadamente
- As imagens devem seguir as mesmas diretrizes de tamanho (900×600px, proporção 3:2)
- Após modificar, teste abrindo `index.html` para verificar o visual

---

## 📊 Artigos Atuais

Total de artigos: **9**

| ID  | Título                                  | Categoria          | Autor      |
| --- | --------------------------------------- | ------------------ | ---------- |
| 1   | A diferença entre Genéricos e Similares | Você Sabia?        | Maria Lima |
| 2   | 3 Práticas Clínicas Essenciais          | Para Profissionais | João Pedro |
| 3   | Como ler uma bula corretamente          | Saúde e Informação | Ana Costa  |
| 4   | Curiosidades sobre plantas medicinais   | Curiosidades       | Maria Lima |
| 5   | Resistência aos Antibióticos            | Para Profissionais | João Pedro |
| 6   | Saúde Mental e Medicamentos             | Saúde e Informação | Ana Costa  |
| 7   | Vitaminas e Suplementos                 | Você Sabia?        | Maria Lima |
| 8   | Medicamentos em Idosos                  | Para Profissionais | João Pedro |
| 9   | Tecnologia na Farmácia                  | Curiosidades       | Maria Lima |

---

## 🔐 Segurança de Conteúdo

### ⚠️ O que NÃO deve fazer

Os artigos são renderizados através do **Markdown com Sanitização DOMPurify**. Isto significa:

#### ❌ NÃO use HTML/JavaScript malicioso

```markdown
<!-- ❌ PROIBIDO - Será removido -->
<script>alert('XSS')</script>
<img src="x" onerror="alert('XSS')">
<iframe src="malicioso.html"></iframe>
```

#### ❌ NÃO use tags HTML complexas

```markdown
<!-- ❌ PROIBIDO - Não será renderizado -->
<div onclick="malicioso()">Clique aqui</div>
<style>body { display: none; }</style>
```

### ✅ O que PODE fazer (Tags Permitidas)

O conteúdo aceita **apenas** estas tags HTML e atributos:

| Tag                                                     | Atributos                 | Descrição                           |
| ------------------------------------------------------- | ------------------------- | ----------------------------------- |
| `<b>`, `<i>`, `<em>`, `<strong>`                        | —                         | Formatação de texto                 |
| `<p>`, `<br>`                                           | —                         | Parágrafos e quebras                |
| `<h1>` até `<h6>`                                       | —                         | Títulos                             |
| `<ul>`, `<ol>`, `<li>`                                  | —                         | Listas                              |
| `<blockquote>`                                          | —                         | Citações                            |
| `<code>`, `<pre>`                                       | —                         | Código                              |
| `<a>`                                                   | `href`, `target`, `title` | Links (apenas http/https)           |
| `<img>`                                                 | `src`, `alt`, `title`     | Imagens (apenas caminhos relativos) |
| `<table>`, `<thead>`, `<tbody>`, `<tr>`, `<th>`, `<td>` | —                         | Tabelas                             |

### ✅ Exemplos Seguros de Markdown

````markdown
## Título do Artigo

Este é um parágrafo normal com **negrito** e _itálico_.

### Subsecção

Pode incluir links seguros:
[Clique aqui](https://exemplo.com)

Imagens (apenas caminhos relativos):
![Descrição](assets/images/exemplo.png)

- Ponto 1
- Ponto 2

> Uma citação importante

```python
# Código Python
print("Seguro!")
```
````

| Coluna 1 | Coluna 2 |
| -------- | -------- |
| Dado 1   | Dado 2   |

```

### 🛡️ Como a Segurança Funciona

1. **Markdown Parse** → O conteúdo markdown é convertido em HTML
2. **DOMPurify Sanitize** → HTML perigoso é removido
3. **Whitelist de Tags** → Apenas tags seguras são mantidas
4. **Whitelist de Atributos** → Apenas atributos permitidos funcionam
5. **Resultado Seguro** → Conteúdo renderizado sem risco de XSS

### 💡 Boas Práticas

- ✅ Use **markdown padrão** sempre que possível
- ✅ Para formatação avançada, use **HTML simples** (bold, itálico, links)
- ✅ Teste o artigo em `artigos.html` antes de publicar
- ✅ Se algo não renderizar, está bloqueado por segurança (é normal!)
- ✅ Contacte admin se precisar de tags HTML especiais

### 🔍 Verificação de Segurança

Antes de adicionar novo artigo, verifique:

1. ✔️ Nenhum `<script>` ou `javascript:` no conteúdo
2. ✔️ Nenhum atributo `on*` (onclick, onerror, etc.)
3. ✔️ Nenhuma tag `<iframe>` ou `<embed>`
4. ✔️ Links estão em formato `[texto](url)` markdown
5. ✔️ Imagens estão em `![alt](path)` markdown

Se violar estas regras, o conteúdo será automaticamente sanitizado e partes serão removidas.

---

**Dúvidas? Consulte o `content/articles-catalog.json` para exemplos completos.**
```
