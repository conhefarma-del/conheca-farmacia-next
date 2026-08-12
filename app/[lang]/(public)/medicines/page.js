import { loadTranslations, t, SUPPORTED_LANGS, DEFAULT_LANG } from "@/lib/i18n";
import { getPublicDrugsWithInfo } from "@/lib/actions/medicamentos";
import MedicamentosPageClient from "../medicamentos/medicamentosPageClient";

export const revalidate = 3600;

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

export default async function MedicinesPage({ params }) {
  const { lang } = await params;
  const safeLang = SUPPORTED_LANGS.includes(lang) ? lang : DEFAULT_LANG;
  const drugs = await getPublicDrugsWithInfo(safeLang);
  return <MedicamentosPageClient lang={safeLang} drugs={drugs} />;
}
