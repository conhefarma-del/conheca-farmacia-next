"use client";

import { useState } from "react";
import { Save, X } from "lucide-react";
import { createClass, updateClass } from "@/lib/actions/classes";

function slugify(str) {
  return (str || "")
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}

export default function ClassForm({
  initialData,
  panelOpen,
  onClose,
  onSaved,
}) {
  const isNew = !initialData?.id;

  const [slug, setSlug] = useState(initialData?.slug || "");
  const [namePt, setNamePt] = useState(initialData?.name_pt || "");
  const [nameEn, setNameEn] = useState(initialData?.name_en || "");
  const [descriptionPt, setDescriptionPt] = useState(
    initialData?.description_pt || ""
  );
  const [descriptionEn, setDescriptionEn] = useState(
    initialData?.description_en || ""
  );
  const [atcPrefix, setAtcPrefix] = useState(initialData?.atc_prefix || "");
  const [sortOrder, setSortOrder] = useState(initialData?.sort_order ?? 0);
  const [status, setStatus] = useState(initialData?.status || "draft");

  const [error, setError] = useState(null);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    if (!namePt.trim()) return setError("O nome (PT) é obrigatório.");
    if (!nameEn.trim()) return setError("O nome (EN) é obrigatório.");
    if (!slug.trim()) return setError("O slug é obrigatório.");

    setSaving(true);
    setError(null);
    try {
      const payload = {
        slug: slug.trim(),
        name_pt: namePt.trim(),
        name_en: nameEn.trim(),
        description_pt: descriptionPt.trim(),
        description_en: descriptionEn.trim(),
        atc_prefix: atcPrefix.trim(),
        sort_order: parseInt(sortOrder, 10) || 0,
        status,
      };
      const res = isNew
        ? await createClass(payload)
        : await updateClass(initialData.id, payload);

      if (res.success) {
        onSaved(true, isNew ? "Criada." : "Atualizada.");
      } else {
        setError(res.error || "Erro ao guardar.");
      }
    } catch (err) {
      setError("Erro inesperado: " + (err.message || ""));
    } finally {
      setSaving(false);
    }
  };

  const inputClass = "admin-dim-input";
  const labelClass = "admin-dim-label";

  return (
    <div
      className={`admin-dim-form class-admin-form${panelOpen ? " open" : ""}`}
    >
      <div className="admin-dim-header">
        <h3>{isNew ? "Nova" : "Editar"} classe terapêutica</h3>
        <button className="admin-dim-close" onClick={onClose}>
          <X size={20} />
        </button>
      </div>
      <div className="admin-dim-body">
        {error && <p className="admin-dim-error">{error}</p>}

        <label className={labelClass}>Nome (PT)</label>
        <input
          className={inputClass}
          value={namePt}
          onChange={(e) => {
            setNamePt(e.target.value);
            if (isNew) setSlug(slugify(e.target.value));
          }}
          placeholder="ex: Antibacterianos"
        />

        <label className={labelClass}>Nome (EN)</label>
        <input
          className={inputClass}
          value={nameEn}
          onChange={(e) => setNameEn(e.target.value)}
          placeholder="ex: Antibacterials"
        />

        <label className={labelClass}>Slug</label>
        <input
          className={inputClass}
          value={slug}
          onChange={(e) => setSlug(e.target.value)}
          placeholder="ex: antibacterianos"
        />

        <label className={labelClass}>Código ATC (prefixo)</label>
        <input
          className={inputClass}
          value={atcPrefix}
          onChange={(e) => setAtcPrefix(e.target.value)}
          placeholder="ex: J01"
        />

        <label className={labelClass}>Descrição (PT)</label>
        <textarea
          className={inputClass}
          rows={5}
          value={descriptionPt}
          onChange={(e) => setDescriptionPt(e.target.value)}
          placeholder="O que são e como funcionam estes fármacos..."
        />

        <label className={labelClass}>Descrição (EN)</label>
        <textarea
          className={inputClass}
          rows={5}
          value={descriptionEn}
          onChange={(e) => setDescriptionEn(e.target.value)}
          placeholder="What these drugs are and how they work..."
        />

        <label className={labelClass}>Ordem</label>
        <input
          className={inputClass}
          type="number"
          value={sortOrder}
          onChange={(e) => setSortOrder(e.target.value)}
        />

        <label className={labelClass}>Estado</label>
        <select
          className={inputClass}
          value={status}
          onChange={(e) => setStatus(e.target.value)}
        >
          <option value="draft">Rascunho</option>
          <option value="published">Publicado</option>
        </select>

        {/* Revisão visual — como o card aparece na página pública */}
        {(namePt || descriptionPt) && (
          <div className="alvo-admin-preview">
            <p className="alvo-admin-preview-label">
              Revisão visual (página pública)
            </p>
            <div className="admin-dashboard-card" style={{ pointerEvents: "none" }}>
              <h3>{namePt || "Nome da classe"}</h3>
              <p
                style={{
                  color: "var(--admin-text-muted)",
                  fontSize: "13px",
                  margin: "8px 0 0",
                  display: "-webkit-box",
                  WebkitLineClamp: 3,
                  WebkitBoxOrient: "vertical",
                  overflow: "hidden",
                }}
              >
                {descriptionPt || "Descrição da classe..."}
              </p>
              {atcPrefix && (
                <span className="admin-badge" style={{ marginTop: 8 }}>
                  ATC {atcPrefix}
                </span>
              )}
            </div>
          </div>
        )}
      </div>
      <div className="admin-dim-footer">
        <button
          className="admin-btn admin-btn-primary"
          onClick={handleSave}
          disabled={saving}
        >
          <Save size={14} /> {saving ? "A guardar…" : "Guardar"}
        </button>
      </div>
    </div>
  );
}
