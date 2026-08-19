"use server";

import { createAnonClient } from "@/lib/supabase/server-anon";
import { unstable_cache } from "next/cache";

// ============================================================
//  Lista pública de classes de fármacos
// ============================================================
export const getPublicDrugClasses = unstable_cache(
  async (lang = "pt") => {
    const supabase = await createAnonClient();
    const { data, error } = await supabase
      .from("drug_classes")
      .select("id, slug, name_pt, name_en, description_pt, description_en, atc_prefix, sort_order")
      .eq("status", "published")
      .eq("is_archived", false)
      .order("sort_order", { ascending: true });
    if (error || !data) return [];

    // Contar fármacos por classe
    const { data: drugs } = await supabase
      .from("drugs")
      .select("class_id, id")
      .eq("status", "published")
      .eq("is_archived", false);

    const counts = {};
    (drugs || []).forEach((d) => {
      if (d.class_id) {
        counts[d.class_id] = (counts[d.class_id] || 0) + 1;
      }
    });

    return data.map((c) => ({
      id: c.id,
      slug: c.slug,
      name: c[`name_${lang}`] || c.name_pt,
      description: c[`description_${lang}`] || c.description_pt,
      atcPrefix: c.atc_prefix,
      drugCount: counts[c.id] || 0,
    }));
  },
  ["api", "drug-classes", "list"],
  { revalidate: 3600, tags: ["classes"] }
);

// ============================================================
//  Detalhe de uma classe (com lista de fármacos)
// ============================================================
export const getPublicDrugClassBySlug = unstable_cache(
  async (slug, lang = "pt") => {
    const supabase = await createAnonClient();

    const { data: cls, error: clsError } = await supabase
      .from("drug_classes")
      .select("id, slug, name_pt, name_en, description_pt, description_en, atc_prefix")
      .eq("slug", slug)
      .eq("status", "published")
      .eq("is_archived", false)
      .maybeSingle();
    if (clsError || !cls) return null;

    const nameCol = lang === "en" ? "name_en" : "name_pt";
    const descCol = lang === "en" ? "description_en" : "description_pt";
    const drugNameCol = lang === "en" ? "name_en" : "name_pt";

    const { data: drugs } = await supabase
      .from("drugs")
      .select("id, slug, name_pt, name_en, atc_code")
      .eq("class_id", cls.id)
      .eq("status", "published")
      .eq("is_archived", false)
      .order(drugNameCol, { ascending: true });

    return {
      id: cls.id,
      slug: cls.slug,
      name: cls[nameCol] || cls.name_pt,
      description: cls[descCol] || cls.description_pt,
      atcPrefix: cls.atc_prefix,
      drugs: (drugs || []).map((d) => ({
        id: d.id,
        slug: d.slug,
        name: d[drugNameCol] || d.name_pt,
        atcCode: d.atc_code || "",
      })),
    };
  },
  ["api", "drug-classes", "by-slug"],
  { revalidate: 3600, tags: ["classes"] }
);
