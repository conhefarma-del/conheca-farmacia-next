import { notFound } from "next/navigation";
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { buildBreadcrumbSchema } from "@/lib/seo";
import { SITE_URL } from "@/lib/constants";
import { getPublicDrugClassBySlug } from "@/lib/actions/classes";
import Breadcrumb from "@/components/ui/Breadcrumb";
import ClassDetailClient from "./classDetailClient";

export const revalidate = 3600;

export async function generateMetadata({ params }) {
  const { lang, slug } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const cls = await getPublicDrugClassBySlug(slug, safeLang);
  if (!cls) return { title: "404" };

  return {
    title: `${cls.name} | Conheça Farmácia`,
    description: cls.description?.slice(0, 160) || cls.name,
    alternates: {
      languages: { pt: `/pt/classes/${slug}`, en: `/en/classes/${slug}` },
    },
  };
}

export default async function ClassDetailPage({ params }) {
  const { lang, slug } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const cls = await getPublicDrugClassBySlug(slug, safeLang);
  if (!cls) notFound();

  const listPath = `/${safeLang}/classes`;
  const breadcrumbSchema = buildBreadcrumbSchema(
    [
      { label: tFn("nav.inicio"), href: `/${safeLang}` },
      { label: tFn("classes_page.hero_title"), href: listPath },
      { label: cls.name, href: `${listPath}/${slug}` },
    ].map((l) => ({ ...l, href: `${SITE_URL}${l.href}` }))
  );

  const breadcrumbLevels = [
    { label: tFn("nav.inicio"), href: `/${safeLang}` },
    { label: tFn("classes_page.hero_title"), href: listPath },
    { label: cls.name },
  ];

  return (
    <>
      {breadcrumbSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
        />
      )}
      <nav id="breadcrumb" aria-label="Breadcrumb">
        <Breadcrumb items={breadcrumbLevels} />
      </nav>
      <ClassDetailClient lang={safeLang} cls={cls} />
    </>
  );
}
