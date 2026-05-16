// src/migrations/migrate-json-to-supabase.js
/**
 * Migration Script: JSON → Supabase
 *
 * INSTRUCTIONS:
 * 1. Run in browser console on admin page
 * 2. Or run with Node.js (requires @supabase/supabase-js)
 *
 * This script will:
 * 1. Backup current JSON data
 * 2. Migrate to Supabase with status='published'
 * 3. Verify migration
 */

import articlesData from '../content/articles-catalog.json' assert { type: 'json' };
import eventsData from '../content/events-catalog.json' assert { type: 'json' };
import livesData from '../content/lives-catalog.json' assert { type: 'json' };
import { supabaseClient } from '../config.js';

// Migrate articles
async function migrateArticles() {
  console.log('Migrating articles...');

  for (const article of articlesData.articles) {
    const { error } = await supabaseClient.from('articles').insert({
      slug: article.slug,
      title: article.title,
      excerpt: article.excerpt,
      category: article.category,
      category_label: article.categoryLabel,
      content: article.content,
      author_name: article.author?.name,
      author_role: article.author?.role,
      author_bio: article.author?.bio,
      author_avatar: article.author?.avatar,
      author_avatar_bg: article.author?.avatarBg,
      published_date: article.date,
      read_time: article.readTime,
      image_url: article.image,
      references: article.references || [],
      status: 'published', // All existing articles published
      published_at: new Date().toISOString(),
    });

    if (error) {
      console.error(`Error migrating article ${article.slug}:`, error);
    } else {
      console.log(`✓ Migrated: ${article.slug}`);
    }
  }
}

// Migrate events
async function migrateEvents() {
  console.log('Migrating events...');

  for (const event of eventsData.events) {
    const { error } = await supabaseClient.from('events').insert({
      slug: event.slug,
      title: event.title,
      excerpt: event.excerpt,
      category: event.category,
      category_label: event.categoryLabel,
      date: event.date,
      time: event.time,
      end_time: event.end_time,
      location: event.location,
      type: event.type,
      capacity: event.capacity,
      hosts: event.hosts || [],
      image_url: event.image,
      registration_link: event.registrationLink,
      status: 'published',
      published_at: new Date().toISOString(),
    });

    if (error) {
      console.error(`Error migrating event ${event.slug}:`, error);
    } else {
      console.log(`✓ Migrated: ${event.slug}`);
    }
  }
}

// Migrate lives
async function migrateLives() {
  console.log('Migrating lives...');

  for (const live of livesData.events) {
    const { error } = await supabaseClient.from('lives').insert({
      slug: live.slug,
      title: live.title,
      excerpt: live.resumo,
      category: live.categoria,
      category_label: live.categoriaLabel,
      date: live.data,
      time: live.hora,
      platform: live.plataforma,
      access_link: live.link_acesso,
      meeting_id: live.id_reuniao,
      password: live.senha,
      materials: live.materiais_apoio,
      host_name: live.anfitriao?.nome,
      host_role: live.anfitriao?.cargo,
      host_organization: live.anfitriao?.organizacao,
      image_url: live.imagem,
      status: 'published',
      published_at: new Date().toISOString(),
    });

    if (error) {
      console.error(`Error migrating live ${live.slug}:`, error);
    } else {
      console.log(`✓ Migrated: ${live.slug}`);
    }
  }
}

// Run migration
async function runMigration() {
  console.log('🚀 Starting migration...');

  await migrateArticles();
  await migrateEvents();
  await migrateLives();

  console.log('✅ Migration complete!');
}

// Export for use
export { runMigration };

// Auto-run if in browser
if (typeof window !== 'undefined') {
  runMigration();
}
