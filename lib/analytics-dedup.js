'use client'

export function hasTracked(key) {
  try {
    const raw = localStorage.getItem(key)
    if (!raw) return false
    const { ts } = JSON.parse(raw)
    return Date.now() - ts < 86_400_000
  } catch { return false }
}

export function markTracked(key) {
  try {
    localStorage.setItem(key, JSON.stringify({ ts: Date.now() }))
  } catch {}
}
