"use client";

import { useState } from "react";
import { Save, X } from "lucide-react";
import { saveDrugProfile } from "@/lib/actions/medicamentos";

/**
 * Slide-in panel largo para criar/editar o perfil editorial de um fármaco
 * (tabela drug_profiles, 1:1 com drugs). Segue o padrão do
 * DrugInteractionForm: estilos inline, painel lateral com overlay.
 * Upsert por drug_id (ON CONFLICT) feito na server action.
 */
export default function DrugProfileForm({
  drug,
  profile,
  panelOpen,
  onClose,
  onSaved,
}) {
  const [status, setStatus] = useState(profile?.status || "draft");
  const [overviewPublicPt, setOverviewPublicPt] = useState(
    profile?.overview_public_pt || ""
  );
  const [overviewPublicEn, setOverviewPublicEn] = useState(
    profile?.overview_public_en || ""
  );
  const [overviewProPt, setOverviewProPt] = useState(
    profile?.overview_pro_pt || ""
  );
  const [overviewProEn, setOverviewProEn] = useState(
    profile?.overview_pro_en || ""
  );
  const [indicationsPt, setIndicationsPt] = useState(
    profile?.indications_pt || ""
  );
  const [indicationsEn, setIndicationsEn] = useState(
    profile?.indications_en || ""
  );
  const [sideEffectsPt, setSideEffectsPt] = useState(
    profile?.side_effects_pt || ""
  );
  const [sideEffectsEn, setSideEffectsEn] = useState(
    profile?.side_effects_en || ""
  );
  const [precautionsPt, setPrecautionsPt] = useState(
    profile?.precautions_pt || ""
  );
  const [precautionsEn, setPrecautionsEn] = useState(
    profile?.precautions_en || ""
  );
  const [sourcePt, setSourcePt] = useState(profile?.source_pt || "");
  const [sourceEn, setSourceEn] = useState(profile?.source_en || "");
  const [error, setError] = useState(null);
  const [saving, setSaving] = useState(false);

  const handleSave = async () => {
    setSaving(true);
    setError(null);
    try {
      const payload = {
        status,
        overview_public_pt: overviewPublicPt,
        overview_public_en: overviewPublicEn,
        overview_pro_pt: overviewProPt,
        overview_pro_en: overviewProEn,
        indications_pt: indicationsPt,
        indications_en: indicationsEn,
        side_effects_pt: sideEffectsPt,
        side_effects_en: sideEffectsEn,
        precautions_pt: precautionsPt,
        precautions_en: precautionsEn,
        source_pt: sourcePt,
        source_en: sourceEn,
      };
      const res = await saveDrugProfile(drug.id, payload);
      if (res.success) {
        onSaved(true, profile ? "Perfil atualizado." : "Perfil criado.");
      } else {
        setError(res.error || "Erro ao guardar o perfil.");
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
  const textarea = (value, setter, rows = 5) => ({
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
        aria-label="Editar perfil do fármaco"
        style={{
          position: "fixed",
          top: 0,
          right: 0,
          bottom: 0,
          zIndex: 1000,
          width: "100%",
          maxWidth: 720,
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
            Perfil do Fármaco — {drug?.name_pt || ""}
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

          <div style={fieldGap}>
            <label style={labelStyle}>Overview — Público PT</label>
            <textarea {...textarea(overviewPublicPt, setOverviewPublicPt, 4)} />
            <p style={hint}>
              O que é, para que serve, como funciona — tom leigo, 2–3 frases.
            </p>
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Overview — Public EN</label>
            <textarea {...textarea(overviewPublicEn, setOverviewPublicEn, 4)} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Overview — Profissionais PT</label>
            <textarea {...textarea(overviewProPt, setOverviewProPt, 4)} />
            <p style={hint}>
              Classe, indicações formais, farmacologia — tom técnico.
            </p>
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Overview — Professionals EN</label>
            <textarea {...textarea(overviewProEn, setOverviewProEn, 4)} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Indicações PT (uma por linha)</label>
            <textarea {...textarea(indicationsPt, setIndicationsPt, 5)} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Indications EN (one per line)</label>
            <textarea {...textarea(indicationsEn, setIndicationsEn, 5)} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>
              Efeitos secundários comuns PT (uma por linha)
            </label>
            <textarea {...textarea(sideEffectsPt, setSideEffectsPt, 5)} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>
              Common side effects EN (one per line)
            </label>
            <textarea {...textarea(sideEffectsEn, setSideEffectsEn, 5)} />
          </div>

          <div style={fieldGap}>
            <label style={labelStyle}>Precauções PT (uma por linha)</label>
            <textarea {...textarea(precautionsPt, setPrecautionsPt, 5)} />
          </div>
          <div style={fieldGap}>
            <label style={labelStyle}>Precautions EN (one per line)</label>
            <textarea {...textarea(precautionsEn, setPrecautionsEn, 5)} />
          </div>

          <div style={rowGap}>
            <div style={{ flex: 1 }}>
              <label style={labelStyle}>Fonte PT</label>
              <input
                type="text"
                value={sourcePt}
                onChange={(e) => setSourcePt(e.target.value)}
                style={inputStyle}
                placeholder="DailyMed/FDA (NIH/NLM) — rótulo aprovado …"
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
              : profile
                ? "Guardar Alterações"
                : "Criar Perfil"}
          </button>
        </div>
      </div>
    </>
  );
}
