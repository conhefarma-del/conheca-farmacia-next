/**
 * Esqueleto das definições dentro do AccountShell.
 *
 * Duas colunas de painéis, como a página real (formulário à esquerda, conta
 * à direita) — sem o hero de artigo que aqui não existe.
 */
export default function Loading() {
  const bar = (width, height, opacity) => ({
    width,
    height,
    borderRadius: 6,
    background: 'var(--color-brand-divider)',
    opacity,
  })

  return (
    <main className="conta-page">
      <div style={{ marginBottom: '1.25rem' }}>
        <div style={bar(100, 10, 0.45)} />
        <div style={{ ...bar(200, 28, 0.3), marginTop: 8 }} />
        <div style={{ ...bar(280, 12, 0.25), marginTop: 8 }} />
      </div>

      <div className="conta-grid2">
        <div>
          <div className="conta-panel" style={{ height: 210, opacity: 0.2 }} />
          <div className="conta-panel" style={{ height: 150, marginTop: '1rem', opacity: 0.16 }} />
        </div>
        <div>
          <div className="conta-panel" style={{ height: 130, opacity: 0.18 }} />
          <div className="conta-panel" style={{ height: 110, marginTop: '1rem', opacity: 0.14 }} />
        </div>
      </div>
    </main>
  )
}
