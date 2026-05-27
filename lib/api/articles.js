import { createClient } from '@/lib/supabase/server'
import { normalizeArticle } from '@/lib/api/normalize'

const ARTICLE_COLUMNS = 'id, slug, title, excerpt, image_url, category, category_label, author_name, author_role, author_bio, author_avatar, author_avatar_bg, published_date, read_time, status, featured, references_arr, meta_description, content'

export async function getArticles() {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('status', 'published')
    .order('published_date', { ascending: false })

  if (error) throw error
  return (data || []).map(normalizeArticle)
}

export async function getArticleBySlug(slug) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('slug', slug)
    .eq('status', 'published')
    .single()

  if (error) return null
  return data ? normalizeArticle(data) : null
}

export async function getFeaturedArticles(limit = 3) {
  const supabase = await createClient()
  const { data, error } = await supabase
    .from('articles')
    .select(ARTICLE_COLUMNS)
    .eq('status', 'published')
    .eq('featured', true)
    .order('published_date', { ascending: false })
    .limit(limit)

  if (error) throw error
  return (data || []).map(normalizeArticle)
}

export async function getPublishedArticlesCount() {
  const supabase = await createClient()
  const { count, error } = await supabase
    .from('articles')
    .select('*', { count: 'exact', head: true })
    .eq('status', 'published')

  if (error) return 0
  return count || 0
}
