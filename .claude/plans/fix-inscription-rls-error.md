# Plan for Fixing Inscription RLS Error (42501)

## Goals

Investigate and resolve the `42501` RLS error when inserting into the `inscricoes` table.

## Investigation Steps

1.  **Examine Insertion Logic**: Read `inscription-logic.js` to understand how the `insert` operation is being performed (e.g., what data is being sent, is it using a service role or anon key).
2.  **Check Supabase Client Configuration**: Read `src/lib/supabaseClient.js` to see how the Supabase client is initialized and which keys are being used.
3.  **Check API Settings**: Read `config.js` to verify API endpoints and any other configuration related to Supabase.
4.  **Analyze Database Schema and Policies**: Read `SUPABASE_MIGRATION.sql` to inspect the table definition for `inscricoes` and its Row-Level Security (RLS) policies.

## Potential Causes to Verify

- Missing `INSERT` policy for the `anon` role.
- Policy requires authentication (`auth.uid()`), but the client is using an anonymous session.
- Column mismatch between the insertion data and what the policy allows.
- Incorrectly configured Supabase client (e.g., using the wrong URL or key).
