# Índice dos Guias de Estudo - Conheça Farmácia

## Visão Geral

Este diretório contém os guias de estudo estruturados para as páginas `/guia/[slug]` do website, baseados na comparação curricular entre as principais universidades angolanas.

## Arquivos Gerados

| Curso | Slug | Arquivo JSON | Duração | Universidades Comparadas |
|-------|------|--------------|---------|--------------------------|
| **Enfermagem** | `enfermagem` | `guia-enfermagem.json` | 4 anos | ISIA, UPRA, PIAGET, UNIBELAS (4 univ.) |
| **Ciências Farmacêuticas** | `ciencias-farmaceuticas` | `guia-ciencias-farmaceuticas.json` | 5 anos | ISIA (1 univ. com grade completa) |
| **Análises Clínicas e Saúde Pública** | `analises-clinicas` | `guia-analises-clinicas.json` | 4 anos | ISIA (1 univ. com grade completa) |
| **Medicina** | `medicina` | `guia-medicina.json` | 6 anos | UPRA, PIAGET (2 univ.) |

## Metodologia

### Critério de Seleção de Disciplinas
- **Frequência ≥ 75% (3/4 ou 2/2)**: Disciplina **ESSENCIAL** - aparece na maioria das grades
- **Frequência 50% (2/4 ou 1/2)**: Disciplina **IMPORTANTE** - aparece em algumas grades
- **Frequência < 50%**: Disciplina **OPCIONAL/ESPECÍFICA** - particular de uma universidade

### Regra do Ano de Consenso
Para disciplinas que aparecem em anos diferentes entre universidades, adotou-se a **moda (maior frequência)**. Exemplo: se aparece no 2º ano em 2 universidades e no 3º ano em 1, o consenso é **2º ano**.

### Duração Padrão Considerada
- Enfermagem: 4 anos (padrão Bolonha)
- Ciências Farmacêuticas: 5 anos (padrão Bolonha)
- Análises Clínicas: 4 anos (padrão Bolonha)
- Medicina: 6 anos (padrão nacional)

## Estrutura dos JSONs

Cada arquivo segue o padrão:

```json
{
  "slug": "identificador-url",
  "nome": "Nome do Curso",
  "duracaoAnos": 4,
  "descricao": "Descrição da metodologia",
  "universidadesReferencia": [...],
  "ano1": { "nome": "1º Ano - Título", "disciplinas": [...] },
  "ano2": { "nome": "2º Ano - Título", "disciplinas": [...] },
  "ano3": { "nome": "3º Ano - Título", "disciplinas": [...] },
  "ano4": { "nome": "4º Ano - Título", "disciplinas": [...] },
  "ano5": { "nome": "5º Ano - Título", "disciplinas": [...] },  // se aplicável
  "ano6": { "nome": "6º Ano - Título", "disciplinas": [...] }   // se aplicável
}
```

Cada disciplina:
```json
{
  "nome": "Nome da Disciplina",
  "frequencia": "X/Y",
  "essencial": true/false
}
```

## Fonte dos Dados

### ISIA (Instituto Superior Politécnico Internacional de Angola)
- **URL**: https://isia.co.ao/cursos
- **Método**: Navegação automatizada + extração DOM
- **Cursos extraídos**: Enfermagem, Ciências Farmacêuticas, Análises Clínicas, Medicina Dentária

### UPRA (Universidade Privada de Angola)
- **URL**: https://www.upra.ao/licenciaturas
- **Método**: Extração de PDFs oficiais
- **Arquivos**: `UPRA - ENFERMAGEM.pdf`, `UPRA - MEDICINA.pdf`, `UPRA - ENFERMAGEM 2.pdf`

### PIAGET (Universidade Jean Piaget de Angola)
- **URL**: https://www.unipiaget-angola.org/
- **Método**: Extração de PDFs oficiais
- **Arquivos**: `PIAGET - Enfermagem.pdf`, `PIAGET - Medicina Geral.pdf`

### UNIBELAS
- **URLs**: Links de referência apenas (não acessados)
- Enfermagem: https://unibelas.online/courses/enfermagem/
- Farmácia: https://unibelas.online/courses/farmacia/
- Análises Clínicas: https://unibelas.online/courses/analises-clinica/

## Arquivo de Comparação Completa

Ver `COMPARACAO_CURRICULOS.md` para a tabela detalhada com todas as disciplinas, frequências e análise por ano.

## Próximos Passos Sugeridos

1. **Validar com coordenadores de curso** das universidades parceiras
2. **Complementar com UNIBELAS** acessando as páginas de curso
3. **Adicionar bibliografia recomendada** por disciplina
4. **Criar trilhas de estudo** (básico → intermediário → avançado)
5. **Integrar com sistema de flashcards/questions** do website
6. **Adicionar carga horária/ECTS** onde disponível