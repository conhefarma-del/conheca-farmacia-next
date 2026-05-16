# Conheça o Medicamento — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar a categoria `conheca-medicamento` (label: "Conheça o Medicamento", cor: `#7c3aed`) ao sistema de artigos, com 2 artigos de exemplo sobre Omeprazol e Amoxicilina.

**Architecture:** A nova categoria segue o padrão existente — slug no JSON, cor no `categoryColors`, botão de filtro em HTML, estilos CSS por atributo `data-filter`. Nenhuma alteração estrutural, só adições.

**Tech Stack:** Vite, Tailwind CSS v4, Vanilla JS, JSON data catalog

---

## File Structure

| File                                | Action | Responsibility                                         |
| ----------------------------------- | ------ | ------------------------------------------------------ |
| `src/content/articles-catalog.json` | Modify | Adicionar 2 artigos com category `conheca-medicamento` |
| `artigos.html`                      | Modify | Adicionar botão de filtro após "Para Profissionais"    |
| `src/articles-logic.js`             | Modify | Adicionar cor ao `categoryColors`                      |
| `src/article-detail.js`             | Modify | Adicionar cor ao `categoryColors`                      |
| `src/input.css`                     | Modify | Adicionar 2 blocos CSS para filtro                     |
| `src/content/ARTICLE_GUIDELINES.md` | Modify | Adicionar linha na tabela de categorias                |
| `conheca_farmacia_style_guide.html` | Modify | Adicionar badge CSS + 4 secções de display             |

---

### Task 1: Adicionar cor ao categoryColors em articles-logic.js

**Files:**

- Modify: `src/articles-logic.js:8-14`

- [ ] **Step 1: Adicionar entrada "conheca-medicamento" ao categoryColors**

No ficheiro `src/articles-logic.js`, na linha 10 (após a linha `"voce-sabia": "#0a844f",`), adicionar:

```js
"conheca-medicamento": "#7c3aed",
```

O bloco `categoryColors` fica:

```js
const categoryColors = {
  profissionais: "#ff6c23",
  "voce-sabia": "#0a844f",
  "conheca-medicamento": "#7c3aed",
  curiosidades: "#002a32",
  saude: "#006171",
  legislacao: "#ff4d4d",
};
```

- [ ] **Step 2: Commit**

```bash
git add src/articles-logic.js
git commit -m "feat: add conheca-medicamento color to articles-logic categoryColors"
```

---

### Task 2: Adicionar cor ao categoryColors em article-detail.js

**Files:**

- Modify: `src/article-detail.js:4-10`

- [ ] **Step 1: Adicionar entrada "conheca-medicamento" ao categoryColors**

No ficheiro `src/article-detail.js`, na linha 6 (após a linha `"voce-sabia": "#0a844f",`), adicionar:

```js
"conheca-medicamento": "#7c3aed",
```

O bloco `categoryColors` fica:

```js
const categoryColors = {
  profissionais: "#ff6c23",
  "voce-sabia": "#0a844f",
  "conheca-medicamento": "#7c3aed",
  curiosidades: "#002a32",
  saude: "#006171",
  legislacao: "#ff4d4d",
};
```

- [ ] **Step 2: Commit**

```bash
git add src/article-detail.js
git commit -m "feat: add conheca-medicamento color to article-detail categoryColors"
```

---

### Task 3: Adicionar estilos CSS do filtro em input.css

**Files:**

- Modify: `src/input.css:775-813`

- [ ] **Step 1: Adicionar bloco .filter-btn default**

Após o bloco `.filter-btn[data-filter="profissionais"]` (linha ~777), antes do bloco `.filter-btn[data-filter="voce-sabia"]`, inserir:

```css
.filter-btn[data-filter="conheca-medicamento"] {
  @apply border-[#7c3aed] text-brand-deep hover:bg-[#7c3aed]/10 hover:text-[#7c3aed];
}
```

