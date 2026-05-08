# Integração com Supabase - Instruções

## Configuração Inicial

### Variáveis de Ambiente

Adicione ao arquivo `.env`:

```
SUPABASE_URL=sua_url_aqui
SUPABASE_ANON_KEY=sua_chave_aqui
```

## Formulário de Inscrição

### Campos Obrigatórios

O formulário de inscrição deve conter os seguintes campos para a tabela `inscricoes`:

| Campo           | Tipo          | Descrição                             |
| --------------- | ------------- | ------------------------------------- |
| `nome`          | text          | Nome completo do inscrito             |
| `email`         | email         | Endereço de email válido              |
| `telefone`      | text          | Número de telefone com DDD            |
| `profissao`     | text          | Profissão ou área de atuação          |
| `origem_evento` | text          | Como conheceu o evento (fonte/origem) |
| `evento_slug`   | text          | Slug único do evento (referência)     |
| `honeypot`      | text (oculto) | Campo anti-spam (não deve ter valor)  |

### Estrutura HTML Recomendada

```html
<form id="registration-form">
  <input type="text" name="nome" placeholder="Seu nome" required />
  <input type="email" name="email" placeholder="Seu email" required />
  <input type="tel" name="telefone" placeholder="Seu telefone" required />
  <select name="profissao" required>
    <option value="">Selecione sua profissão</option>
    <option value="farmaceutico">Farmacêutico</option>
    <option value="tecnico">Técnico de Farmácia</option>
    <!-- mais opções -->
  </select>
  <select name="origem_evento" required>
    <option value="">Como conheceu este evento?</option>
    <option value="instagram">Instagram</option>
    <option value="facebook">Facebook</option>
    <option value="recomendacao">Recomendação</option>
    <option value="outro">Outro</option>
  </select>

  <!-- Campo anti-spam (oculto) -->
  <input type="hidden" name="honeypot" value="" />

  <input type="hidden" name="evento_slug" value="evento-slug-aqui" />

  <button type="submit">Inscrever-me</button>
</form>
```

### Validação no JavaScript

```javascript
// Validar que o honeypot está vazio (anti-spam)
const honeypot = document.querySelector('input[name="honeypot"]');
if (honeypot && honeypot.value !== "") {
  console.warn("⚠️ Formulário suspeito (honeypot preenchido)");
  return false;
}
```

### Envio para Supabase

```javascript
async function submitForm(formData) {
  try {
    // Verificar honeypot
    if (formData.honeypot) return false;

    const { data, error } = await supabase.from("inscricoes").insert([
      {
        nome: formData.nome,
        email: formData.email,
        telefone: formData.telefone,
        profissao: formData.profissao,
        origem_evento: formData.origem_evento,
        evento_slug: formData.evento_slug,
      },
    ]);

    if (error) throw error;
    console.log("✅ Inscrição realizada com sucesso!");
    return true;
  } catch (error) {
    console.error("❌ Erro na inscrição:", error);
    return false;
  }
}
```

## Scripts NPM

- **Dev:** `npm run dev` - Compila Tailwind em modo watch
- **Build:** `npm run build` - Compila Tailwind com minificação
- **Format:** `npm run format` - Formata código com Prettier

## Estrutura de Pastas

```
/
├── src/
│   ├── input.css
│   └── lib/
│       └── supabaseClient.js
├── dist/
│   └── output.css
├── content/
│   └── (arquivos de conteúdo JSON)
├── assets/
│   ├── images/
│   ├── icons/
│   └── logo/
├── .env
├── .gitignore
├── .prettierrc
├── package.json
└── index.html
```
