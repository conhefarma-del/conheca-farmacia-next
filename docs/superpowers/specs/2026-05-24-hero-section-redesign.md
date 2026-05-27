# Hero Section Redesign - Especificação de Design

## Visão Geral
Redesign da secção Hero (`#inicio`) do `index.html`, substituindo a imagem do farmacêutico + floating card fixo por 5 cards informativos com disposição em grid assimétrico.

## Contexto
- **Ficheiro**: `index.html` (linhas 155-189)
- **Estado atual**: Título + subtítulo + CTA à esquerda; imagem + floating card fixo à direita
- **Problema**: Card fixo à imagem, pouco dinamismo visual

## Especificações de Design

### Estrutura
- **Remover**: Imagem do farmacêutico completamente
- **Adicionar**: 5 cards flutuantes com fundo escuro
- **Layout**: Grid assimétrico estilo "bento box"
- **Responsividade**: 2 colunas desktop, 1 coluna mobile

### Conteúdo dos Cards
| Card | Texto | Ícone (SVG) |
|------|-------|-------------|
| 1 | Eventos Especializados | `Asset 7-verde.svg` (calendário/marker) |
| 2 | Conhecimento de Qualidade | `Asset 1-verde.svg` (cruz farmacêutica) |
| 3 | Artigos Científicos | `Asset 15-verde.svg` (documento/texto) |
| 4 | Lives & Webinars | `Asset 20-verde.svg` (vídeo/play) |
| 5 | Comunidade Ativa | `Asset 11-verde.svg` (grupo/pessoas) |

### Especificações Visuais
- **Cor de fundo**: `#00493a` (verde farmacêutico escuro)
- **Cor de texto**: `#ffffff` (branco)
- **Border-radius**: `12px`
- **Box-shadow**: `0 4px 12px rgba(0, 73, 58, 0.15)`
- **Padding**: `20px`
- **Largura base**: `auto` (grid responsivo)
- **Ícones**: `24x24px`, versão branca dos SVGs

### Layout Grid (Desktop)
```.hero-cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  grid-template-rows: repeat(2, auto);
  gap: 24px;
}

/* Card 1: Eventos - span 2 colunas */
.card-1 { grid-column: span 2; }

/* Card 5: Comunidade - centralizado na linha 2 */
.card-5 { grid-column: 2; }
```

### Layout Grid (Mobile)
```css
@media (max-width: 768px) {
  .hero-cards {
    grid-template-columns: 1fr;
  }
}
```

## Arquitetura

### Ficheiros a Modificar
1. **`index.html`** (linhas 155-189)
   - Remover `<div class="hero-visual">` com imagem
   - Adicionar `<div class="hero-cards">` com 5 cards

2. **`src/input.css`** (ou ficheiro CSS da secção Hero)
   - Adicionar regras para `.hero-cards`, `.hero-card`, `.hero-card-icon`, `.hero-card-text`

### Dependências
- Ícones SVG: `/public/assets/icons/Asset 1-branco.svg`, `Asset 7-branco.svg`, `Asset 11-branco.svg`, `Asset 15-branco.svg`, `Asset 20-branco.svg`
- Variáveis CSS existentes: `--brand-primary` (#00493a), `--brand-bg` (branco)

## Fluxo de Implementação
1. Ler `index.html` atual
2. Identificar secção Hero (linhas 155-189)
3. Substituir `<div class="hero-visual">` por `<div class="hero-cards">`
4. Criar 5 cards com estrutura HTML idêntica
5. Adicionar CSS no `input.css` ou `src/style.css`
6. Validar responsividade (mobile/desktop)
7. Testar build: `npm run build`

## Critérios de Sucesso
- [ ] 5 cards visíveis em desktop (layout 3+2 ou 2+2+1)
- [ ] 1 coluna em mobile
- [ ] Ícones brancos visíveis sobre fundo verde
- [ ] Cards com shadow suave
- [ ] Sem imagem de farmacêutico
- [ ] Título e subtítulo mantidos
- [ ] CTA "Fale Connosco" mantido
- [ ] Build sem erros

## Riscos e Mitigações
| Risco | Mitigação |
|-------|-----------|
| Ícones não visíveis (cor errada) | Usar versão `-branco.svg` dos assets |
| Grid quebra em mobile | Media query `max-width: 768px` com `grid-template-columns: 1fr` |
| Cards sem contraste | Confirmar `#00493a` sobre fundo branco |
| Build falha | Validar HTML com `npm run build` após edição |

## Referências
- Design inspirado em: https://cdn.dribbble.com/userupload/46591234/file/c465b177ce7c425c042eb6e036edcba8.png
- CLAUDE.md: lições aprendidas sobre edição de HTML/CSS
- Memory: `admin-css-stats-grid-variants.md` (evitar duplicação de seletores)
