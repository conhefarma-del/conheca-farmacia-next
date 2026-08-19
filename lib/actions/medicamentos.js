"use server";

import { createClient } from "@/lib/supabase/server";
import { createAnonClient } from "@/lib/supabase/server-anon";
import { revalidatePath, revalidateTag, unstable_cache } from "next/cache";
import { z } from "zod";

// ============================================================
//  Helper: requireAdmin (padrão de interacoes.js / guides.js)
// ============================================================
async function requireAdmin() {
  const supabase = await createClient();
  try {
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();
    if (userError || !user) return null;
    const { data: adminUser, error: adminError } = await supabase
      .from("admin_users")
      .select("user_id, role")
      .eq("user_id", user.id)
      .maybeSingle();
    if (adminError || !adminUser) return null;
    return { supabase, user, role: adminUser.role };
  } catch {
    return null;
  }
}

// ============================================================
//  Helpers
// ============================================================
function pickLang(row, prefix, lang) {
  return row[`${prefix}_${lang}`] ?? row[`${prefix}_pt`] ?? "";
}

// Severidade máxima (a mais grave) para ordenação por risco.
const SEVERITY_RANK = { critical: 0, moderate: 1, minor: 2, none: 3 };

function worstSeverity(a, b) {
  if (!a) return b;
  if (!b) return a;
  return SEVERITY_RANK[a] <= SEVERITY_RANK[b] ? a : b;
}

// ============================================================
//  Admin — Perfis de fármaco (drug_profiles)
// ============================================================
const drugProfileSchema = z.object({
  overview_public_pt: z.string().optional().default(""),
  overview_public_en: z.string().optional().default(""),
  overview_pro_pt: z.string().optional().default(""),
  overview_pro_en: z.string().optional().default(""),
  indications_pt: z.string().optional().default(""),
  indications_en: z.string().optional().default(""),
  side_effects_pt: z.string().optional().default(""),
  side_effects_en: z.string().optional().default(""),
  precautions_pt: z.string().optional().default(""),
  precautions_en: z.string().optional().default(""),
  source_pt: z.string().optional().default(""),
  source_en: z.string().optional().default(""),
  status: z.enum(["draft", "published"]).default("draft"),
});

// Perfil completo de um fármaco (edição no admin)
export async function getDrugProfile(drugId) {
  const ctx = await requireAdmin();
  if (!ctx) return null;
  const { data, error } = await ctx.supabase
    .from("drug_profiles")
    .select("*")
    .eq("drug_id", drugId)
    .maybeSingle();
  if (error || !data) return null;
  return data;
}

// Cria ou atualiza o perfil de um fármaco (upsert por drug_id)
export async function saveDrugProfile(drugId, data) {
  const ctx = await requireAdmin();
  if (!ctx) return { success: false, error: "Não autorizado" };
  if (!drugId) return { success: false, error: "Fármaco inválido" };
  const parsed = drugProfileSchema.safeParse(data);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.issues[0]?.message || "Dados inválidos",
    };
  }
  const { error } = await ctx.supabase.from("drug_profiles").upsert(
    {
      drug_id: drugId,
      ...parsed.data,
      updated_by: ctx.user.id,
      // Guardar um perfil arquivado volta a torná-lo visível (o estado
      // editorial decide a publicação; o arquivo é só soft-delete).
      is_archived: false,
      archived_at: null,
      archived_by: null,
    },
    { onConflict: "drug_id" }
  );
  if (error) return { success: false, error: error.message };
  revalidatePath("/[lang]/interacoes");
  revalidatePath("/[lang]/medicamento/[slug]");
  revalidateTag("interacoes");
  return { success: true };
}

// ============================================================
//  Admin — Farmacologia do fármaco (drug_pharmacology)
// ============================================================
const drugPharmacologySchema = z.object({
  pharmacodynamics_pt: z.string().optional().default(""),
  pharmacodynamics_en: z.string().optional().default(""),
  mechanism_pt: z.string().optional().default(""),
  mechanism_en: z.string().optional().default(""),
  metabolism_pt: z.string().optional().default(""),
  metabolism_en: z.string().optional().default(""),
  absorption_pt: z.string().optional().default(""),
  absorption_en: z.string().optional().default(""),
  half_life_pt: z.string().optional().default(""),
  half_life_en: z.string().optional().default(""),
  source_pt: z.string().optional().default(""),
  source_en: z.string().optional().default(""),
  status: z.enum(["draft", "published"]).default("draft"),
});

// Farmacologia completa de um fármaco (edição no admin)
export async function getDrugPharmacology(drugId) {
  const ctx = await requireAdmin();
  if (!ctx) return null;
  const { data, error } = await ctx.supabase
    .from("drug_pharmacology")
    .select("*")
    .eq("drug_id", drugId)
    .maybeSingle();
  if (error || !data) return null;
  return data;
}

