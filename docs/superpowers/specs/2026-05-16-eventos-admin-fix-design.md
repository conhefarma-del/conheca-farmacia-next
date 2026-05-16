# Design: Correções no Admin de Eventos

## Visão Geral
Este documento descreve as correções necessárias no admin de eventos para resolver as seguintes issues:
1. Categoria "curso" incorretamente labelada como "Curso" em vez de "Congresso"
2. Falta de suporte frontend para categorias "seminario" e "outro" 
3. Página eventos.html não exibindo dados atualizados do Supabase
4. Clareza sobre funcionamento do link de inscrição

## Problemas Identificados

### 1. Mapeamento Incorreto de Categoria
**Local**: `src/admin/eventos/new.html` e `src/admin/eventos/edit.html`
**Problema**: A opção `<option value="curso">Curso</option>` deveria ser `<option value="curso">Congresso</option>`

### 2. Falta de Suporte Frontend para Categorias
**Local**: 
- `eventos.html` (filtros e cores)
- `src/content/events-catalog.json` (dados de fallback)
- `src/events-logic.js` (lógica de renderização)

**Problema**: As categorias "seminario" e "outro" existem no admin mas:
- Não têm cores definidas no CSS
- Não aparecem como opções de filtro em eventos.html
- Não existem exemplos no JSON de fallback

### 3. Fonte de Dados da Página de Eventos
**Local**: `src/events-logic.js`
**Observação**: A página atualmente importa dados estáticos de `./content/events-catalog.json` em vez de buscar do Supabase

### 4. Link de Inscrição
**Confirmação**: O link de inscrição já está disponível na página evento.html através do botão "Inscrever-me"
**Funcionamento**: O link é salvo no Supabase (campo registration_link) e usado na página de detalhe

## Solução Proposta

### Correção Imediata: Label da Categoria
**Arquivos**: `src/admin/eventos/new.html` e `src/admin/eventos/edit.html`
**Alteração**: 
```diff
- <option value="curso">Curso</option>
+ <option value="curso">Congresso</option>
```

### Melhoria de Suporte às Categorias
#### 3.1 Definição de Cores
Adicionar mapeamento de cores para todas as categorias em um local central (ex: `src/config.js` ou arquivo de constantes)

#### 3.2 Atualização do JSON de Fallback
Adicionar exemplos de eventos com categorias "seminario" e "outro" em `src/content/events-catalog.json`

#### 3.3 Atualização dos Filtros HTML
Adicionar opções de filtro para "seminario" e "outro" em `eventos.html`

### Melhoria de Fonte de Dados
Modificar `src/events-logic.js` para:
1. Buscar eventos do Supabase via `getEvents()` da API
2. Manter o JSON de fallback como backup
3. Implementar lógica de merge ou fallback adequada

### Manutenção do Link de Inscrição
Nenhuma alteração necessária pois já está funcionando conforme esperado.

## Arquivos a Modificar

### 1. Correção de Label (Imediata)
- `src/admin/eventos/new.html` - linha ~42
- `src/admin/eventos/edit.html` - linha ~43

### 2. Suporte às Categorias
- `src/config.js` ou novo arquivo de constantes - definir mapa de cores
- `src/content/events-catalog.json` - adicionar eventos de exemplo
- `eventos.html` - adicionar opções de filtro
- `src/events-logic.js` - usar mapa de cores para badges

### 3. Fonte de Dados do Supabase
- `src/events-logic.js` - modificar inicialização para usar API
- Possivelmente criar função de sincronização periódica

## Critérios de Aceito

✅ Categoria "curso" aparece como "Congresso" nos formulários admin
✅ Categorias "seminario" e "outro" têm cores definidas e aparecem nos filtros
✅ Página eventos.html exibe dados do Supabase (não apenas JSON fallback)
✅ Link de inscrição continua funcionando na página de detalhe
✅ Todas as alterações respeitam as lições aprendidas do CLAUDE.md (validação JS, etc.)

## Dependências
- Supabase configurado e acessível
- Funções API em `src/lib/api.js` funcionando
- JSON de fallback atualizado

## Próximos Passos
Após aprovação deste design, seguir para:
1. Criar plano de implementação usando a skill `writing-plans`
2. Executar as alterações seguindo o plano
3. Validar com `node --check` antes de commits (conforme lições aprendidas)
4. Testar em ambiente de desenvolvimento