"use server";

import { createClient } from "@/lib/supabase/server";
import { createAnonClient } from "@/lib/supabase/server-anon";
import { unstable_cache, revalidatePath, revalidateTag } from "next/cache";
import { z } from "zod";

// ============================================================
//  Helper: requireAdmin
// ============================================================
async function requireAdmin() {
  const supabase = await createClient();
  try {
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();
    if (userError || !user) return null;
    const {
      data: adminUser,
      error: adminError,
    } = await supabase
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

const classSchema = z.object({
  slug: z
    .string()
    .min(1)
    .regex(
      /^[a-z0-9-]+$/,
      "Slug inválido (apenas letras minúsculas, números e hífens)"
    ),
  name_pt: z.string().min(1, "Nome (PT) é obrigatório"),
  name_en: z.string().min(1, "Name (EN) is required"),
  description_pt: z.string().optional().default(""),
  description_en: z.string().optional().default(""),
  atc_prefix: z.string().optional().default(""),
  sort_order: z.number().int().optional().default(0),
  status: z.enum(["draft", "published"]).default("draft"),
});

// ============================================================
//  Helper: pickLang
// ============================================================
function pickLang(row, prefix, lang) {
  return row[`${prefix}_${lang}`] ?? row[`${prefix}_pt`] ?? "";
}

// ============================================================
//  Queries públicas (ISR 3600s, tag 'classes')
// ============================================================
export const getPublicDrugClasses = unstable_cache(
  async (lang = "pt") => {
    const supabase = await createAnonClient();
    const { data, error } = await supabase
      .from("drug_classes")
      .select(
        "id, slug, name_pt, name_en, description_pt, description_en, atc_prefix, sort_order"
      )
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

    const {
      data: cls,
      error: clsError,
    } = await supabase
      .from("drug_classes")
      .select(
        "id, slug, name_pt, name_en, description_pt, description_en, atc_prefix"
      )
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

// ============================================================
//  Admin — CRUD de classes
// ============================================================
export async function getAllClassesAdmin() {
  const ctx = await requireAdmin();
  if (!ctx) return [];
  const { data, error } = await ctx.supabase
    .from("drug_classes")
    .select("*")
    .order("sort_order", { ascending: true });
  if (error) return [];

  // Contar fármacos por classe
  const { data: drugs } = await ctx.supabase
    .from("drugs")
    .select("class_id")
    .eq("status", "published")
    .eq("is_archived", false);

  const counts = {};
  (drugs || []).forEach((d) => {
    if (d.class_id) {
      counts[d.class_id] = (counts[d.class_id] || 0) + 1;
    }
  });

  return (data || []).map((c) => ({
    id: c.id,
    slug: c.slug,
    name_pt: c.name_pt,
    name_en: c.name_en,
    description_pt: c.description_pt,
    description_en: c.description_en,
    atc_prefix: c.atc_prefix,
    sort_order: c.sort_order,
    status: c.status,
    is_archived: c.is_archived,
    archived_at: c.archived_at,
    archived_by: c.archived_by,
    drugCount: counts[c.id] || 0,
  }));
}

export async function createClass(data) {
  const ctx = await requireAdmin();
  if (!ctx) return { success: false, error: "Não autorizado" };
  const parsed = classSchema.safeParse(data);
  if (!parsed.success)
    return {
      success: false,
      error: parsed.error.issues[0]?.message || "Dados inválidos",
    };
  const { error } = await ctx.supabase
    .from("drug_classes")
    .insert(parsed.data);
  if (error) return { success: false, error: error.message };
  revalidateTag("classes");
  revalidatePath("/[lang]/classes");
  return { success: true };
}

export async function updateClass(id, data) {
  const ctx = await requireAdmin();
  if (!ctx) return { success: false, error: "Não autorizado" };
  const parsed = classSchema.partial().safeParse(data);
  if (!parsed.success)
    return {
      success: false,
      error: parsed.error.issues[0]?.message || "Dados inválidos",
    };
  const { error } = await ctx.supabase
    .from("drug_classes")
    .update({ ...parsed.data, updated_at: new Date().toISOString() })
    .eq("id", id);
  if (error) return { success: false, error: error.message };
  revalidateTag("classes");
  revalidatePath("/[lang]/classes");
  return { success: true };
}

export async function archiveClass(id) {
  const ctx = await requireAdmin();
  if (!ctx) return { success: false, error: "Não autorizado" };
  const { error } = await ctx.supabase
    .from("drug_classes")
    .update({
      is_archived: true,
      archived_at: new Date().toISOString(),
      archived_by: ctx.user.id,
    })
    .eq("id", id);
  if (error) return { success: false, error: error.message };
  revalidateTag("classes");
  revalidatePath("/[lang]/classes");
  return { success: true };
}

export async function restoreClass(id) {
  const ctx = await requireAdmin();
  if (!ctx || ctx.role !== "superadmin")
    return { success: false, error: "Apenas superadmin" };
  const { error } = await ctx.supabase
    .from("drug_classes")
    .update({
      is_archived: false,
      archived_at: null,
      archived_by: null,
    })
    .eq("id", id);
  if (error) return { success: false, error: error.message };
  revalidateTag("classes");
  revalidatePath("/[lang]/classes");
  return { success: true };
}

export async function deleteClass(id) {
  const ctx = await requireAdmin();
  if (!ctx || ctx.role !== "superadmin")
    return { success: false, error: "Apenas superadmin" };
  // Desligar fármacos antes de apagar a classe
  await ctx.supabase
    .from("drugs")
    .update({ class_id: null })
    .eq("class_id", id);
  const { error } = await ctx.supabase
    .from("drug_classes")
    .delete()
    .eq("id", id);
  if (error) return { success: false, error: error.message };
  revalidateTag("classes");
  revalidatePath("/[lang]/classes");
  return { success: true };
}