// Cria ou atualiza a farmacologia de um fármaco (upsert por drug_id)
export async function saveDrugPharmacology(drugId, data) {
  const ctx = await requireAdmin();
  if (!ctx) return { success: false, error: "Não autorizado" };
  if (!drugId) return { success: false, error: "Fármaco inválido" };
  const parsed = drugPharmacologySchema.safeParse(data);
  if (!parsed.success) {
    return {
      success: false,
      error: parsed.error.issues[0]?.message || "Dados inválidos",
    };
  }
  const { error } = await ctx.supabase.from("drug_pharmacology").upsert(
    {
      drug_id: drugId,
      ...parsed.data,
      updated_by: ctx.user.id,
      is_archived: false,
      archived_at: null,
      archived_by: null,
    },
    { onConflict: "drug_id" }
  );
  if (error) return { success: false, error: error.message };
  revalidatePath("/[lang]/medicamento/[slug]");
  revalidateTag("interacoes");
  return { success: true };
}

// ============================================================
//  Lista pública de fármacos (com severidade máxima por fármaco)
// ============================================================
export const getPublicDrugsWithInfo = unstable_cache(
  async (lang = "pt") => {
  const supabase = await createAnonClient();
  const [drugsRes, interactionsRes] = await Promise.all([
    supabase
      .from("drugs")
      .select(
        "id, slug, name_pt, name_en, class_pt, class_en, aliases, atc_code"
      )
      .eq("status", "published")
      .eq("is_archived", false)
      .order("name_pt", { ascending: true }),
    supabase
      .from("drug_interactions")
      .select("drug_a_id, drug_b_id, severity")
      .eq("status", "published")
      .eq("is_archived", false),
  ]);
  if (drugsRes.error) return [];

  // Fármaco → pior severidade entre os pares publicados em que participa
  const maxByDrug = {};
  (interactionsRes.data || []).forEach((i) => {
    maxByDrug[i.drug_a_id] = worstSeverity(maxByDrug[i.drug_a_id], i.severity);
    maxByDrug[i.drug_b_id] = worstSeverity(maxByDrug[i.drug_b_id], i.severity);
  });

  return (drugsRes.data || []).map((d) => ({
    id: d.id,
    slug: d.slug,
    name: pickLang(d, "name", lang),
    className: pickLang(d, "class", lang),
    atcCode: d.atc_code || "",
    aliases: d.aliases || [],
    maxSeverity: maxByDrug[d.id] || null,
  }));
  },
  ["api", "medicamentos", "list"],
  { revalidate: 3600, tags: ["interacoes"] }
)

// ============================================================
//  Detalhe público de um fármaco (com perfil editorial, se existir)
// ============================================================
export const getPublicDrugBySlug = unstable_cache(
  async (slug, lang = "pt") => {
  const supabase = await createAnonClient();
  const { data: drug, error } = await supabase
    .from("drugs")
    .select("id, slug, name_pt, name_en, class_pt, class_en, aliases, atc_code, class_id")
    .eq("slug", slug)
    .eq("status", "published")
    .eq("is_archived", false)
    .maybeSingle();
  if (error || !drug) return null;

  // Fetch class slug if class_id exists
  let classSlug = "";
  if (drug.class_id) {
    const { data: cls } = await supabase
      .from("drug_classes")
      .select("slug")
      .eq("id", drug.class_id)
      .maybeSingle();
    classSlug = cls?.slug || "";
  }

  // Consultas independentes e tolerantes a erro: cada secção opcional (perfil,
  // farmacologia) falha de forma isolada — se uma tabela ainda não foi aplicada,
  // a secção simplesmente não aparece em vez de derrubar a página inteira.
  const [profileRes, pharmacologyRes] = await Promise.all([
    supabase
      .from("drug_profiles")
      .select(
        "overview_public_pt, overview_public_en, overview_pro_pt, overview_pro_en, " +          "indications_pt, indications_en, side_effects_pt, side_effects_en, " +
          "precautions_pt, precautions_en, source_pt, source_en, updated_at"
        )
      .eq("drug_id", drug.id)
      .eq("status", "published")
      .eq("is_archived", false)
      .maybeSingle(),
    supabase
      .from("drug_pharmacology")
      .select(
        "pharmacodynamics_pt, pharmacodynamics_en, mechanism_pt, mechanism_en, " +
          "metabolism_pt, metabolism_en, absorption_pt, absorption_en, " +
          "half_life_pt, half_life_en, source_pt, source_en"
      )
      .eq("drug_id", drug.id)
      .eq("status", "published")
      .eq("is_archived", false)
      .maybeSingle(),
  ]);
  const profile = profileRes.error ? null : profileRes.data;
  const pharmacology = pharmacologyRes.error ? null : pharmacologyRes.data;

  return {
    id: drug.id,
    slug: drug.slug,
    name: pickLang(drug, "name", lang),
    className: pickLang(drug, "class", lang),
    classSlug,
    atcCode: drug.atc_code || "",
    aliases: drug.aliases || [],
    profile: profile
      ? {
          overviewPublic: pickLang(profile, "overview_public", lang),
          overviewPro: pickLang(profile, "overview_pro", lang),
          indications: pickLang(profile, "indications", lang),
          sideEffects: pickLang(profile, "side_effects", lang),
          precautions: pickLang(profile, "precautions", lang),
          source: pickLang(profile, "source", lang),
          updatedAt: profile.updated_at || null,
        }
      : null,
    pharmacology: pharmacology
      ? {
          pharmacodynamics: pickLang(pharmacology, "pharmacodynamics", lang),
          mechanism: pickLang(pharmacology, "mechanism", lang),
          metabolism: pickLang(pharmacology, "metabolism", lang),
          absorption: pickLang(pharmacology, "absorption", lang),
          halfLife: pickLang(pharmacology, "half_life", lang),
          source: pickLang(pharmacology, "source", lang),
        }
      : null,
  };
  },
  ["api", "medicamentos", "by-slug"],
  { revalidate: 3600, tags: ["interacoes"] }
)

