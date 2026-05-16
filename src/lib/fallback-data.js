// src/lib/fallback-data.js
import articlesData from '../content/articles-catalog.json';
import eventsData from '../content/events-catalog.json';
import livesData from '../content/lives-catalog.json';

/**
 * Get articles from local JSON (fallback)
 */
export function getFallbackArticles() {
  return articlesData.articles || [];
}

/**
 * Get single article from local JSON
 */
export function getFallbackArticleBySlug(slug) {
  return (articlesData.articles || []).find(a => a.slug === slug) || null;
}

/**
 * Get events from local JSON (fallback)
 */
export function getFallbackEvents() {
  return eventsData.events || [];
}

/**
 * Get single event from local JSON
 */
export function getFallbackEventBySlug(slug) {
  return (eventsData.events || []).find(e => e.slug === slug) || null;
}

/**
 * Get lives from local JSON (fallback)
 */
export function getFallbackLives() {
  return livesData.events || [];
}

/**
 * Get single live from local JSON
 */
export function getFallbackLiveBySlug(slug) {
  return (livesData.events || []).find(l => l.slug === slug) || null;
}
