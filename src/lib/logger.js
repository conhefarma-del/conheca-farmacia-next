/**
 * Logger condicional — só mostra em ambiente de desenvolvimento.
 * Em produção, log/warn são silenciados. Erros permanecem ativos.
 */
const isDev = import.meta.env.DEV;

export const logger = {
  log: isDev ? console.log.bind(console) : () => {},
  warn: isDev ? console.warn.bind(console) : () => {},
  info: isDev ? console.info.bind(console) : () => {},
  debug: isDev ? console.debug.bind(console) : () => {},
  error: console.error.bind(console),
};
