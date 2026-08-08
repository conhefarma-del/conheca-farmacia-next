"use client";

import { useState } from "react";
import { Save, X } from "lucide-react";
import { saveDrugPharmacology } from "@/lib/actions/medicamentos";

function formatDate(value) {
  if (!value) return "—";
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return "—";
  return d.toLocaleString("pt-PT", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function shortId(value) {
  return value ? value.slice(0, 8) + "…" : "—";
}

/**
 * Slide-in panel largo para criar/editar a farmacologia de um fármaco
 * (tabela drug_pharmacology, 1:1 com drugs). Segue o padrão do
 * DrugProfileForm: estilos inline, painel lateral com overlay.
 * Upsert por drug_id (ON CONFLICT) feito na server action.
 */
export default function DrugPharmacologyForm({
  drug,
  pharmacology,
  panelOpen,
  onClose,
  onSaved,
}) {
  const [status, setStatus] = useState(pharmacology?.status || "draft");
  const [pharmacodynamicsPt, setPharmacodynamicsPt] = useState(
    pharmacology?.pharmacodynamics_pt || ""
  );
  const [pharmacodynamicsEn, setPharmacodynamicsEn] = useState(
    pharmacology?.pharmacodynamics_en || ""
  );
  const [mechanismPt, setMechanismPt] = useState(
    pharmacology?.mechanism_pt || ""
  );
  const [mechanismEn, setMechanismEn] = useState(
    pharmacology?.mechanism_en || ""
  );
  const [metabolismPt, setMetabolismPt] = useState(
    pharmacology?.metabolism_pt || ""
  );
  const [metabolismEn, setMetabolismEn] = useState(
    pharmacology?.metabolism_en || ""
  );
  const [absorptionPt, setAbsorptionPt] = useState(
    pharmacology?.absorption_pt || ""
  );
  const [absorptionEn, setAbsorptionEn] = useState(
    pharmacology?.absorption_en || ""
  );
  const [halfLifePt, setHalfLifePt] = useState(
    pharmacology?.half_life_pt || ""
  );
  const [halfLifeEn, setHalfLifeEn] = useState(
    pharmacology?.half_life_en || ""
  );
  const [sourcePt, setSourcePt] = useState(pharmacology?.source_pt || "");
  const [sourceEn, setSourceEn] = useState(pharmacology?.source_en || "");
  const [error, setError] = useState(null);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      const payload = {
        status,
        pharmacodynamics_pt: pharmacodynamicsPt,
        pharmacodynamics_en: pharmacodynamicsEn,
        mechanism_pt: mechanismPt,
        mechanism_en: mechanismEn,
        metabolism_pt: metabolismPt,
        metabolism_en: metabolismEn,
        absorption_pt: absorptionPt,
        absorption_en: absorptionEn,
        half_life_pt: halfLifePt,
        half_life_en: halfLifeEn,
        source_pt: sourcePt,
        source_en: sourceEn,
      };
      const res = await saveDrugPharmacology(drug.id, payload);
      if (res.success) {
        onSaved(
          true,
          pharmacology ? "Farmacologia atualizada." : "Farmacologia criada."
        );
      } else {
        setError(res.error || "Erro ao guardar a farmacologia.");
      }
    } catch (err) {
      setError("Erro inesperado: " + (err.message || "desconhecido"));
    } finally {
      setSaving(false);
    }
  };

  const inputStyle = {
    width: "100%",
    padding: "10px 14px",
    border: "1px solid #d1d5db",
    borderRadius: 8,
    fontSize: 14,
    fontFamily: "Inter, sans-serif",
    outline: "none",
    background: "#fff",
    color: "#111827",
  };
  const labelStyle = {
    display: "block",
    fontSize: 13,
    fontWeight: 600,
    color: "#374151",
    marginBottom: 6,
    textTransform: "uppercase",
    letterSpacing: "0.05em",
  };
  const fieldGap = { marginBottom: 22 };
  const rowGap = { display: "flex", gap: 16, marginBottom: 22 };
  const textarea = (value, setter, rows = 4) => ({
    value,
    onChange: (e) => setter(e.target.value),
    style: {
      ...inputStyle,
      resize: "vertical",
      minHeight: 60,
      lineHeight: 1.5,
    },
    rows,
  });
  const hint = {
    fontSize: 12,
    color: "#6b7280",
    marginTop: 4,
  };

  const field = (label, pt, en, setterPt, setterEn, rows) => (
    <div style={fieldGap}>
      <label style={labelStyle}>{label}</label>
      <div style={rowGap}>
        <textarea {...textarea(pt, setterPt, rows)} placeholder="PT" />
        <textarea {...textarea(en, setterEn, rows)} placeholder="EN" />
      </div>
    </div>
  );

  return (
    <>
      <div
        onClick={onClose}
        style={{
          position: "fixed",
          inset: 0,
          zIndex: 999,
          background: panelOpen
            ? "rgba(0, 42, 50, 0.45)"
            : "rgba(0, 42, 50, 0)",
          backdropFilter: panelOpen ? "blur(4px)" : "blur(0px)",
          WebkitBackdropFilter: panelOpen ? "blur(4px)" : "blur(0px)",
          transition: "all 250ms ease-out",
        }}
      />
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Editar farmacologia do fármaco"
        style={{
          position: "fixed",
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: "100%",
          maxWidth: 860,
          background: "#fff",
          boxShadow: panelOpen
            ? "-8px 0 40px rgba(0, 42, 50, 0.15)"
            : "-8px 0 40px rgba(0, 42, 50, 0)",
          transform: panelOpen ? "translateX(0)" : "translateX(100%)",
          transition:
            "transform 250ms cubic-bezier(0.16, 1, 0.3, 1), box-shadow 250ms ease-out",
          display: "flex",
          flexDirection: "column",
          overflow: "hidden",
        }}
      >
        <div
          style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "space-between",
            padding: "20px 28px",
            borderBottom: "1px solid #e5e7eb",
            flexShrink: 0,
          }}
        >
          <h2
            style={{
              margin: 0,
              fontSize: 18,
              fontWeight: 600,
              color: "#002a32",
              fontFamily: "Inter, sans-serif",
            }}
          >
            Farmacologia — {drug?.name_pt || ""}
          </h2>
          <button
            type="button"
            onClick={onClose}
            aria-label="Fechar"
            style={{
              background: "none",
              border: "none",
              cursor: "pointer",
              width: 36,
              height: 36,
              borderRadius: 8,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              color: "#6b7280",
              fontSize: 20,
              fontWeight: 300,
              lineHeight: 1,
              transition: "all 0.15s ease",
            }}
            onMouseEnter={(e) => {
              e.currentTarget.style.background = "#f3f4f6";
              e.currentTarget.style.color = "#002a32";
            }}
            onMouseLeave={(e) => {
              e.currentTarget.style.background = "none";
              e.currentTarget.style.color = "#6b7280";
            }}
          >
            <X size={18} />
          </button>
        </div>

        <div style={{ flex: 1, overflowY: "auto", padding: "28px" }}>
          {error && (
            <div
              style={{
                background: "#fef2f2",
                border: "1px solid #fecaca",
                color: "#991b1b",
                padding: "12px 16px",
                borderRadius: 8,
                fontSize: 14,
                marginBottom: 20,
              }}
            >
              {error}
            </div>
          )}

          {pharmacology && (
            <div
              style={{
                background: "#f8fafc",
                border: "1px solid #e2e8f0",
                borderRadius: 8,
                padding: "12px 16px",
                marginBottom: 22,
                fontSize: 13,
              }}
            >
              <div style={labelStyle}>Estado &amp; Histórico</div>
              <div
                style={{
                  display: "flex",
                  flexWrap: "wrap",
                  gap: "8px 24px",
                  color: "#374151",
                }}
              >
                <span>
                  Criado em:{" "}
                  <strong>{formatDate(pharmacology.created_at)}</strong>
                </span>
                <span>
                  Atualizado em:{" "}
                  <strong>{formatDate(pharmacology.updated_at)}</strong>
                </span>
                <span>
                  Última edição por:{" "}
                  <strong>{shortId(pharmacology.updated_by)}</strong>
                </span>
                {pharmacology.is_archived && (
                  <span style={{ color: "#b91c1c" }}>
                    <strong>Arquivado</strong>
                    {pharmacology.archived_at
                      ? ` em ${formatDate(pharmacology.archived_at)}`
                      : ""}
                  </span>
                )}
              </div>
              <p style={hint}>
                Guardar uma farmacologia arquivada volta a torná-la visível
                (is_archived = false) e regista quem editou pela última vez.
              </p>
            </div>
          )}

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Estado</label>
              <select
                value={status}
                onChange={(e) => setStatus(e.target.value)}
                style={inputStyle}
              >
                <option value="draft">Rascunho</option>
                <option value="published">Publicado</option>
              </select>
            </div>
          </div>

          {field(
            "Farmacodinâmica (PT | EN)",
            pharmacodynamicsPt,
            pharmacodynamicsEn,
            setPharmacodynamicsPt,
            setPharmacodynamicsEn,
            4
          )}
          {field(
            "Mecanismo de Ação (PT | EN)",
            mechanismPt,
            mechanismEn,
            setMechanismPt,
            setMechanismEn,
            4
          )}
          {field(
            "Metabolismo (PT | EN)",
            metabolismPt,
            metabolismEn,
            setMetabolismPt,
            setMetabolismEn,
            4
          )}
          {field(
            "Absorção (PT | EN)",
            absorptionPt,
            absorptionEn,
            setAbsorptionPt,
            setAbsorptionEn,
            3
          )}
          {field(
            "Meia-Vida (PT | EN)",
            halfLifePt,
            halfLifeEn,
            setHalfLifePt,
            setHalfLifeEn,
            3
          )}

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Fonte PT</label>
              <input
                type="text"
                value={sourcePt}
                onChange={(e) => setSourcePt(e.target.value)}
                style={inputStyle}
                placeholder="DailyMed/FDA (NIH/NLM) — rótulo aprovado, secção 12 …"
              />
            </div>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Source EN</label>
              <input
                type="text"
                value={sourceEn}
                onChange={(e) => setSourceEn(e.target.value)}
                style={inputStyle}
              />
            </div>
          </div>
        </div>

        <div
          style={{
            display: "flex",
            gap: 12,
            justifyContent: "flex-end",
            alignItems: "center",
            padding: "16px 28px",
            borderTop: "1px solid #e5e7eb",
            background: "#f9fafb",
            flexShrink: 0,
          }}
        >
          <button
            type="button"
            onClick={onClose}
            disabled={saving}
            style={{
              padding: "10px 20px",
              borderRadius: 8,
              border: "2px solid #00493a",
              background: "transparent",
              color: "#00493a",
              fontSize: 14,
              fontWeight: 500,
              fontFamily: "Inter, sans-serif",
              cursor: saving ? "not-allowed" : "pointer",
              opacity: saving ? 0.5 : 1,
              transition: "all 0.15s ease",
            }}
          >
            Cancelar
          </button>
          <button
            type="button"
            onClick={handleSave}
            disabled={saving}
            style={{
              padding: "10px 24px",
              borderRadius: 8,
              border: "none",
              background: saving ? "#6b7280" : "#00493a",
              color: "#fff",
              fontSize: 14,
              fontWeight: 600,
              fontFamily: "Inter, sans-serif",
              cursor: saving ? "not-allowed" : "pointer",
              transition: "all 0.15s ease",
              display: "flex",
              alignItems: "center",
              gap: 8,
            }}
          >
            <Save size={16} />
            {saving
              ? "A guardar..."
              : pharmacology
                ? "Guardar Alterações"
                : "Criar Farmacologia"}
          </button>
        </div>
      </div>
    </>
  );
}
