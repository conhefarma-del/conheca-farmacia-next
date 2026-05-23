// src/lib/sitemap.js
// Gerador de sitemap.xml — corre no build (node src/lib/sitemap.js)
// Requer SUPABASE_URL e SUPABASE_ANON_KEY no .env

import { writeFileSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Carregar dotenv se disponível
try {
  const dotenv = await import('dotenv');
  dotenv.config({ path: resolve(__dirname, '../../.env') });
} catch {
  // dotenv não disponível — variáveis devem estar no ambiente
}

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const BASE_URL = 'https://conhecafarmacia.netlify.app';

async function fetchPublishedSlugs() {
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    console.warn('⚠️  SUPABASE_URL ou SUPABASE_ANON_KEY não definidos. Sitemap terá apenas páginas estáticas.');
    return [];
  }

  try {
    const response = await fetch(
      `${SUPABASE_URL}/rest/v1/articles?status=eq.published&select=slug,published_date,updated_at&order=published_date.desc`,
      {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
        },
      }
    );

    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return await response.json();
  } catch (error) {
    console.error('❌ Erro ao buscar artigos para sitemap:', error.message);
    return [];
  }
}

function generateSitemap(articles) {
  const today = new Date().toISOString().split('T')[0];

  const staticPages = [
    { loc: `${BASE_URL}/`, changefreq: 'daily', priority: '1.0' },
    { loc: `${BASE_URL}/artigos.html`, changefreq: 'daily', priority: '0.9' },
    { loc: `${BASE_URL}/eventos.html`, changefreq: 'weekly', priority: '0.8' },
    { loc: `${BASE_URL}/lives-list.html`, changefreq: 'weekly', priority: '0.7' },
    { loc: `${BASE_URL}/sobre.html`, changefreq: 'monthly', priority: '0.5' },
  ];

  const articlePages = articles.map(article => ({
    loc: `${BASE_URL}/artigo.html?id=${encodeURIComponent(article.slug)}`,
    lastmod: article.updated_at
      ? new Date(article.updated_at).toISOString().split('T')[0]
      : article.published_date
        ? new Date(article.published_date).toISOString().split('T')[0]
        : today,
    changefreq: 'monthly',
    priority: '0.7',
  }));

  const allPages = [...staticPages, ...articlePages];

  const urls = allPages.map(page => `  <url>
    <loc>${page.loc}</loc>
    ${page.lastmod ? `<lastmod>${page.lastmod}</lastmod>` : `<lastmod>${today}</lastmod>`}
    <changefreq>${page.changefreq}</changefreq>
    <priority>${page.priority}</priority>
  </url>`).join('\n');

  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls}
</urlset>`;
}

// Executar
const articles = await fetchPublishedSlugs();
const xml = generateSitemap(articles);
const outputPath = resolve(__dirname, '../../public/sitemap.xml');

writeFileSync(outputPath, xml, 'utf-8');
console.log(`✅ Sitemap gerado: ${outputPath} (${articles.length} artigos + ${5} páginas estáticas)`);
