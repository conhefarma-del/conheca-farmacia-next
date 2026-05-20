# Design: Dashboard de Análise para Admin CMS

## Contexto
O painel administrativo existente já foi redesignado com uma estrutura moderna, mas os cards não apresentam dados reais do Supabase. O objetivo é transformar o admin numa ferramenta de gestão estratégica, adicionando métricas de análise em tempo real consumindo diretamente do Supabase.

## Objetivo
Implementar um Dashboard de Análise que forneça insights valiosos para a gestão de conteúdo, incluindo métricas de volume, engajamento, gestão de equipa e conversão de eventos.

## Abordagem Escolhida: Evolutiva
Melhorar o dashboard existente adicionando novos cards e funcionalidades gradualmente, reutilizando o máximo possível do código atual.

## Arquitetura e Componentes

### 1. Cards Existentes - Atualização para Dados Reais
Substituir os valores simulados pelos cards existentes por consultas reais ao Supabase:

- **Páginas**: Total de artigos publicados (tabela `articles`, status = 'published')
- **Posts**: Total de eventos publicados (tabela `events`, status = 'published')  
- **Utilizadores**: Total de admin users ativos (tabela `admin_users`)
- **Ficheiros**: Total de uploads no Supabase Storage (requer função edge ou contagem alternativa)
- **Categorias**: Número de categorias únicas utilizadas em artigos/eventos/lives
- **Comentários**: Placeholder para futura implementação (sistema de comentários)

### 1.1. Barra de Pesquisa Funcional
Tornar funcional a barra de pesquisa existente no topo do dashboard (admin-search-input) para permitir busca em tempo real por:
- Artigos (por título, conteúdo, autor)
- Eventos (por título, descrição, localização)
- Lives (por título, descrição)
- Usuários admin (por nome, email)

### 2. Novos Cards de Análise
Adicionar seção de métricas rápidas com:

#### A. Métricas de Volume e Cadência
- **Total de Subscritores**: Contagem da tabela de newsletter (a ser criada)
- **Total de Conteúdos**: Soma de artigos, eventos e lives publicados
- **Cadência Mensal**: Quantos artigos foram publicados nos últimos 30 dias

#### B. Métricas de Engajamento e Relevância
- **Distribuição por Categoria**: Gráfico circular (pizza) mostrando publicações por categoria
- **Artigo mais lido**: Ranking de artigos por visualizações (requer campo `view_count` na tabela `articles`)

#### C. Gestão de Equipa (Baseado na audit_logs)
- **Atividade Recente**: Feed interno mostrando ações recentes dos admins (últimas 10 ações)
- **Líder de Publicações**: Admin que publicou mais conteúdo no período

#### D. Conversão de Eventos
- **Taxa de Preenchimento**: Para o próximo evento, % de inscrições em relação à capacidade

### 3. Fluxo de Dados
1. Supabase Client já configurado em `src/config.js` e `src/lib/supabaseClient.js`
2. Funções de API existentes em `src/lib/api.js` para artigos, eventos e lives
3. Novas funções de API serão adicionadas para:
   - Contagem de inscritos (newsletter table)
   - Métricas de agregação (contagens, agrupamentos)
   - Dados de auditoria (audit_logs table)
   - Estatísticas de eventos (próximos eventos, taxas de preenchimento)

### 4. Bibliotecas e Dependências
- **Chart.js**: Já utilizada no dashboard existente para gráficos
- **Supabase JS Client**: Já integrado no projeto
- **Date-fns ou native Date**: Para cálculos de data (últimos 30 dias)

### 5. Estrutura de Arquivos a Modificar
- `src/admin/dashboard.html`: Estrutura dos cards e containers
- `src/admin/dashboard.js`: Lógica de carregamento e renderização
- `src/lib/api.js`: Novas funções de API para métricas de análise
- `src/config.js`: Verificar se precisa de ajustes no Supabase client

### 6. Novas Tabelas Necessárias
- **newsletter**: Para armazenar inscritos (email, nome, data_inscricao, status)
- **view_count** (opcional): Coluna na tabela `articles` para rastrear visualizações
- **event_registrations** (opcional): Para rastrear inscrições em eventos

### 7. Segurança e RLS
Todas as novas tabelas terão políticas RLS aplicadas:
- Público: Acesso apenas a dados agregados (não dados pessoais)
- Admins: Acesso completo para gestão

### 8. Tratamento de Erros e Loading States
- Indicadores de carregamento enquanto buscam dados
- Mensagens de erro amigáveis em caso de falha
- Fallback para valores simulados em caso de indisponibilidade do Supabase

### 9. Performance e Cache
- Consultas otimizadas com índices apropriados
- Cache de 15-30 segundos para métricas que não exigem tempo real
- Evitar consultas pesadas em intervalos curtos

### 10. Responsividade
- Layout adaptável para mobile e desktop
- Cards que se reorganizam conforme o tamanho da tela
- Gráficos que mantêm legibilidade em telas menores

## Verificação de Implementação
Para validar que o dashboard está funcionando corretamente:

1. **Teste de Conexão**: Verificar se o dashboard carrega sem erros de conexão com Supabase
2. **Dados Reais**: Confirmar que os valores exibidos correspondem aos dados reais no Supabase
3. **Atualização em Tempo Real**: Validar que as métricas são atualizadas após mudanças no CMS
4. **Responsividade**: Testar em diferentes tamanhos de tela
5. **Tratamento de Erros**: Simular falhas de rede e verificar comportamento adequado
6. **Performance**: Medir tempo de carregamento e garantir que permanece aceitável

## Próximos Passos
Após aprovação deste design, criar o plano de implementação detalhado usando a skill `writing-plans`.