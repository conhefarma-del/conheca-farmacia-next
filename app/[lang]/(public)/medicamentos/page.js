import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { buildBreadcrumbSchema } from "@/lib/seo";
import { SITE_URL } from "@/lib/constants";
import { getPublicDrugsWithInfo } from "@/lib/actions/medicamentos";
import MedicamentosPageClient from "./medicamentosPageClient";

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);

  return {
    title: `${tFn("medicamentos_page.hero_title")} | Conheça Farmácia`,
    description: tFn("medicamentos_page.hero_subtitle"),
    alternates: { languages: { pt: "/pt/medicamentos", en: "/en/medicines" } },
  };
}

export default async function MedicamentosPage({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const drugs = await getPublicDrugsWithInfo(safeLang);

  // BreadcrumbList: Início > Medicamentos (absolutos, como nas restantes páginas).
  const listPath = `/${safeLang}/${safeLang === "en" ? "medicines" : "medicamentos"}`;
  const breadcrumbSchema = buildBreadcrumbSchema(
    [
      { label: tFn("nav.inicio"), href: `/${safeLang}` },
      { label: tFn("nav.medicamentos"), href: listPath },
    ].map((l) => ({ ...l, href: `${SITE_URL}${l.href}` }))
  );

  return (
    <>
      {breadcrumbSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
        />
      )}
      <MedicamentosPageClient lang={safeLang} drugs={drugs} />
    </>
  );
}
