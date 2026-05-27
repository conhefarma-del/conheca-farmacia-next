export default function HostCard({ host, categoryColor }) {
  if (!host || !host.nome) return null

  const color = categoryColor || '#00493a'
  const initials = host.nome
    .split(' ')
    .map(w => w[0])
    .join('')
    .slice(0, 2)
    .toUpperCase()

  return (
    <div className="host-card-event">
      <div
        className="speaker-avatar"
        style={{ backgroundColor: color }}
      >
        {initials}
      </div>
      <div>
        <h3 className="speaker-name">{host.nome}</h3>
        {host.cargo && <p className="speaker-role">{host.cargo}</p>}
        {host.organizacao && <p className="speaker-org">{host.organizacao}</p>}
      </div>
    </div>
  )
}