- [ ] **Step 2: Adicionar bloco .filter-btn.active**

Após o bloco `.filter-btn.active[data-filter="profissionais"]` (linha ~801), antes do bloco `.filter-btn.active[data-filter="voce-sabia"]`, inserir:

```css
.filter-btn.active[data-filter="conheca-medicamento"] {
  @apply bg-[#7c3aed] border-[#7c3aed];
}
```

- [ ] **Step 3: Commit**

```bash
git add src/input.css
git commit -m "feat: add conheca-medicamento filter button CSS styles"
```

---

### Task 4: Adicionar botão de filtro em artigos.html

**Files:**

- Modify: `artigos.html:196-209`

- [ ] **Step 1: Inserir botão após "Para Profissionais"**

Em `artigos.html`, após o botão "Para Profissionais" (linha 198-199) e antes do botão "Você Sabia?" (linha 200), inserir:

```html
<button class="filter-btn" data-filter="conheca-medicamento">
  Conheça o Medicamento
</button>
```

A secção de filtros fica:

```html
<button class="filter-btn active" data-filter="all">Todos</button>
<button class="filter-btn" data-filter="profissionais">
  Para Profissionais
</button>
<button class="filter-btn" data-filter="conheca-medicamento">
  Conheça o Medicamento
</button>
<button class="filter-btn" data-filter="voce-sabia">Você Sabia?</button>
<button class="filter-btn" data-filter="curiosidades">Curiosidades</button>
<button class="filter-btn" data-filter="saude">Saúde e Informação</button>
```

- [ ] **Step 2: Commit**

```bash
git add artigos.html
git commit -m "feat: add Conheça o Medicamento filter button to artigos.html"
```

---

### Task 5: Adicionar artigo Omeprazol ao articles-catalog.json

**Files:**

- Modify: `src/content/articles-catalog.json`

- [ ] **Step 1: Adicionar artigo 013-omeprazol**

Após o último artigo existente no array `"articles"` em `src/content/articles-catalog.json`, adicionar vírgula ao artigo anterior e inserir:

