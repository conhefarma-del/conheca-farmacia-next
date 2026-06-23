// Page shown when a visitor scans the validation QR code but is not
// authenticated as a Conheça Farmácia administrator. The page is
// intentionally static and never exposes which IDs exist or not — to
// non-admins it looks the same regardless of the ?ref= value.

export default function ValidarBloqueado({ lang = 'pt' }) {
  const pt = lang !== 'en'

  return (
    <div className="validar-page">
      <header className="validar-header">
        <div className="validar-lock" aria-hidden="true">
          <svg
            viewBox="0 0 24 24"
            width="48"
            height="48"
            fill="none"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <rect x="3" y="11" width="18" height="11" rx="2" />
            <path d="M7 11V7a5 5 0 0 1 10 0v4" />
          </svg>
        </div>
        <h1>
          {pt
            ? 'Validação reservada a administradores'
            : 'Validation reserved to administrators'}
        </h1>
        <p>
          {pt
            ? 'Apenas administradores Conheça Farmácia conseguem validar inscrições através deste link.'
            : 'Only Conheça Farmácia administrators can validate registrations through this link.'}
        </p>
        <p className="validar-bloqueado-sub">
          {pt ? (
            <>
              Para validar a sua própria inscrição, use o botão{' '}
              <strong>Imprimir / Guardar como PDF</strong> na página de
              confirmação que recebeu após a inscrição.
            </>
          ) : (
            <>
              To validate your own registration, use the{' '}
              <strong>Print / Save as PDF</strong> button on the confirmation
              page you received after registering.
            </>
          )}
        </p>
      </header>
    </div>
  )
}
