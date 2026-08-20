'use client'

import { useState } from 'react'
import SaveButton from '@/components/ui/SaveButton'
import NotesDrawer from '@/components/ui/NotesDrawer'

/**
 * ArticleWithNotes — wrapper client para artigo com NotesDrawer
 */
export default function ArticleWithNotes({ article, lang, children }) {
  const [notesOpen, setNotesOpen] = useState(false)

  return (
    <>
      {children}
      
      {/* Notes Drawer */}
      <NotesDrawer
        isOpen={notesOpen}
        onClose={() => setNotesOpen(false)}
        itemId={article.id}
        itemName={article.title}
        itemSlug={article.slug}
        itemType="article"
        lang={lang}
      />
    </>
  )
}
