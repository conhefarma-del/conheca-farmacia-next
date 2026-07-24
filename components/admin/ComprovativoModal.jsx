'use client'

import { useEffect, useState, useCallback } from 'react'
import InscricaoBilhete from '@/components/pages/InscricaoBilhete'

/**
 * ComprovativoModal — slide panel da direita.
 * Reutiliza InscricaoBilhete (boarding pass) com botões de impressão/PDF.
 * Animação slideIn + overlay com backdrop-filter.
 */
export default function ComprovativoModal({ inscricao, evento, onClose }) {
  const [open, setOpen] = useState(false)
  const shortRef = String(inscricao.id).padStart(6, '0')
  const eventMeta = {
    startAt: evento?.date ? `${evento.date}T${evento.time || '00:00'}` : null,
    location: evento?.location || null,
    modality: evento?.type || null,
  }

  // Trigger entrada animada no mount
  useEffect(() => {
    requestAnimationFrame(() => setOpen(true))
  }, [])

  // Fechar com animação
  const handleClose = useCallback(() => {
    setOpen(false)
    setTimeout(onClose, 250)
  }, [onClose])

  // Escape key
  useEffect(() => {
    const onKey = (e) => { if (e.key === 'Escape') handleClose() }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [handleClose])

  return (
    <>
      {/* Overlay */}
      <div
        onClick={handleClose}
        style={{
          position: 'fixed',
          inset: 0,
          zIndex: 999,
          background: open ? 'rgba(0, 42, 50, 0.45)' : 'rgba(0, 42, 50, 0)',
          backdropFilter: open ? 'blur(4px)' : 'blur(0px)',
          WebkitBackdropFilter: open ? 'blur(4px)' : 'blur(0px)',
          transition: 'all 250ms ease-out',
        }}
      />

      {/* Panel */}
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Comprovativo de Inscrição"
        style={{
          position: 'fixed',
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: '100%',
          maxWidth: 680,
          background: '#fff',
          boxShadow: open
            ? '-8px 0 40px rgba(0, 42, 50, 0.15)'
            : '-8px 0 40px rgba(0, 42, 50, 0)',
          transform: open ? 'translateX(0)' : 'translateX(100%)',
          transition: 'transform 250ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 250ms ease-out',
          display: 'flex',
          flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        {/* Header */}
        <div
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
            padding: '20px 28px',
            borderBottom: '1px solid #e5e7eb',
            flexShrink: 0,
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div
              style={{
                width: 10,
                height: 10,
                borderRadius: '50%',
                background: '#0a844f',
                flexShrink: 0,
              }}
            />
            <h2
              style={{
                margin: 0,
                fontSize: 18,
                fontWeight: 600,
                color: '#002a32',
                fontFamily: 'Inter, sans-serif',
              }}
            >
              Comprovativo de Inscrição
            </h2>
          </div>
          <button
            type="button"
            onClick={handleClose}
            aria-label="Fechar"
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              width: 36,
              height: 36,
              borderRadius: 8,
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              color: '#6b7280',
              fontSize: 20,
              fontWeight: 300,
              lineHeight: 1,
              transition: 'all 0.15s ease',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = '#f3f4f6'
              e.currentTarget.style.color = '#002a32'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'none'
              e.currentTarget.style.color = '#6b7280'
            }}
          >
            ✕
          </button>
        </div>

        {/* Content */}
        <div
          style={{
            flex: 1,
            overflowY: 'auto',
            padding: 28,
          }}
        >
          <InscricaoBilhete
            lang="pt"
            formData={inscricao}
            profLabel={inscricao.profissao || ''}
            eventTitle={evento?.title}
            eventMeta={eventMeta}
            shortRef={shortRef}
            inscriptionDate={inscricao.created_at}
            logoSrc="/logo/logo-principal-branco.svg"
            t={(k) => k}
          />
        </div>

        {/* Footer */}
        <div
          style={{
            display: 'flex',
            gap: 12,
            justifyContent: 'flex-end',
            alignItems: 'center',
            padding: '16px 28px',
            borderTop: '1px solid #e5e7eb',
            background: '#f9fafb',
            flexShrink: 0,
          }}
        >
          <button
            type="button"
            onClick={handleClose}
            style={{
              padding: '10px 20px',
              borderRadius: 8,
              border: '2px solid #00493a',
              background: 'transparent',
              color: '#00493a',
              fontSize: 14,
              fontWeight: 500,
              fontFamily: 'Inter, sans-serif',
              cursor: 'pointer',
              transition: 'all 0.15s ease',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = 'rgba(0, 73, 58, 0.06)'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = 'transparent'
            }}
          >
            Fechar
          </button>
          <button
            type="button"
            onClick={() => window.print()}
            style={{
              padding: '10px 24px',
              borderRadius: 8,
              border: 'none',
              background: '#00493a',
              color: '#fff',
              fontSize: 14,
              fontWeight: 600,
              fontFamily: 'Inter, sans-serif',
              cursor: 'pointer',
              transition: 'all 0.15s ease',
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = '#005c4a'
              e.currentTarget.style.transform = 'scale(1.02)'
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = '#00493a'
              e.currentTarget.style.transform = 'scale(1)'
            }}
          >
            Imprimir / Guardar PDF
          </button>
        </div>
      </div>

      {/* Print styles */}
      <style>{`
        @media print {
          body > *:not(.comprovativo-bilhete, #comprovativo-bilhete, [id*="comprovativo"]) { display: none !important; }
          [role="dialog"] { display: none !important; }
          .comprovativo-bilhete, #comprovativo-bilhete { display: block !important; }
        }
      `}</style>
    </>
  )
}
