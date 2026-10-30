/**
 * Esqueletos da área de conta.
 *
 * Cada página tem o seu: a grelha, os painéis e as linhas são os da página
 * real, para o primeiro pintar e o conteúdo final não saltarem de sítio. Um
 * esqueleto genérico («três caixas cinzentas») não serve — quando o conteúdo
 * chega, a página mexe-se e o utilizador perde o sítio onde ia clicar.
 */

/** Barra cinzenta. `w` aceita número (px) ou string CSS. */
function Bar({ w = '100%', h = 10, radius = 6, style }) {
  return (
    <span
      className="conta-skel"
      aria-hidden="true"
      style={{ display: 'block', width: w, height: h, borderRadius: radius, ...style }}
    />
  )
}

/** Cabeçalho de página: kicker, título, subtítulo e, às vezes, um botão. */
function PageHead({ titleWidth = 220, subWidth = 'min(34rem, 100%)', action }) {
  return (
    <header className="conta-page-head">
      <div style={{ width: '100%' }}>
        <Bar w={104} h={8} style={{ marginBottom: 10 }} />
        <Bar w={titleWidth} h={30} radius={8} />
        <Bar w={subWidth} h={11} style={{ marginTop: 10 }} />
      </div>
      {action && <Bar w={168} h={30} radius={8} />}
    </header>
  )
}

/** Cabeçalho de painel, com um título e (opcional) um botão à direita. */
function PanelHead({ titleWidth = 150, action = false }) {
  return (
    <div className="conta-panel-head">
      <Bar w={titleWidth} h={10} />
      {action && <Bar w={86} h={26} radius={7} />}
    </div>
  )
}

/** Uma linha da lista: kicker, título e meta — a anatomia de `.conta-row`. */
function Row({ titleWidth = '58%', meta = true, actions = 0 }) {
  return (
    <li className="conta-row">
      <div className="conta-row-main">
        <Bar w={96} h={7} style={{ marginBottom: 6 }} />
        <Bar w={titleWidth} h={14} radius={5} />
        {meta && <Bar w="42%" h={8} style={{ marginTop: 6 }} />}
      </div>
      {actions > 0 && (
        <div className="conta-row-acts">
          {Array.from({ length: actions }).map((_, i) => (
            <Bar key={i} w={78} h={26} radius={7} />
          ))}
        </div>
      )}
    </li>
  )
}

/** Visão geral (`/perfil`): identidade em cima, guardados à esquerda, resumo à direita. */
export function PerfilSkeleton() {
  return (
    <main className="conta-page" aria-busy="true">
      <PageHead titleWidth={200} action />

      <section className="conta-panel">
        <div className="conta-identity">
          <Bar w={84} h={84} radius={999} style={{ flexShrink: 0 }} />
          <div className="conta-identity-main" style={{ width: '100%' }}>
            <Bar w={220} h={20} radius={6} />
            <Bar w={260} h={11} style={{ marginTop: 10 }} />
            <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
              <Bar w={150} h={22} radius={999} />
              <Bar w={128} h={22} radius={999} />
            </div>
          </div>
        </div>
      </section>

      <div className="conta-grid2">
        <section className="conta-panel">
          <PanelHead titleWidth={116} action />
          <ul className="conta-rows">
            <Row titleWidth="54%" actions={2} />
            <Row titleWidth="46%" actions={2} />
            <Row titleWidth="60%" actions={2} />
          </ul>
        </section>

        <div>
          <section className="conta-panel">
            <PanelHead titleWidth={104} action />
            <ul className="conta-rows">
              <Row titleWidth="64%" />
            </ul>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={130} />
            <ul className="conta-rows">
              <Row titleWidth="40%" />
              <Row titleWidth="46%" />
              <Row titleWidth="36%" />
            </ul>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={92} />
            <ul className="conta-rows">
              <Row titleWidth="52%" />
              <Row titleWidth="34%" />
              <Row titleWidth="44%" />
            </ul>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={78} />
            <ul className="conta-rows">
              <Row titleWidth="48%" actions={1} />
              <Row titleWidth="38%" actions={1} />
              <Row titleWidth="52%" actions={1} />
            </ul>
          </section>
        </div>
      </div>
    </main>
  )
}

/** Eventos (`/perfil/eventos`): inscrições, dados de inscrição e próximos eventos. */
export function EventosSkeleton() {
  return (
    <main className="conta-page" aria-busy="true">
      <PageHead titleWidth={150} action />

      <section className="conta-panel">
        <PanelHead titleWidth={168} />
        <ul className="conta-rows">
          <Row titleWidth="62%" actions={3} />
          <Row titleWidth="48%" actions={3} />
        </ul>
      </section>

      <section className="conta-panel">
        <PanelHead titleWidth={154} />
        {/* Grelha de dois campos por linha, como `.conta-form-grid`. */}
        <div className="conta-panel-body">
          <Bar w="72%" h={11} style={{ marginBottom: 14 }} />
          <div className="conta-form-grid">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i}>
                <Bar w={92} h={7} style={{ marginBottom: 8 }} />
                <Bar h={38} radius={8} />
              </div>
            ))}
          </div>
          <div className="conta-actions">
            <Bar w={124} h={30} radius={8} />
          </div>
        </div>
      </section>

      <section className="conta-panel">
        <PanelHead titleWidth={158} action />
        <ul className="conta-rows">
          <Row titleWidth="56%" actions={1} />
          <Row titleWidth="44%" actions={1} />
          <Row titleWidth="62%" actions={1} />
        </ul>
      </section>
    </main>
  )
}

