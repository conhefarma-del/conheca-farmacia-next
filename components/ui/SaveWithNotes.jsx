'use client'

import { useState } from 'react'
import SaveButton from '@/components/ui/SaveButton'
import NotesDrawer from '@/components/ui/NotesDrawer'

/**
 * SaveWithNotes — wrapper client para SaveButton + NotesDrawer
 */
export default function SaveWithNotes({
  itemType,
  itemId,
  itemSlug,
  itemName,
  itemSubtitle,
  itemImageUrl,
  lang = 'pt',
  size = 'md',
  className = '',
}) {
  const [notesOpen, setNotesOpen] = useState(false)

  return (
    <>
      <SaveButton
        itemType={itemType}
        itemId={itemId}
        itemSlug={itemSlug}
        itemName={itemName}
        itemSubtitle={itemSubtitle}
        itemImageUrl={itemImageUrl}
        lang={lang}
        size={size}
        className={className}
        showNotesBtn={true}
        onNotesClick={() => setNotesOpen(true)}
      />
      
      <NotesDrawer
        isOpen={notesOpen}
        onClose={() => setNotesOpen(false)}
        itemId={itemId}
        itemName={itemName}
        itemSlug={itemSlug}
        itemType={itemType}
        lang={lang}
      />
    </>
  )
}
