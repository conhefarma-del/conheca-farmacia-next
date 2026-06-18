// Helper partilhado para envio de email via Brevo (API HTTP v3).
// Substitui o stack denomailer (SMTP/Amazon SES) em todas as Edges.
//
// Padrões do projecto (preservados):
//   - subject ASCII (commit b35cea8)
//   - sender.name UTF-8 hardcoded "Conheça Farmácia" (decisão 2026-06-18)
//   - headers RFC 8058 (List-Unsubscribe + List-Unsubscribe-Post)
//   - error codes semânticos via throwCode({ code, detail })
//   - telemetria: code + emailHash + requestId, sem PII raw
//   - idempotency via X-Request-Id (campo do payload, NÃO HTTP header)
//
// Referências:
//   - Brevo API v3: https://developers.brevo.com/reference/sendtransacemail
//   - Memory: server-action-error-pattern, denomailer-headers-encoding-ascii-solution
//   - Email addresses mapping: newsletter@, info@, inscricao@ (todos @conhecafarmacia.com)
import { hashEmail } from "./hash.ts";

export type BrevoErrorCode =
  | "brevo_auth_error"
  | "brevo_bad_request"
  | "brevo_rate_limit"
  | "brevo_unavailable";

const BREVO_ENDPOINT = "https://api.brevo.com/v3/smtp/email";
const REPLY_TO_DEFAULT = "contato@conhecafarmacia.com";
const DEFAULT_TIMEOUT_MS = 10_000;
const RETRY_BACKOFF_MS = 500;
const RETRYABLE_STATUS = new Set([500, 502, 503, 504]);

export interface SendViaBrevoParams {
  to: { email: string; name?: string };
  sender: "newsletter@conhecafarmacia.com" | "info@conhecafarmacia.com" | "inscricao@conhecafarmacia.com";
  subject: string;
  htmlContent: string;
  textContent?: string;
  replyTo?: string;
  headers?: Record<string, string>;
  tags?: string[];
  requestId?: string;
  timeoutMs?: number;
}

function throwCode(code: BrevoErrorCode, detail: string): never {
  throw new Error(JSON.stringify({ code, detail }));
}

async function callBrevo(
  payload: Record<string, unknown>,
  apiKey: string,
  timeoutMs: number,
): Promise<{ status: number; body: unknown }> {
  let lastErr: unknown = null;
  for (let attempt = 0; attempt < 2; attempt++) {
    const ac = new AbortController();
    const timer = setTimeout(() => ac.abort(), timeoutMs);
    try {
      const res = await fetch(BREVO_ENDPOINT, {
        method: "POST",
        headers: {
          "accept": "application/json",
          "api-key": apiKey,
          "content-type": "application/json",
        },
        body: JSON.stringify(payload),
        signal: ac.signal,
      });
      const text = await res.text();
      let body: unknown = null;
      try { body = text ? JSON.parse(text) : null; } catch { body = text; }
      if (res.ok) return { status: res.status, body };
      if (!RETRYABLE_STATUS.has(res.status) || attempt === 1) {
        return { status: res.status, body };
      }
      lastErr = { status: res.status, body };
    } catch (err) {
      lastErr = err;
      if (attempt === 1) {
        // distinguir timeout de network error no caller
        const isTimeout = err instanceof DOMException && err.name === "AbortError";
        throw { _timeout: isTimeout, cause: err };
      }
    } finally {
      clearTimeout(timer);
    }
    await new Promise((r) => setTimeout(r, RETRY_BACKOFF_MS));
  }
  // unreachable — o loop ou retorna ou relança
  throw lastErr;
}

function mapBrevoError(status: number, body: unknown): BrevoErrorCode {
  if (status === 401 || status === 403) return "brevo_auth_error";
  if (status === 400) return "brevo_bad_request";
  if (status === 429) return "brevo_rate_limit";
  return "brevo_unavailable";
}

export async function sendViaBrevo(params: SendViaBrevoParams): Promise<{ messageId: string }> {
  const apiKey = Deno.env.get("BREVO_API_KEY");
  if (!apiKey) {
    throwCode("brevo_auth_error", "BREVO_API_KEY não configurada");
  }

  const requestId = params.requestId ?? crypto.randomUUID();
  const textContent = params.textContent ?? params.htmlContent.replace(/<[^>]+>/g, "").slice(0, 200);

  const payload: Record<string, unknown> = {
    sender: { name: "Conheça Farmácia", email: params.sender },
    to: [{ email: params.to.email, name: params.to.name ?? params.to.email }],
    subject: params.subject,
    htmlContent: params.htmlContent,
    textContent,
    replyTo: { email: params.replyTo ?? REPLY_TO_DEFAULT },
    headers: {
      ...(params.headers ?? {}),
      "X-Request-Id": requestId,
    },
  };
  if (params.tags && params.tags.length > 0) {
    payload.tags = params.tags;
  }

  const emailHash = hashEmail(params.to.email);
  const timeoutMs = params.timeoutMs ?? DEFAULT_TIMEOUT_MS;

  let res: { status: number; body: unknown };
  try {
    res = await callBrevo(payload, apiKey!, timeoutMs);
  } catch (err: any) {
    if (err && err._timeout) {
      console.error("[brevo] code=brevo_unavailable detail=timeout requestId=" + requestId + " emailHash=" + (emailHash ?? "?"));
      throwCode("brevo_unavailable", "timeout");
    }
    console.error("[brevo] code=brevo_unavailable detail=network requestId=" + requestId + " emailHash=" + (emailHash ?? "?"));
    throwCode("brevo_unavailable", "network");
  }

  if (!res || typeof res.status !== "number") {
    console.error("[brevo] code=brevo_unavailable detail=no_response requestId=" + requestId + " emailHash=" + (emailHash ?? "?"));
    throwCode("brevo_unavailable", "no_response");
  }

  if (res.status >= 200 && res.status < 300) {
    const body = res.body as { messageId?: string } | null;
    const messageId = body?.messageId ?? "(no-message-id)";
    console.log("[brevo] code=ok status=" + res.status + " requestId=" + requestId + " emailHash=" + (emailHash ?? "?") + " messageId=" + messageId);
    return { messageId };
  }

  const code = mapBrevoError(res.status, res.body);
  const detail = (() => {
    const b = res.body as { message?: string; code?: string } | null;
    if (b?.message) return b.message;
    if (b?.code) return b.code;
    try { return JSON.stringify(res.body).slice(0, 200); } catch { return "unknown"; }
  })();
  console.error("[brevo] code=" + code + " status=" + res.status + " detail=" + detail + " requestId=" + requestId + " emailHash=" + (emailHash ?? "?"));
  throwCode(code, detail);
}