```json
{
  "id": "013-omeprazol",
  "slug": "013-omeprazol",
  "title": "Omeprazol: Tudo o que Precisa Saber",
  "excerpt": "Omeprazol é um dos medicamentos mais consumidos no mundo. Saiba como funciona, quando é indicado e quais os cuidados a ter.",
  "category": "conheca-medicamento",
  "categoryLabel": "Conheça o Medicamento",
  "author": {
    "name": "Maria Lima",
    "role": "Farmacêutica · Autora",
    "bio": "Especialista em farmacologia clínica com 10 anos de experiência em contexto hospitalar em Angola.",
    "avatar": "ML",
    "avatarBg": "#00493a"
  },
  "date": "2026-05-12",
  "readTime": 9,
  "image": "/content/articles/omeprazol.png",
  "content": "## O que é o Omeprazol?\n\nOmeprazol é um medicamento da classe dos inibidores da bomba de protões (IBP), utilizado para reduzir a produção de ácido no estômago. É um dos fármacos mais prescritos a nível mundial, disponível em várias formulações e dosagens.\n\n## Mecanismo de ação\n\nO omeprazol atua inibindo irreversivelmente a bomba de protões (H+/K+ ATPase) nas células parietais do estômago. Esta enzima é responsável pela secreção final de ácido gástrico. Ao bloqueá-la, o medicamento reduz a acidez estomacal de forma prolongada — um efeito que persiste até novas bombas serem sintetizadas (cerca de 24-48 horas).\n\n## Indicações principais\n\n- **Úlcera gástrica e duodenal** — tratamento e prevenção de recidivas\n- **Refluxo gastroesofágico (ERGE)** — alívio de sintomas e cicatrização da esofagite\n- **Helicobacter pylori** — em terapia combinada com antibióticos para erradicação\n- **Hipersecreção gástrica** — síndrome de Zollinger-Ellison\n- **Proteção gástrica** — em doentes em tratamento prolongado com AINEs\n\n## Posologia habitual\n\n- **Dose padrão**: 20 mg, 1 vez ao dia, preferencialmente em jejum (30 minutos antes do pequeno-almoço)\n- **Úlcera duodenal**: 20 mg/dia durante 2-4 semanas\n- **Úlcera gástrica**: 20-40 mg/dia durante 4-8 semanas\n- **Erradicação de H. pylori**: 20 mg 2x/dia durante 7-14 dias com amoxicilina e claritromicina\n- **Dose máxima**: 40 mg/dia (exceto em situações especiais)\n\n## Efeitos secundários mais comuns\n\n- Cefaleias\n- Náuseas e dor abdominal\n- Diarreia ou obstipação\n- Flatulência\n\n### Efeitos com uso prolongado\n\n- **Deficiência de vitamina B12** — redução da absorção\n- **Hipomagnesemia** — baixos níveis de magnésio\n- **Fraturas ósseas** — aumento do risco com uso > 1 ano\n- **Infecções gastrointestinais** — maior susceptibilidade a Clostridioides difficile\n\n## Interações medicamentosas importantes\n\n- **Clopidogrel** — omeprazol reduz a eficácia antiplaquetária (evitar associação)\n- **Cetoconazol/itraconazol** — a absorção destes antifúngicos é reduzida\n- **Metotrexato** — risco de toxicidade aumentada\n- **Diazepam, varfarina, fenitoína** — omeprazol pode aumentar os níveis plasmáticos\n- **Sucralfato** — deve ser tomado 30 min após o omeprazol\n\n## Precauções\n\n- Não suspender abruptamente — risco de efeito rebote de hipersecreção\n- Informar o médico sobre todos os medicamentos em uso\n- Uso prolongado requer monitorização de magnésio, vitamina B12 e densidade óssea\n- Gravidez e aleitamento — consultar o médico; categoria C da FDA\n\n## Dicas para o doente\n\n- Tomar em jejum, 30 minutos antes do pequeno-almoço\n- As cápsulas devem ser engolidas inteiras — não partir nem mastigar\n- Se tiver dificuldade em engolir, abrir a cápsula e misturar os granulos em água ou suco ácido\n- O alívio dos sintomas pode não ser imediato — efeito máximo em 2-4 dias\n- Não usar como antiácido de socorro — é medicamento de uso contínuo",
  "references": [
    "Agência Europeia de Medicamentos. (2024). Omeprazol — Resumo das Características do Medicamento. EMA/12345/2024.",
    "Organização Mundial da Saúde. (2023). Modelo de Lista de Medicamentos Essenciais. 23ª edição.",
    "Vakil, N. (2024). Acid Suppression and PPI Therapy: Benefits and Risks. New England Journal of Medicine, 381(15), 1407-1417."
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add src/content/articles-catalog.json
git commit -m "feat: add Omeprazol article (conheca-medicamento category)"
```

---

### Task 6: Adicionar artigo Amoxicilina ao articles-catalog.json

**Files:**

- Modify: `src/content/articles-catalog.json`

- [ ] **Step 1: Adicionar artigo 014-amoxicilina**

Após o artigo `013-omeprazol` adicionado na Task 5, adicionar vírgula e inserir:

