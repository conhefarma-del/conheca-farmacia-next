import { loadTranslations, t as translate } from '@/lib/i18n'

/**
 * Idioma da área de conta.
 *
 * As rotas de `(identidade)` vivem na raiz (`/perfil`, sem `[lang]`), por isso
 * o idioma não vem do URL: vem da preferência que a pessoa escolheu em
 * `/perfil/preferencias`, guardada em `user_metadata`. Sem preferência, PT —
 * é o idioma do produto, não um fallback de conveniência.
 */
export function accountLang(user) {
  const meta = user?.user_metadata || {}
  const escolhido = meta.lang || meta.preferred_lang || meta.idioma
  return escolhido === 'en' ? 'en' : 'pt'
}

/** Locale para datas — `en-GB` mantém o dia antes do mês, como em PT. */
export function accountLocale(lang) {
  return lang === 'en' ? 'en-GB' : 'pt-PT'
}

/**
 * Tradutor para Server Components do perfil.
 *
 * Devolve também `lang` e `translations` para quem precisa de os passar ao
 * `LangProvider` ou de formatar datas. `escape: false` porque estas chaves são
 * texto de UI escrito por nós (não vêm de input), e escapar aqui só produziria
 * `&amp;` visível em frases como «Segurança e palavra-passe».
 */
export function accountTranslator(user) {
  const lang = accountLang(user)
  const translations = loadTranslations(lang)
  return {
    lang,
    translations,
    t: (key, params) => translate(translations, key, params, { escape: false }),
  }
}