/** Atividade (`/perfil/atividade`): uma linha temporal só, com muitas linhas. */
export function AtividadeSkeleton() {
  return (
    <main className="conta-page" aria-busy="true">
      <PageHead titleWidth={140} />

      <section className="conta-panel">
        <PanelHead titleWidth={140} />
        <ul className="conta-rows">
          {Array.from({ length: 8 }).map((_, i) => (
            <Row key={i} titleWidth={i % 3 === 0 ? '64%' : i % 3 === 1 ? '48%' : '56%'} />
          ))}
        </ul>
      </section>
    </main>
  )
}

/** Privacidade (`/perfil/privacidade`): lista do que guardamos + exportar + apagar. */
export function PrivacidadeSkeleton() {
  return (
    <main className="conta-page" aria-busy="true">
      <PageHead titleWidth={230} />

      <div className="conta-grid2">
        <div>
          <section className="conta-panel">
            <PanelHead titleWidth={126} />
            <ul className="conta-rows">
              {Array.from({ length: 5 }).map((_, i) => (
                <Row key={i} titleWidth={i % 2 === 0 ? '26%' : '34%'} />
              ))}
            </ul>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={148} />
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="82%" h={11} style={{ marginTop: 8 }} />
              <Bar w="64%" h={11} style={{ marginTop: 8, marginBottom: 14 }} />
              <Bar h={30} radius={8} />
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel">
            <PanelHead titleWidth={118} />
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="76%" h={11} style={{ marginTop: 8, marginBottom: 14 }} />
              <Bar h={30} radius={8} />
            </div>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={78} />
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="58%" h={11} style={{ marginTop: 8, marginBottom: 14 }} />
              <div style={{ display: 'flex', gap: 8 }}>
                <Bar w={92} h={26} radius={7} />
                <Bar w={74} h={26} radius={7} />
              </div>
            </div>
          </section>
        </aside>
      </div>
    </main>
  )
}

/** Preferências (`/perfil/preferencias`): um painel com segmentos, campos e botão. */
export function PreferenciasSkeleton() {
  return (
    <main className="conta-page" aria-busy="true">
      <PageHead titleWidth={190} />

      <section className="conta-panel">
        <PanelHead titleWidth={116} />
        <div className="conta-panel-body">
          <div className="conta-form-row" style={{ marginTop: 0 }}>
            <div>
              <Bar w={54} h={7} style={{ marginBottom: 10 }} />
              <div style={{ display: 'flex', gap: 6 }}>
                <Bar w={96} h={28} radius={7} />
                <Bar w={84} h={28} radius={7} />
              </div>
            </div>

            <div>
              <Bar w={72} h={7} style={{ marginBottom: 10 }} />
              <div style={{ display: 'flex', gap: 6 }}>
                <Bar w={72} h={28} radius={7} />
                <Bar w={74} h={28} radius={7} />
                <Bar w={78} h={28} radius={7} />
              </div>
            </div>

            <div>
              <Bar w={68} h={7} style={{ marginBottom: 8 }} />
              <Bar h={38} radius={8} />
              <Bar w="78%" h={9} style={{ marginTop: 8 }} />
            </div>

            <div>
              <Bar w={74} h={7} style={{ marginBottom: 8 }} />
              <Bar h={38} radius={8} />
            </div>

            <Bar h={30} radius={8} />
          </div>
        </div>
      </section>
    </main>
  )
}

/** Segurança (`/perfil/seguranca`): e-mail, palavra-passe, sessões e apagar conta. */
export function SegurancaSkeleton() {
  return (
    <main className="conta-page" aria-busy="true">
      <PageHead titleWidth={170} />

      <div className="conta-grid2">
        <div>
          <section className="conta-panel">
            <PanelHead titleWidth={128} />
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="70%" h={11} style={{ marginTop: 8, marginBottom: 14 }} />
              <Bar w={82} h={7} style={{ marginBottom: 8 }} />
              <Bar h={38} radius={8} />
              <Bar h={30} radius={8} style={{ marginTop: 12 }} />
            </div>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={152} />
            <div className="conta-panel-body">
              <Bar w={112} h={7} style={{ marginBottom: 8 }} />
              <Bar h={38} radius={8} />
              <Bar w={138} h={7} style={{ marginTop: 12, marginBottom: 8 }} />
              <Bar h={38} radius={8} />
              <Bar h={30} radius={8} style={{ marginTop: 12 }} />
            </div>
          </section>

          <section className="conta-panel">
            <PanelHead titleWidth={76} />
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="74%" h={11} style={{ marginTop: 8, marginBottom: 14 }} />
              <Bar h={30} radius={8} />
            </div>
          </section>
        </div>

        <aside>
          <section className="conta-panel">
            <PanelHead titleWidth={168} />
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="84%" h={11} style={{ marginTop: 8 }} />
              <Bar w="62%" h={11} style={{ marginTop: 8 }} />
            </div>
          </section>

          <section className="conta-panel">
            <div className="conta-panel-head">
              <Bar w={104} h={10} />
            </div>
            <div className="conta-panel-body">
              <Bar h={11} />
              <Bar w="88%" h={11} style={{ marginTop: 8 }} />
              <Bar w="70%" h={11} style={{ marginTop: 8 }} />
              <Bar h={38} radius={8} style={{ marginTop: 14 }} />
              <Bar h={30} radius={8} style={{ marginTop: 12 }} />
            </div>
          </section>
        </aside>
      </div>
    </main>
  )
}