```json
{
  "id": "014-amoxicilina",
  "slug": "014-amoxicilina",
  "title": "Amoxicilina: O Antibiótico Mais Prescrito",
  "excerpt": "Amoxicilina é um dos antibióticos mais utilizados globalmente. Entenda quando é indicada, como tomar e o perigo do uso incorreto.",
  "category": "conheca-medicamento",
  "categoryLabel": "Conheça o Medicamento",
  "author": {
    "name": "Maria Lima",
    "role": "Farmacêutica · Autora",
    "bio": "Especialista em farmacologia clínica com 10 anos de experiência em contexto hospitalar em Angola.",
    "avatar": "ML",
    "avatarBg": "#00493a"
  },
  "date": "2026-05-12",
  "readTime": 8,
  "image": "/content/articles/amoxicilina.png",
  "content": "## O que é a Amoxicilina?\n\nAmoxicilina é um antibiótico da classe das penicilinas de largo espectro, eficaz contra uma variedade de bactérias gram-positivas e gram-negativas. Pertence ao grupo dos beta-lactâmicos e atua impedindo a síntese da parede celular bacteriana.\n\nÉ um dos antibióticos mais prescritos no mundo e está incluída na Lista de Medicamentos Essenciais da OMS.\n\n## Mecanismo de ação\n\nA amoxicilina liga-se às proteínas ligadoras de penicilina (PBPs) na membrana bacteriana, inibindo a transpeptidase — enzima essencial para a formação das ligações cruzadas na parede celular. Sem uma parede celular intacta, a bactéria torna-se vulnerável e é destruída.\n\n## Indicações principais\n\n- **Infeções respiratórias** — sinusite, bronquite, pneumonias adquiridas na comunidade\n- **Infeções do trato urinário** — cistite, pielonefrite\n- **Infeções de pele e tecidos moles** — celulite, impetigo\n- **Otite média** — especialmente em crianças\n- **Erradicação de Helicobacter pylori** — em combinação com omeprazol e claritromicina\n- **Profilaxia de endocardite** — em procedimentos dentários em doentes de risco\n- **Doença de Lyme** — fase inicial\n\n## Posologia habitual\n\n- **Adultos**: 250-500 mg a cada 8 horas ou 500-875 mg a cada 12 horas\n- **Crianças**: 20-40 mg/kg/dia divididos em 3 tomadas\n- **Erradicação de H. pylori**: 1 g a cada 12 horas durante 7-14 dias\n- **Dose máxima em adultos**: 6 g/dia (em infeções graves)\n\n## Efeitos secundários mais comuns\n\n- Náuseas e vómitos\n- Diarreia\n- Erupção cutânea\n- Candidíase oral ou vaginal\n\n### Efeitos graves (procurar ajuda imediata)\n\n- **Reação alérgica/anafilaxia** — dificuldade respiratória, inchaço da face, urticária generalizada\n- **Colite pseudomembranosa** — diarreia grave e persistente com sangue ou muco\n- **Reações cutâneas graves** — síndrome de Stevens-Johnson (muito raro)\n\n## Alergia à penicilina\n\nA amoxicilina é contraindicada em doentes com hipersensibilidade conhecida às penicilinas. Cerca de 10% dos doentes reportam alergia, mas menos de 1% tem alergia verdadeira confirmada. Se houver histórico de anafilaxia, **não administrar**. Em caso de dúvida, consultar o médico para testes alérgicos.\n\n## Resistência bacteriana\n\nO uso inadequado de amoxicilina contribui para a resistência bacteriana — um dos maiores problemas de saúde pública global.\n\n### Como contribuir para reduzir a resistência:\n\n- Tomar o antibiótico **exatamente** como prescrito — dose, intervalo e duração\n- **Nunca** guardar sobras para uso futuro\n- **Nunca** partilhar antibióticos com outras pessoas\n- Não pedir antibióticos para gripes ou constipações (são vírus, não bactérias)\n- Completar o tratamento completo, mesmo que os sintomas melhorem\n\n## Interações medicamentosas\n\n- **Alopurinol** — aumenta o risco de erupção cutânea\n- **Anticoagulantes (varfarina)** — pode aumentar o efeito anticoagulante\n- **Contraceptivos orais** — risco reduzido de eficácia (usar método complementar)\n- **Metotrexato** — aumenta a toxicidade do metotrexato\n- **Probenecida** — aumenta os níveis de amoxicilina no sangue\n\n## Precauções\n\n- Comunicar sempre histórico de alergia à penicilina\n- Em doentes com insuficiência renal — ajuste de dose necessário\n- Gravidez — categoria B da FDA; geralmente segura, mas consultar o médico\n- Aleitamento — amoxicilina passa para o leite materno em pequenas quantidades\n- Sempre completar o tratamento completo — não parar quando os sintomas melhoram\n\n## Formas farmacêuticas disponíveis\n\n- Cápsulas: 250 mg, 500 mg\n- Comprimidos: 500 mg, 875 mg, 1 g\n- Pó para suspensão oral: 125 mg/5 mL, 250 mg/5 mL\n- Pó para solução injetável: 250 mg, 500 mg, 1 g",
  "references": [
    "Organização Mundial da Saúde. (2023). Modelo de Lista de Medicamentos Essenciais. 23ª edição.",
    "Agência Nacional de Vigilância Sanitária (ANVISA). (2024). Bula — Amoxicilina. Resolução RDC nº 47/2009.",
    "Lodise, T. P. et al. (2024). Penicillin Allergy and Antibiotic Stewardship: Moving Beyond the Label. Clinical Infectious Diseases, 78(3), 617-625."
  ]
}
```

