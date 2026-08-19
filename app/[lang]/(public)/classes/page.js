import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { buildBreadcrumbSchema, buildClassesListSchema } from "@/lib/seo";
import { SITE_URL } from "@/lib/constants";
import { getPublicDrugClasses } from "@/lib/actions/classes";
import ClassesPageClient from "./classesPageClient";

export const revalidate = 3600;

export async function generateMetadata({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);

  return {
    title: `${tFn("classes_page.hero_title")} | Conheça Farmácia`,
    description: tFn("classes_page.hero_subtitle"),
    alternates: { languages: { pt: "/pt/classes", en: "/en/classes" } },
  };
}

export default async function ClassesPage({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const classes = await getPublicDrugClasses(safeLang);

  const listPath = `/${safeLang}/classes`;
  const breadcrumbSchema = buildBreadcrumbSchema(
    [
      { label: tFn("nav.inicio"), href: `/${safeLang}` },
      { label: tFn("classes_page.hero_title"), href: listPath },
    ].map((l) => ({ ...l, href: `${SITE_URL}${l.href}` }))
  );

  const classesListSchema = buildClassesListSchema(classes, safeLang);

  return (
    <>
      {breadcrumbSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
        />
      )}
      {classesListSchema &&
        classesListSchema.map((schema, i) => (
          <script
            key={i}
            type="application/ld+json"
            dangerouslySetInnerHTML={{ __html: JSON.stringify(schema) }}
          />
        ))}
      <ClassesPageClient lang={safeLang} classes={classes} />
    </>
  );
}
