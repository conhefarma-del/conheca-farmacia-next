-- 247: Terms of Use sections (hierarchical, mirrors privacy_sections structure)
CREATE TABLE IF NOT EXISTS public.terms_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES public.terms_sections(id) ON DELETE CASCADE,
  anchor_slug TEXT UNIQUE NOT NULL,
  title_pt TEXT NOT NULL,
  title_en TEXT NOT NULL,
  content_pt TEXT NOT NULL DEFAULT '',
  content_en TEXT NOT NULL DEFAULT '',
  level INT NOT NULL DEFAULT 1 CHECK (level IN (1, 2)),
  pending BOOLEAN NOT NULL DEFAULT false,
  sort_order INT NOT NULL DEFAULT 0,
  is_archived BOOLEAN NOT NULL DEFAULT false,
  archived_at TIMESTAMPTZ,
  archived_by UUID,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- RLS
ALTER TABLE public.terms_sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_all_terms_sections" ON public.terms_sections
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.admin_users WHERE user_id = auth.uid()));

CREATE POLICY "anon_read_terms_sections" ON public.terms_sections
  FOR SELECT TO anon, authenticated
  USING (is_archived = false);

CREATE TRIGGER set_terms_sections_updated_at
  BEFORE UPDATE ON public.terms_sections
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Seed Terms of Use sections
INSERT INTO public.terms_sections (anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order) VALUES
  ('aceitacao', '1. Aceitação dos Termos', '1. Acceptance of Terms',
   'Ao aceder e utilizar o website da Conheça Farmácia (conhecafarmacia.com), concorda com estes Termos de Utilização. Se não concordar com algum dos termos, não utilize o website.',
   'By accessing and using the Conheça Farmácia website (conhecafarmacia.com), you agree to these Terms of Use. If you do not agree with any of the terms, do not use the website.',
   1, false, 1),

  ('finalidade', '2. Finalidade do Website', '2. Purpose of the Website',
   'A Conheça Farmácia é uma organização de educação e promoção da saúde. O website destina-se a:\n\n- Fornecer informação farmacológica fiável e actualizada;\n- Facilitar o acesso a eventos e formações em saúde;\n- Disponibilizar ferramentas educativas para profissionais e estudantes de saúde;\n- Promover a literacia em saúde em Angola.\n\nO website não se destina a substituir aconselhamento médico profissional.',
   'Conheça Farmácia is a health education and promotion organization. The website is intended to:\n\n- Provide reliable and up-to-date pharmacological information;\n- Facilitate access to health events and training;\n- Provide educational tools for health professionals and students;\n- Promote health literacy in Angola.\n\nThe website is not intended to replace professional medical advice.',
   1, false, 2),

  ('conta-utilizador', '3. Conta de Utilizador', '3. User Account',
   'Para aceder a determinadas funcionalidades (guardar itens, criar anotações, participar em quizzes), é necessário criar uma conta. Ao criar uma conta, concorda em:\n\n- Fornecer informações verdadeiras e actualizadas;\n- Manter a segurança da sua palavra-passe;\n- Notificar-nos imediatamente de qualquer uso não autorizado da sua conta;\n- Não partilhar as suas credenciais de acesso com terceiros.\n\nPode eliminar a sua conta a qualquer momento através da página de perfil ou contactando-nos em geral@conhecafarmacia.com.',
   'To access certain features (save items, create notes, participate in quizzes), you need to create an account. By creating an account, you agree to:\n\n- Provide true and up-to-date information;\n- Maintain the security of your password;\n- Immediately notify us of any unauthorized use of your account;\n- Not share your login credentials with third parties.\n\nYou may delete your account at any time through the profile page or by contacting us at geral@conhecafarmacia.com.',
   1, false, 3),

  ('utilizacao', '4. Utilização Aceitável', '4. Acceptable Use',
   'Ao utilizar o website, compromete-se a:\n\n- Não utilizar o website para fins ilícitos ou não autorizados;\n- Não tentar aceder não autorizado a sistemas ou redes;\n- Não transmitir vírus, malware ou código prejudicial;\n- Não interferir com o funcionamento do website;\n- Não reproduzir, duplicar ou copiar conteúdo sem autorização;\n- Respeitar os direitos de propriedade intelectual da Conheça Farmácia e de terceiros.',
   'By using the website, you agree to:\n\n- Not use the website for illicit or unauthorized purposes;\n- Not attempt unauthorized access to systems or networks;\n- Not transmit viruses, malware or harmful code;\n- Not interfere with the operation of the website;\n- Not reproduce, duplicate or copy content without authorization;\n- Respect the intellectual property rights of Conheça Farmácia and third parties.',
   1, false, 4),

  ('propriedade', '5. Propriedade Intelectual', '5. Intellectual Property',
   'Todo o conteúdo do website (textos, imagens, gráficos, logótipos, ícones, software) é propriedade da Conheça Farmácia ou de terceiros que autorizaram a sua utilização, sendo protegido pelas leis de propriedade intelectual angolanas e internacionais.\n\nÉ permitida a partilha de conteúdo do website para fins educativos, desde que citada a fonte (Conheça Farmácia).',
   'All website content (texts, images, graphics, logos, icons, software) is the property of Conheça Farmácia or third parties who have authorized its use, and is protected by Angolan and international intellectual property laws.\n\nSharing website content for educational purposes is permitted, provided the source (Conheça Farmácia) is cited.',
   1, false, 5),

  ('responsabilidade', '6. Isenção de Responsabilidade', '6. Disclaimer',
   'O conteúdo disponível no website é fornecido apenas para fins informativos e educativos. A Conheça Farmácia:\n\n- Não se responsabiliza por decisões tomadas com base na informação disponibilizada;\n- Não garante a exactidão, completude ou actualidade do conteúdo;\n- Não se responsabiliza por danos diretos ou indiretos decorrentes da utilização do website;\n- Recomenda sempre a consulta de um profissional de saúde para questões médicas específicas.',
   'The content available on the website is provided for informational and educational purposes only. Conheça Farmácia:\n\n- Is not responsible for decisions made based on the information provided;\n- Does not guarantee the accuracy, completeness or timeliness of the content;\n- Is not liable for direct or indirect damages arising from the use of the website;\n- Always recommends consulting a health professional for specific medical questions.',
   1, false, 6),

  ('links-externos', '7. Links Externos', '7. External Links',
   'O website pode conter links para websites de terceiros. Estes links são fornecidos apenas para conveniência. A Conheça Farmácia não se responsabiliza pelo conteúdo, políticas de privacidade ou práticas de websites de terceiros.',
   'The website may contain links to third-party websites. These links are provided for convenience only. Conheça Farmácia is not responsible for the content, privacy policies, or practices of third-party websites.',
   1, false, 7),

  ('suspensoes', '8. Suspensão e Cessação', '8. Suspension and Termination',
   'A Conheça Farmácia reserva-se o direito de suspender ou cessar o acesso ao website, a qualquer momento e sem aviso prévio, por violação destes Termos de Utilização ou por qualquer outro motivo justificado.',
   'Conheça Farmácia reserves the right to suspend or terminate access to the website at any time and without prior notice, for violation of these Terms of Use or for any other justified reason.',
   1, false, 8),

  ('alteracoes-termos', '9. Alterações aos Termos', '9. Changes to Terms',
   'A Conheça Farmácia reserva-se o direito de alterar estes Termos de Utilização a qualquer momento. As alterações entram em vigor imediatamente após a publicação no website. O uso continuado do website após as alterações constitui aceitação dos novos termos.',
   'Conheça Farmácia reserves the right to modify these Terms of Use at any time. Changes take effect immediately upon publication on the website. Continued use of the website after changes constitutes acceptance of the new terms.',
   1, false, 9),

  ('lei-aplicavel', '10. Lei Aplicável e Foro', '10. Applicable Law and Jurisdiction',
   'Estes Termos de Utilização são regidos pelas leis da República de Angola. Qualquer dispute decorrente da utilização do website será submetida à jurisdição exclusiva dos tribunais angolanos.',
   'These Terms of Use are governed by the laws of the Republic of Angola. Any dispute arising from the use of the website shall be submitted to the exclusive jurisdiction of the Angolan courts.',
   1, false, 10);

-- Level 2 sections for "conta-utilizador"
DO $$
DECLARE
  conta_id UUID;
BEGIN
  SELECT id INTO conta_id FROM public.terms_sections WHERE anchor_slug = 'conta-utilizador';

  INSERT INTO public.terms_sections (parent_id, anchor_slug, title_pt, title_en, content_pt, content_en, level, pending, sort_order) VALUES
  (conta_id, 'eliminacao-conta', '3.1 Eliminação de Conta', '3.1 Account Deletion',
   'Pode eliminar a sua conta a qualquer momento. Ao eliminar a sua conta:\n\n- Os seus dados pessoais serão eliminados permanentemente;\n- As suas anotações e itens guardados serão eliminados;\n- O seu histórico de participações será mantido de forma anónima para fins estatísticos.\n\nPara eliminar a sua conta, contacte-nos em geral@conhecafarmacia.com.',
   'You may delete your account at any time. When you delete your account:\n\n- Your personal data will be permanently deleted;\n- Your notes and saved items will be deleted;\n- Your participation history will be kept anonymously for statistical purposes.\n\nTo delete your account, contact us at geral@conhecafarmacia.com.',
   2, false, 1);
END $$;