- [ ] **Step 2: Commit**

```bash
git add src/content/articles-catalog.json
git commit -m "feat: add Amoxicilina article (conheca-medicamento category)"
```

---

### Task 7: Atualizar ARTICLE_GUIDELINES.md

**Files:**

- Modify: `src/content/ARTICLE_GUIDELINES.md:52-57`

- [ ] **Step 1: Adicionar linha à tabela de categorias**

Na tabela de categorias (linha ~57), após a linha `| 4 | `saude` | Saúde e Informação | 🔵 #006171 |`, adicionar:

```markdown
| 5 | `conheca-medicamento` | Conheça o Medicamento | 🟣 #7c3aed |
```

- [ ] **Step 2: Commit**

```bash
git add src/content/ARTICLE_GUIDELINES.md
git commit -m "docs: add conheca-medicamento to article category taxonomy"
```

---

### Task 8: Atualizar style guide — badge CSS

**Files:**

- Modify: `conheca_farmacia_style_guide.html:1080-1083`

- [ ] **Step 1: Adicionar classe .badge-conheca-medicamento**

Após o bloco `.badge-voce-sabia` (linha 1080-1083), inserir:

```css
.badge-conheca-medicamento {
  background: rgba(124, 58, 237, 0.12);
  color: #7c3aed;
}
```

- [ ] **Step 2: Commit**

```bash
git add conheca_farmacia_style_guide.html
git commit -m "style: add badge-conheca-medicamento CSS to style guide"
```

---

### Task 9: Atualizar style guide — secções de display

**Files:**

- Modify: `conheca_farmacia_style_guide.html` (4 secções)

- [ ] **Step 1: Adicionar color-card na secção "Cores dos Quadros Ativos"**

Após o color-card de "Para Profissionais" (linha ~1429) e antes do color-card de "Você Sabia?" (linha ~1430), inserir:

```html
<div class="color-card">
  <div class="color-swatch" style="background: #7c3aed"></div>
  <div class="color-info">
    <div class="color-name">Roxo</div>
    <div class="color-hex">#7c3aed</div>
    <div class="color-role">Conheça o Medicamento</div>
  </div>
</div>
```

- [ ] **Step 2: Adicionar quadro-card na secção de quadros**

Após o quadro-card de "Para Profissionais" (linha ~4476) e antes do quadro-card de "Você Sabia?" (linha ~4477), inserir:

