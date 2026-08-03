import { createClient } from '@/lib/supabase/server'

export const dynamic = 'force-dynamic'

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

export default async function CertificadoPublicoPage({ params }) {
  const { token } = await params

  if (!UUID_RE.test(token)) {
    return <CertificadoInvalido />
  }

  const supabase = await createClient()

  // SEC-UMN-05 (auditoria "O Sentinela" #2): leitura via SECURITY DEFINER
  // get_certificado_by_token em vez de .from('inscricoes').select(...) direto.
  // A tabela tem RLS ativa e sem policy SELECT para anon — a leitura direta
  // devolvia sempre vazio (página partida em produção). A RPC devolve apenas
  // a linha cujo certificado_token coincide (capability), mantendo RLS a
  // bloquear SELECT anónimo em massa. Requer migration 048 antes do deploy.
  const { data, error } = await supabase.rpc('get_certificado_by_token', {
    p_token: token,
  })

  if (error || !data) {
    return <CertificadoInvalido />
  }

  const ev = data.evento || {}
  const dataEvento = ev.date
    ? new Intl.DateTimeFormat('pt-PT', { day: '2-digit', month: 'long', year: 'numeric' }).format(new Date(ev.date))
    : ''

  return (
    <main
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 32,
        background: '#f9f9f9',
        fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
      }}
    >
      <div
        style={{
          maxWidth: 560,
          width: '100%',
          background: '#fff',
          borderRadius: 16,
          padding: 48,
          boxShadow: '0 4px 24px rgba(0,0,0,0.08)',
          textAlign: 'center',
        }}
      >
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 8,
            padding: '8px 20px',
            borderRadius: 100,
            background: '#d4edda',
            color: '#155724',
            fontWeight: 600,
            fontSize: 14,
            marginBottom: 24,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <polyline points="20 6 9 17 4 12" />
          </svg>
          Certificado válido
        </div>

        <h1 style={{ fontSize: 28, fontWeight: 700, color: '#1a1a1a', marginBottom: 8 }}>
          {data.nome}
        </h1>

        <p style={{ fontSize: 16, color: '#555', marginBottom: 4 }}>
          <strong>{ev.title}</strong>
        </p>

        <p style={{ fontSize: 14, color: '#777', marginBottom: 24 }}>
          {ev.location ? `${ev.location} · ` : ''}{dataEvento}
        </p>

        <div
          style={{
            padding: '12px 16px',
            background: '#f0f0f0',
            borderRadius: 8,
            fontSize: 12,
            color: '#888',
            wordBreak: 'break-all',
          }}
        >
          Verificação: conhecafarmacia.com/certificado/{data.certificado_token}
        </div>
      </div>
    </main>
  )
}

function CertificadoInvalido() {
  return (
    <main
      style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        padding: 32,
        background: '#f9f9f9',
        fontFamily: "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
      }}
    >
      <div
        style={{
          maxWidth: 400,
          width: '100%',
          background: '#fff',
          borderRadius: 16,
          padding: 48,
          boxShadow: '0 4px 24px rgba(0,0,0,0.08)',
          textAlign: 'center',
        }}
      >
        <div
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: 8,
            padding: '8px 20px',
            borderRadius: 100,
            background: '#f8d7da',
            color: '#721c24',
            fontWeight: 600,
            fontSize: 14,
            marginBottom: 24,
          }}
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
            <line x1="18" y1="6" x2="6" y2="18" />
            <line x1="6" y1="6" x2="18" y2="18" />
          </svg>
          Certificado inválido ou expirado
        </div>
        <p style={{ fontSize: 14, color: '#666' }}>
          O certificado que procura não foi encontrado ou o link de verificação é inválido.
        </p>
        <p style={{ fontSize: 12, color: '#999', marginTop: 16 }}>
          <a href="https://conhecafarmacia.com" style={{ color: '#00493a' }}>
            Conheça Farmácia
          </a>
        </p>
      </div>
    </main>
  )
}
