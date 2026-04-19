# Email Template - Confirmação de Inscrição

## 📧 Pré-visualização

Abra `email-template.html` no navegador para ver uma pré-visualização do email.

---

## 🎨 Características do Template

✅ **Design Responsivo**
- Funciona em desktop, tablet e mobile
- Testado em Gmail, Outlook, Apple Mail

✅ **Estilos Inline**
- Sem dependência de CSS externo
- 100% compatível com clientes de email

✅ **Elementos Dinâmicos**
- Nome do participante
- Nome do evento
- Data/hora da inscrição (formatada em português)

✅ **Estrutura Profissional**
- Header com branding
- Conteúdo principal claro
- Secção de próximos passos
- Footer com redes sociais

---

## 📝 Variáveis Disponíveis

Use estas variáveis no template:

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `${nomeParticipante}` | Nome completo do inscrito | "João Silva" |
| `${nomeEvento}` | Nome do evento | "Workshop: Farmacologia Clínica Aplicada — Módulo III" |
| `${dataFormatada}` | Data/hora da inscrição | "18 de abril de 2026, 16:47" |

---

## 🚀 Como Usar na Edge Function

### 1. Importar o Template

```typescript
import { getInscriptionEmailTemplate } from './email-template.ts';
```

### 2. Gerar o HTML

```typescript
const htmlContent = getInscriptionEmailTemplate(
  'João Silva',           // Nome do participante
  'Workshop: Farmacologia Clínica', // Nome do evento
  '2026-04-18T16:47:00Z'  // Data da inscrição (ISO 8601)
);
```

### 3. Enviar com Resend

```typescript
const response = await resend.emails.send({
  from: 'Conheça Farmácia <noreply@conhecafarmacia.com>',
  to: email_participante,
  subject: 'Confirmação de Inscrição - Conheça Farmácia',
  html: htmlContent,
});
```

---

## 🎯 Próximas Etapas

1. **Configurar Resend**
   - Criar conta em https://resend.com
   - Obter API Key

2. **Criar Edge Function**
   - Usar `email-template.ts`
   - Integrar com Resend

3. **Configurar Database Trigger**
   - Disparar função após INSERT

4. **Testar**
   - Fazer inscrição de teste
   - Verificar email recebido

---

## 📌 Notas de Compatibilidade

- ✅ Gmail (desktop, mobile)
- ✅ Outlook.com
- ✅ Apple Mail
- ✅ Yahoo Mail
- ✅ Thunderbird
- ✅ Telefones (iOS, Android)

**Não usa:**
- Tailwind CSS
- Classes externas
- Media queries (apenas viewport meta)
- Imagens externas (a menos que necessário)

---

## 🔧 Personalizações Futuras

Possíveis adições:

- [ ] Logo como imagem (base64 ou URL)
- [ ] Links dinâmicos para eventos
- [ ] Informações da localização do evento
- [ ] Horário do evento
- [ ] Instruções de acesso específicas
- [ ] Avaliação do evento (pós-evento)

---

## 📞 Contacto e Suporte

Para testar ou modificar o template:

- **Email:** conhecerfarmacia@gmail.com
- **WhatsApp:** +244 925 696 002
- **Redes Sociais:** Instagram, Facebook, LinkedIn (@conhecafarmacia)
