-- 036: FAQ "Como me inscrevo num evento?" — resposta pública
-- Remove o placeholder [a confirmar] e publica a resposta (PT/EN) na tab "geral".
-- O texto descreve o processo real do website (botão Inscrever-me no evento,
-- campos obrigatórios, consentimento de menor, comprovativo + email, capacidade).
UPDATE public.faq_questions
SET answer_pt = 'Na página de detalhes do evento, carregue no botão "Inscrever-me". Preencha o formulário com os seus dados — nome, email, telefone e profissão são obrigatórios; os restantes campos são opcionais, exceto a faixa etária. Participantes menores de 18 anos devem confirmar o consentimento do respetivo responsável legal. Após a submissão, recebe de imediato um comprovativo de inscrição com uma referência única e uma confirmação é enviada para o seu email. As inscrições estão sujeitas à capacidade de cada evento.',
    answer_en = 'On the event detail page, click the "Register" button. Fill in the form with your details — name, email, phone and profession are required; the remaining fields are optional, except the age range. Participants under 18 must confirm the consent of their legal guardian. After submitting, you immediately receive a registration receipt with a unique reference, and a confirmation is sent to your email. Registrations are subject to each event''s capacity.',
    pending = false,
    updated_at = now()
WHERE tab_id = (SELECT id FROM public.faq_tabs WHERE slug = 'geral')
  AND question_pt = 'Como me inscrevo num evento?';
