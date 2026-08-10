import { notFound } from "next/navigation";
import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { buildBreadcrumbSchema, buildMedicalWebPageSchema } from "@/lib/seo";
import { SITE_URL } from "@/lib/constants";
import { getPublicDrugs } from "@/lib/actions/interacoes";
import {
  getPublicDrugBySlug,
  getPublicDrugInteractionsForDrug,
} from "@/lib/actions/medicamentos";
import MedicamentoDetailClient from "./medicamentoDetailClient";

export const dynamic = "force-dynamic";

export async function generateMetadata({ params }) {
  const { lang, slug } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const drug = await getPublicDrugBySlug(slug, safeLang);
  if (!drug) {
    return {
      title: `${tFn("medicamento_detalhe.nao_encontrado")} | Conheça Farmácia`,
    };
  }
  return {
    title: `${drug.name} | Conheça Farmácia`,
    description: drug.profile?.overviewPublic || drug.className || drug.name,
    alternates: {
      languages: { pt: `/pt/medicamento/${slug}`, en: `/en/medicine/${slug}` },
    },
  };
}

export default async function MedicamentoDetalhePage({ params }) {
  const { lang, slug } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const drug = await getPublicDrugBySlug(slug, safeLang);
  if (!drug) notFound();
  const [drugs, interactions] = await Promise.all([
    getPublicDrugs(safeLang),
    getPublicDrugInteractionsForDrug(drug.id, safeLang),
  ]);

  // JSON-LD: BreadcrumbList (Início > Medicamentos > Fármaco) + MedicalWebPage
  // com lastReviewed (updated_at do perfil) e medicalAudience (leigo/profissional).
  const translations = loadTranslations(safeLang);
  const tFn = (key) => t(translations, key);
  const listPath = `/${safeLang}/${safeLang === "en" ? "medicines" : "medicamentos"}`;
  const breadcrumbSchema = buildBreadcrumbSchema(
    [
      { label: tFn("nav.inicio"), href: `/${safeLang}` },
      { label: tFn("nav.medicamentos"), href: listPath },
      { label: drug.name },
    ].map((l) => ({
      ...l,
      href: l.href ? `${SITE_URL}${l.href}` : undefined,
    }))
  );
  const medicalSchema = buildMedicalWebPageSchema(drug, safeLang);

  return (
    <>
      {medicalSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(medicalSchema) }}
        />
      )}
      {breadcrumbSchema && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbSchema) }}
        />
      )}
      <MedicamentoDetailClient
        lang={safeLang}
        drug={drug}
        drugs={drugs}
        interactions={interactions}
      />
    </>
  );
}
