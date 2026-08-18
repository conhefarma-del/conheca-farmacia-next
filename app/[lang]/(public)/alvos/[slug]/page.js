import { notFound } from "next/navigation";
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { buildBreadcrumbSchema } from "@/lib/seo";
import { SITE_URL } from "@/lib/constants";
import { getPublicTargetBySlug } from "@/lib/actions/alvos";
import { getPublicDrugs } from "@/lib/actions/interacoes";
import AlvoDetailClient from "./alvoDetailClient";

export const revalidate = 3600;

export async function generateMetadata({ params }) {
  const { lang, slug } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const target = await getPublicTargetBySlug(slug, safeLang);
  if (!target) {
    return {
      title: `${tFn("alvos_page.nao_encontrado")} | Conheça Farmácia`,
    };
  }
  return {
    title: `${target.name} | Conheça Farmácia`,
    description: target.whatIs || target.role || target.name,
    alternates: {
      languages: { pt: `/pt/alvos/${slug}`, en: `/en/alvos/${slug}` },
    },
  };
}

export default async function AlvoDetailPage({ params }) {
  const { lang, slug } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const [target, drugs] = await Promise.all([
    getPublicTargetBySlug(slug, safeLang),
    getPublicDrugs(safeLang),
  ]);
  if (!target) notFound();

  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const breadcrumbSchema = buildBreadcrumbSchema(
    [
      { label: tFn("nav.inicio"), href: `/${safeLang}` },
      { label: tFn("nav.medicamentos"), href: `/${safeLang}/${safeLang === "en" ? "medicines" : "medicamentos"}` },
      { label: tFn("alvos_page.hero_title"), href: `/${safeLang}/alvos` },
      { label: target.name },
    ].map((l) => ({ ...l, href: l.href ? `${SITE_URL}${l.href}` : undefined }))
  );

  return (
    <>
      {breadcrumbSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
        />
      )}
      <AlvoDetailClient lang={safeLang} target={target} drugs={drugs} />
    </>
  );
}
