// Client Component that renders the public validation receipt.
// Receives already-masked data from app/validar/[ref]/page.js — never
// the raw attendee email or full name.

export default function ValidarBilhete({ data }) {
  const { ref, attendeePartial, attendeeEmailMasked, issuedAt, event } = data

  const eventDateLabel = event?.date
    ? new Intl.DateTimeFormat('pt-PT', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      }).format(new Date(event.date))
    : ''
  const eventTimeLabel = event?.time ? `${event.time}` : ''

  return (
    <div className="validar-page">
      <header className="validar-header">
        <div className="validar-check" aria-hidden="true">
          <svg
            viewBox="0 0 24 24"
            width="48"
            height="48"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.5"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d="M20 6 9 17l-5-5" />
          </svg>
        </div>
        <h1>Inscrição validada</h1>
        <p>
          Esta referência corresponde a uma inscrição confirmada na nossa
          base de dados.
        </p>
      </header>

      <article className="comprovativo-bilhete" aria-label="Comprovativo">
        {/* CANHOTO */}
        <aside className="comprovativo-stub">
          <div className="comprovativo-stub-brand">
            <img
              src="/logo/logo-principal-branco.png"
              alt="Conheça Farmácia"
              className="comprovativo-stub-logo"
            />
          </div>
          <div className="comprovativo-stub-ref">
            <div className="comprovativo-stub-label">Referência</div>
            <div className="comprovativo-stub-refcode">{ref}</div>
          </div>
          <div className="comprovativo-stub-tagline">
            Validado em {new Date().toLocaleDateString('pt-PT')}
          </div>
        </aside>

        {/* MAIN */}
        <div className="comprovativo-main">
          {event && (
            <section className="comprovativo-event">
              <div className="comprovativo-event-label">Evento</div>
              <h2 className="comprovativo-event-name">{event.title}</h2>
              {(eventDateLabel || event.location) && (
                <div className="comprovativo-meta" style={{ marginTop: 12 }}>
                  {eventDateLabel && (
                    <div className="comprovativo-meta-cell">
                      <strong>Data</strong>
                      <span>{eventDateLabel}</span>
                    </div>
                  )}
                  {eventTimeLabel && (
                    <div className="comprovativo-meta-cell">
                      <strong>Hora</strong>
                      <span>{eventTimeLabel}</span>
                    </div>
                  )}
                  {event.location && (
                    <div className="comprovativo-meta-cell comprovativo-meta-cell--full">
                      <strong>Local</strong>
                      <span>{event.location}</span>
                    </div>
                  )}
                </div>
              )}
            </section>
          )}

          <section className="comprovativo-event">
            <div className="comprovativo-event-label">Inscrito</div>
            <div className="comprovativo-event-name" style={{ fontFamily: 'var(--font-sans)' }}>
              {attendeePartial}
            </div>
            <div
              style={{
                marginTop: 6,
                fontSize: 14,
                color: 'var(--color-brand-deep, #002a32)',
                opacity: 0.75,
                fontFamily: 'ui-monospace, monospace',
              }}
            >
              {attendeeEmailMasked}
            </div>
          </section>

          <footer className="comprovativo-footer">
            <div>Emitida em {issuedAt}</div>
            <div>conhecafarmacia.com</div>
          </footer>
        </div>
      </article>

      <p className="validar-note">
        Referência validada em {new Date().toLocaleString('pt-PT')}.
        Para questões, contacte{' '}
        <a href="mailto:contato@conhecafarmacia.com">
          contato@conhecafarmacia.com
        </a>
        .
      </p>
    </div>
  )
}
