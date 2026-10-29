/**
 * Esqueleto do perfil de estudante dentro do AccountShell.
 *
 * A composição é a da página real — cabeçalho, faixa de números e um painel
 * largo — para o primeiro pintar e o conteúdo final não saltarem de sítio.
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
        <div style={bar(120, 10, 0.45)} />
        <div style={{ ...bar(240, 30, 0.3), marginTop: 8 }} />
        <div style={{ ...bar(320, 12, 0.25), marginTop: 8 }} />
      </div>

      <div className="conta-stats" aria-hidden="true">
        {Array.from({ length: 4 }).map((_, i) => (
          <div className="conta-stat" key={i}>
            <div style={bar(84, 9, 0.35)} />
            <div style={{ ...bar(56, 26, 0.22), marginTop: 10 }} />
          </div>
        ))}
      </div>

      <div className="conta-grid2" style={{ marginTop: '1rem' }}>
        <div className="conta-panel" style={{ height: 260, opacity: 0.18 }} />
        <div className="conta-panel" style={{ height: 180, opacity: 0.14 }} />
      </div>
    </main>
  )
}
