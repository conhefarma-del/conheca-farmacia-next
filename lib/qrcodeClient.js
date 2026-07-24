/**
 * Gera QR code data URL a partir de um texto.
 * Usa dynamic import do package `qrcode` (client-side) para evitar bundling.
 * O mesmo padrão usado em InscricaoBilhete (InscricaoPageClient.jsx).
 *
 * @param {string} text - Texto/URL a codificar no QR
 * @param {object} [options] - Opções adicionais para qrcode.toDataURL
 * @returns {Promise<string|null>} Data URL da imagem PNG ou null em caso de erro
 */
export async function qrcodeLib(text, options = {}) {
  try {
    const { default: qrcode } = await import('qrcode')
    return qrcode.toDataURL(text, {
      type: 'image/png',
      width: 200,
      margin: 0,
      errorCorrectionLevel: 'M',
      color: { dark: '#002a32', light: '#ffffff' },
      ...options,
    })
  } catch (err) {
    console.warn('[qrcodeLib] Falha ao gerar QR:', err)
    return null
  }
}
