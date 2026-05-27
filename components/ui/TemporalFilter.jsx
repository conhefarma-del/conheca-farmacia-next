'use client'

export default function TemporalFilter({ activeStatus, onStatusChange, upcomingLabel, pastLabel }) {
  return (
    <div className="flex justify-center gap-4 mb-12">
      <button
        className={`temporal-btn ${activeStatus === 'upcoming' ? 'active' : ''}`}
        onClick={() => onStatusChange('upcoming')}
      >
        {upcomingLabel || 'Próximos'}
      </button>
      <button
        className={`temporal-btn ${activeStatus === 'past' ? 'active' : ''}`}
        onClick={() => onStatusChange('past')}
      >
        {pastLabel || 'Passados'}
      </button>
    </div>
  )
}