// ============================================================
//  Interações de um fármaco (as 4 dimensões) — shapes iguais ao checker
// ============================================================
export const getPublicDrugInteractionsForDrug = unstable_cache(
  async (drugId, lang = "pt") => {
  const supabase = await createAnonClient();
  // Cada dimensão falha de forma isolada (uma tabela em falta ou erro RLS
  // não derruba a página — a secção correspondente fica simplesmente vazia).
  const [pairsRes, foodRes, diseaseRes, pregnancyRes] = await Promise.all([
    supabase
      .from("drug_interactions")
      .select(
        "id, drug_a_id, drug_b_id, severity, summary_pt, summary_en, summary_pro_pt, summary_pro_en, " +
          "explanation_pt, explanation_en, mechanism_pt, mechanism_en, management_pt, management_en, " +
          "monitoring_pt, monitoring_en, red_flags_pt, red_flags_en, source_pt, source_en, source_url"
      )
      .or(`drug_a_id.eq.${drugId},drug_b_id.eq.${drugId}`)
      .eq("status", "published")
      .eq("is_archived", false),
    supabase
      .from("drug_food_interactions")
      .select(
        "id, drug_id, entity_slug, entity_pt, entity_en, severity, mechanism_pt, mechanism_en, advice_pt, advice_en, source_pt, source_en, sort_order"
      )
      .eq("drug_id", drugId)
      .eq("status", "published")
      .eq("is_archived", false)
      .order("sort_order", { ascending: true }),
    supabase
      .from("drug_disease_interactions")
      .select(
        "id, drug_id, condition_slug, condition_pt, condition_en, interaction_type, severity, reason_pt, reason_en, advice_pt, advice_en, source_pt, source_en, sort_order"
      )
      .eq("drug_id", drugId)
      .eq("status", "published")
      .eq("is_archived", false)
      .order("sort_order", { ascending: true }),
    supabase
      .from("drug_pregnancy_info")
      .select(
        "id, drug_id, pregnancy_category, risk_pt, risk_en, trimester_pt, trimester_en, lactation_pt, lactation_en, contraception_pt, contraception_en, source_pt, source_en"
      )
      .eq("drug_id", drugId)
      .eq("status", "published")
      .eq("is_archived", false),
  ]);

  return {
    drugDrug: (pairsRes.error ? [] : pairsRes.data || []).map((i) => ({
      id: i.id,
      drugAId: i.drug_a_id,
      drugBId: i.drug_b_id,
      severity: i.severity,
      summary: pickLang(i, "summary", lang),
      summaryPro: pickLang(i, "summary_pro", lang),
      explanation: pickLang(i, "explanation", lang),
      mechanism: pickLang(i, "mechanism", lang),
      management: pickLang(i, "management", lang),
      monitoring: pickLang(i, "monitoring", lang),
      redFlags: pickLang(i, "red_flags", lang),
      source: pickLang(i, "source", lang),
      sourceUrl: i.source_url || "",
    })),
    food: (foodRes.error ? [] : foodRes.data || []).map((i) => ({
      id: i.id,
      drugId: i.drug_id,
      entitySlug: i.entity_slug,
      entity: pickLang(i, "entity", lang),
      severity: i.severity,
      mechanism: pickLang(i, "mechanism", lang),
      advice: pickLang(i, "advice", lang),
      source: pickLang(i, "source", lang),
    })),
    disease: (diseaseRes.error ? [] : diseaseRes.data || []).map((i) => ({
      id: i.id,
      drugId: i.drug_id,
      conditionSlug: i.condition_slug,
      condition: pickLang(i, "condition", lang),
      interactionType: i.interaction_type,
      severity: i.severity,
      reason: pickLang(i, "reason", lang),
      advice: pickLang(i, "advice", lang),
      source: pickLang(i, "source", lang),
    })),
    pregnancy: (pregnancyRes.error ? [] : pregnancyRes.data || []).map((i) => ({
      id: i.id,
      drugId: i.drug_id,
      pregnancyCategory: i.pregnancy_category,
      risk: pickLang(i, "risk", lang),
      trimester: pickLang(i, "trimester", lang),
      lactation: pickLang(i, "lactation", lang),
      contraception: pickLang(i, "contraception", lang),
      source: pickLang(i, "source", lang),
    })),
  };
  },
  ["api", "medicamentos", "drug-interactions"],
  { revalidate: 3600, tags: ["interacoes"] }
)
