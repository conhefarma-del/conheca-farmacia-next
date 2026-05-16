# Nova Categoria: Conheça o Medicamento

**Data:** 2026-05-12
**Estado:** Aprovado

---

## Contexto

O projeto "Conheça Farmácia" precisa de uma categoria dedicada a apresentar medicamentos específicos ao público. Atualmente a categoria `voce-sabia` cobre conteúdos informativos gerais, mas não há um espaço dedicado a fichas/info sobre medicamentos individuais. A decisão foi **criar nova categoria** em vez de substituir `voce-sabia`, pois têm focos distintos.

---

## Decisões de Design

| Aspecto              | Valor                     |
| -------------------- | ------------------------- |
| Slug                 | `conheca-medicamento`     |
| Label                | `Conheça o Medicamento`   |
| Cor                  | `#7c3aed` (roxo)          |
| Posição nos filtros  | Após "Para Profissionais" |
| Manter `voce-sabia`? | Sim, intacta              |

---

## Ficheiros a Modificar (7)

### 1. `artigos.html` — Botão de filtro

Inserir após o botão "Para Profissionais" (linha ~198):

```html
<button class="filter-btn" data-filter="conheca-medicamento">
  Conheça o Medicamento
</button>
```

### 2. `src/articles-logic.js` — categoryColors

Adicionar entrada ao objeto `categoryColors` (linha ~14):

```js
"conheca-medicamento": "#7c3aed",
```

### 3. `src/article-detail.js` — categoryColors

Adicionar entrada ao objeto `categoryColors` (linha ~10):

```js
"conheca-medicamento": "#7c3aed",
```

### 4. `src/input.css` — Estilos do filtro

Adicionar após o bloco `.filter-btn[data-filter="profissionais"]` (linha ~777):

```css
.filter-btn[data-filter="conheca-medicamento"] {
  @apply border-[#7c3aed] text-brand-deep hover:bg-[#7c3aed]/10 hover:text-[#7c3aed];
}
```

Adicionar após o bloco `.filter-btn.active[data-filter="profissionais"]` (linha ~801):

```css
.filter-btn.active[data-filter="conheca-medicamento"] {
  @apply bg-[#7c3aed] border-[#7c3aed];
}
```

### 5. `src/content/articles-catalog.json` — 2 novos artigos

Adicionar 2 artigos com categoria `conheca-medicamento`:

**Artigo 1 — Omeprazol:**

- ID/slug: `008-omeprazol`
- Título: `Omeprazol: Tudo o que Precisa Saber`
- Autor: Maria Lima (consistente com autora farmacêutica)
- Conteúdo: o que é, mecanismo de ação, indicações, posologia, efeitos secundários, interações, precauções
- Referências: 2-3 fontes (EMA, OMS, bula ANVISA)

**Artigo 2 — Amoxicilina:**

- ID/slug: `009-amoxicilina`
- Título: `Amoxicilina: O Antibiótico Mais Prescrito`
- Autor: Maria Lima
- Conteúdo: o que é, classe farmacológica, indicações, posologia, efeitos secundários, resistência bacteriana, precauções
- Referências: 2-3 fontes

### 6. `src/content/ARTICLE_GUIDELINES.md` — Tabela de categorias

Adicionar linha à tabela de categorias (linha ~57):

```
| 5 | `conheca-medicamento` | Conheça o Medicamento | 🟣 #7c3aed |
```

### 7. `conheca_farmacia_style_guide.html` — Badge e display

Adicionar CSS `.badge-conheca-medicamento` após `.badge-voce-sabia` (linha ~1083):

```css
.badge-conheca-medicamento {
  background: rgba(124, 58, 237, 0.12);
  color: #7c3aed;
}
```

Atualizar seções de display no style guide que listam categorias (linhas ~1435, ~4479, ~5052, ~5640) para incluir a nova categoria.

---

## Ordem dos Filtros

```
Todos → Para Profissionais → Conheça o Medicamento → Você Sabia? → Curiosidades → Saúde e Informação
```

---

## O que NÃO muda

- Categoria `voce-sabia` permanece intacta em todos os ficheiros
- Nenhum artigo existente é alterado
- Nenhum markdown frontmatter é modificado
- Supabase, edge functions, config.js — sem impacto
- `dist/` — regenerado automaticamente no build

---

## Verificação

1. `npm run dev` — abrir artigos.html e verificar:
   - Botão de filtro "Conheça o Medicamento" aparece após "Para Profissionais"
   - Clicar no filtro mostra só os 2 novos artigos
   - Cores do botão (roxo) aplicadas corretamente (borda, hover, active)
   - Tags nos cards dos novos artigos mostram "Conheça o Medicamento" em roxo
2. Clicar nos novos artigos — verificar artigo.html:
   - Badge da categoria em roxo
   - Conteúdo renderizado corretamente
   - Referências aparecem (se existirem)
3. Verificar que "Você Sabia?" continua a funcionar normalmente
4. `npm run build` — verificar que o build não dá erros