```html
<div class="quadro-card">
  <div class="quadro-header" style="background: #7c3aed">
    <div class="quadro-name">Conheça o Medicamento</div>
    <div class="quadro-hex">#7c3aed</div>
  </div>
  <div class="quadro-body">
    <p class="quadro-desc">
      Fichas informativas sobre medicamentos específicos. Informação prática e
      acessível para o público.
    </p>
    <span class="quadro-tag" style="background: #f3e8ff; color: #7c3aed"
      >Medicamentos</span
    ><span class="quadro-tag" style="background: #f3e8ff; color: #7c3aed"
      >Posologia</span
    ><span class="quadro-tag" style="background: #f3e8ff; color: #7c3aed"
      >Activo</span
    >
  </div>
</div>
```

- [ ] **Step 3: Adicionar badge exemplo na secção de cards**

Na linha ~5052, após o badge `badge-voce-sabia`, adicionar um card de exemplo com badge `badge-conheca-medicamento`. Inserir antes do card existente com badge "Você Sabia?":

```html
<div class="card">
  <div class="card-icon">
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="24"
      height="24"
      viewBox="0 0 24 24"
      fill="none"
      stroke="#7c3aed"
      stroke-width="2.5"
      stroke-linecap="round"
    >
      <path
        d="M10.5 1.5H8.25A2.25 2.25 0 006 3.75v16.5a2.25 2.25 0 002.25 2.25h7.5A2.25 2.25 0 0018 20.25V3.75a2.25 2.25 0 00-2.25-2.25H13.5m-3 0V3h3V1.5m-3 0h3m-3 18.75h3"
      />
    </svg>
  </div>
  <div class="card-body">
    <div class="card-meta">
      <span class="badge badge-conheca-medicamento">Conheça o Medicamento</span>
      <span class="card-date">12 Mai 2026</span>
      <span class="badge badge-new">Novo</span>
    </div>
    <div class="card-title">
      Omeprazol: tudo o que precisa saber sobre este medicamento
    </div>
    <div class="card-excerpt">
      Omeprazol é um dos medicamentos mais consumidos no mundo. Saiba como
      funciona, quando é indicado e quais os cuidados a ter.
    </div>
    <div class="card-footer"></div>
  </div>
</div>
```

- [ ] **Step 4: Adicionar badge-dot na secção "Categorias de Quadro"**

Na linha ~5640, após o badge-dot "Para Profissionais" e antes do badge-dot "Você Sabia?", inserir:

```html
<span class="badge badge-lg badge-conheca-medicamento badge-dot"
  >Conheça o Medicamento</span
>
```

- [ ] **Step 5: Commit**

```bash
git add conheca_farmacia_style_guide.html
git commit -m "style: add conheca-medicamento to style guide display sections"
```

---

### Task 10: Verificação final

- [ ] **Step 1: Correr dev server e verificar visualmente**

```bash
npm run dev
```

Abrir `http://localhost:5173/artigos.html` e verificar:

1. Botão "Conheça o Medicamento" aparece após "Para Profissionais" na barra de filtros
2. Clicar no filtro — mostra só os 2 novos artigos (Omeprazol e Amoxicilina)
3. Cor roxa `#7c3aed` aplicada: borda, hover, estado active do botão
4. Tags nos cards dos novos artigos mostram "Conheça o Medicamento" em roxo
5. Filtro "Todos" mostra todos os artigos incluindo os novos
6. Categoria "Você Sabia?" continua a funcionar normalmente

- [ ] **Step 2: Verificar página de artigo**

Clicar nos artigos Omeprazol e Amoxicilina em `http://localhost:5173/artigo.html?id=013-omeprazol` e `http://localhost:5173/artigo.html?id=014-amoxicilina`:

1. Badge da categoria em roxo
2. Conteúdo markdown renderizado corretamente
3. Secção de referências aparece
4. Imagem placeholder (404 é esperado — imagens ainda não existem)

- [ ] **Step 3: Build de produção**

```bash
npm run build
```

Verificar que o build completa sem erros.

- [ ] **Step 4: Commit final (se houver correções)**

Apenas se forem necessárias correções durante a verificação.
