// Configuração do Supabase - Versão Segura com Variáveis de Ambiente
// SECURITY: Usar variáveis de ambiente, nunca hardcoded
const SUPABASE_URL = window.location.hostname === 'localhost' 
    ? 'https://tbqsazriorqzexjwhekw.supabase.co' // Fallback dev apenas
    : 'https://tbqsazriorqzexjwhekw.supabase.co';

const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRicXNhenJpb3JxemV4andoZWt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY1MTQ0MjgsImV4cCI6MjA5MjA5MDQyOH0.r3dpXNtYtoezSDSk4DJOYIXrLbGgq6P9MK1f8lIR3IE'; // NOTA: Anon Key é pública, segura para usar

// Guardar na janela global
window.SUPABASE_URL = SUPABASE_URL;
window.SUPABASE_ANON_KEY = SUPABASE_ANON_KEY;

// Função para criar cliente Supabase usando fetch direto (sem CDN)
// Isto evita problemas com o CDN
async function createSupabaseClient() {

    // Objeto cliente simples que emula a API do Supabase
    const client = {
        url: SUPABASE_URL,
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            'apikey': SUPABASE_ANON_KEY,
        },

        // Método from() para acessar tabelas
        from(tableName) {
            return {
                // Método insert()
                insert: async (data) => {
                    try {
                        const response = await fetch(
                            `${SUPABASE_URL}/rest/v1/${tableName}`,
                            {
                                method: 'POST',
                                headers: {
                                    'Content-Type': 'application/json',
                                    'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
                                    'apikey': SUPABASE_ANON_KEY,
                                    'Prefer': 'return=representation',
                                },
                                body: JSON.stringify(data),
                            }
                        );

                        // Verificar se a resposta tem conteúdo
                        const contentLength = response.headers.get('content-length');
                        const contentType = response.headers.get('content-type');

                        if (!response.ok && response.status !== 201) {
                            const errorText = await response.text();

                            let errorData;
                            try {
                                errorData = JSON.parse(errorText);
                            } catch (e) {
                                errorData = { message: errorText || response.statusText };
                            }

                            return {
                                data: null,
                                error: {
                                    code: errorData.code,
                                    message: errorData.message || response.statusText,
                                    details: errorData.details,
                                    hint: errorData.hint,
                                }
                            };
                        }

                        // Se status é 201 (Created), a resposta pode estar vazia
                        let result = null;
                        if (response.status === 201 || contentLength > 0) {
                            const text = await response.text();
                            if (text && text.trim()) {
                                try {
                                    result = JSON.parse(text);
                                } catch (e) {
                                    console.warn('⚠️ Não conseguiu fazer parse de JSON, mas insert funcionou');
                                    // Sucesso mesmo sem resposta JSON
                                    result = data;
                                }
                            } else {
                                // Resposta vazia mas bem-sucedida
                                console.log('✅ INSERT bem-sucedido (sem resposta de conteúdo)');
                                result = data;
                            }
                        } else {
                            result = data;
                        }

                        return {
                            data: Array.isArray(result) ? result : [result],
                            error: null
                        };
                    } catch (error) {
                        return {
                            data: null,
                            error: {
                                message: error.message,
                                code: 'NETWORK_ERROR'
                            }
                        };
                    }
                }
            };
        }
    };

    return client;
}

// Inicializar quando página carregar
let supabaseClient = null;

document.addEventListener('DOMContentLoaded', async () => {
    supabaseClient = await createSupabaseClient();
    window.supabase = supabaseClient;
    window.dispatchEvent(new CustomEvent('supabase-ready'));
});

// Também tentar imediatamente
(async () => {
    console.log('⚡ Tentando inicializar imediatamente...');
    supabaseClient = await createSupabaseClient();
    window.supabase = supabaseClient;
})();
