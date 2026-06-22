// QR code generator using the `qrcode` package. Returns a data URL
// (PNG, base64) for direct embedding into Satori output.
//
// We use level M error correction — sufficient for short validation URLs
// that are re-validated server-side. The QR is small enough (~200px) to
// be readable by any standard mobile scanner.

import qrcode from 'qrcode'

export async function getQrDataUrl(text, size = 200) {
  return qrcode.toDataURL(text, {
    type: 'image/png',
    width: size,
    margin: 1,
    errorCorrectionLevel: 'M',
    color: {
      dark: '#002a32',
      light: '#ffffff',
    },
  })
}
