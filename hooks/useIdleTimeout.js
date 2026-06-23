'use client'

// Back-compat shim — kept so existing imports of useIdleTimeout still
// resolve. New code should import useAdminSessionTimeout directly.

export { useAdminSessionTimeout as useIdleTimeout } from './useAdminSessionTimeout'
