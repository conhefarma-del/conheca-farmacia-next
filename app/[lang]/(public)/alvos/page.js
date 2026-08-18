import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { buildBreadcrumbSchema } from "@/lib/seo";
import { SITE_URL } from "@/lib/constants";
import { getPublicTargets, getTargetDrugCounts } from "@/lib/actions/alvos";
import AlvosPageClient from "./alvosPageClient";

export const revalidate = 3600;

export async function generateMetadata({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);

  return {
    title: `${tFn("alvos_page.hero_title")} | Conheça Farmácia`,
    description: tFn("alvos_page.hero_subtitle"),
    alternates: { languages: { pt: "/pt/alvos", en: "/en/alvos" } },
  };
}

export default async function AlvosPage({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const [targets, drugCounts] = await Promise.all([
    getPublicTargets(safeLang),
    getTargetDrugCounts(),
  ]);

  const listPath = `/${safeLang}/alvos`;
  const breadcrumbSchema = buildBreadcrumbSchema(
    [
      { label: tFn("nav.inicio"), href: `/${safeLang}` },
      { label: tFn("nav.medicamentos"), href: `/${safeLang}/${safeLang === "en" ? "medicines" : "medicamentos"}` },
      { label: tFn("alvos_page.hero_title"), href: listPath },
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
      <AlvosPageClient lang={safeLang} targets={targets} drugCounts={drugCounts} />
    </>
  );
}
