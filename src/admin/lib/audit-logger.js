// src/admin/lib/audit-logger.js
import { supabaseClient } from '../../config.js';

/**
 * Log an audit event
 * @param {string} action - CREATE | UPDATE | DELETE | PUBLISH | UNPUBLISH
 * @param {string} tableName - articles | events | lives
 * @param {string} recordId - UUID of the record
 * @param {object} oldValues - Previous values (for UPDATE/DELETE)
 * @param {object} newValues - New values (for CREATE/UPDATE)
 */
export async function logAudit(action, tableName, recordId, oldValues = null, newValues = null) {
  try {
    const { data: { session } } = await supabaseClient.auth.getSession();

    if (!session?.user) {
      console.warn('No session for audit log');
      return;
    }

    // Insert audit log
    await supabaseClient
      .from('audit_logs')
      .insert({
        user_id: session.user.id,
        user_email: session.user.email,
        action,
        table_name: tableName,
        record_id: recordId,
        old_values: oldValues ? JSON.parse(JSON.stringify(oldValues)) : null,
        new_values: newValues ? JSON.parse(JSON.stringify(newValues)) : null,
      });
  } catch (error) {
    console.error('Failed to log audit:', error);
    // Don't throw - audit logging failure shouldn't break main operation
  }
}
