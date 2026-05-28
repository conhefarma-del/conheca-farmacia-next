'use client'

import { useState, useRef, useCallback } from 'react'
import { Upload, X, Check } from 'lucide-react'
import { createClient } from '../../lib/supabase/client'

/**
 * ImageUpload — Client Component
 *
 * Upload com compressão client-side + validação.
 * SEC-UPL-01: 5MB max, JPEG/PNG/WebP/GIF only.
 *
 * Props:
 *   - value: string (URL da imagem atual)
 *   - onChange: (url: string) => void
 *   - bucket: string (nome do bucket no Supabase Storage)
 *   - folder: string (pasta dentro do bucket)
 *   - label: string
 */

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif']
const MAX_SIZE = 5 * 1024 * 1024 // 5MB

export default function ImageUpload({ value = '', onChange, bucket = 'article-images', folder = 'articles', label = 'Imagem' }) {
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState('')
  const [dragOver, setDragOver] = useState(false)
  const inputRef = useRef(null)

  // Comprimir imagem antes de upload
  const compressImage = useCallback(async (file) => {
    return new Promise((resolve) => {
      const canvas = document.createElement('canvas')
      const ctx = canvas.getContext('2d')
      const img = new Image()

      img.onload = () => {
        const MAX_WIDTH = 1200
        let { width, height } = img

        if (width > MAX_WIDTH) {
          height = (height * MAX_WIDTH) / width
          width = MAX_WIDTH
        }

        canvas.width = width
        canvas.height = height
        ctx.drawImage(img, 0, 0, width, height)

        canvas.toBlob(
          (blob) => resolve(blob || file),
          file.type === 'image/png' ? 'image/png' : 'image/jpeg',
          0.85
        )
      }

      img.onerror = () => resolve(file)
      img.src = URL.createObjectURL(file)
    })
  }, [])

  // Upload para Supabase Storage
  const handleFile = useCallback(async (file) => {
    setError('')

    // SEC-UPL-01: Validação de MIME type
    if (!ALLOWED_TYPES.includes(file.type)) {
      setError('Tipo de ficheiro não permitido. Use JPEG, PNG, WebP ou GIF.')
      return
    }

    // SEC-UPL-01: Validação de tamanho (5MB)
    if (file.size > MAX_SIZE) {
      setError(`Ficheiro demasiado grande (${(file.size / 1024 / 1024).toFixed(1)}MB). Máximo: 5MB.`)
      return
    }

    setUploading(true)

    try {
      const supabase = createClient()
      const compressed = await compressImage(file)
      const fileName = `${folder}/${Date.now()}_${file.name.replace(/[^a-zA-Z0-9._-]/g, '_')}`

      const { data, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(fileName, compressed, {
          cacheControl: '3600',
          upsert: false,
        })

      if (uploadError) {
        setError('Erro ao carregar imagem. Tente novamente.')
        return
      }

      const { data: urlData } = supabase.storage
        .from(bucket)
        .getPublicUrl(data.path)

      if (urlData?.publicUrl) {
        onChange?.(urlData.publicUrl)
      }
    } catch {
      setError('Erro ao processar imagem.')
    } finally {
      setUploading(false)
    }
  }, [bucket, folder, compressImage, onChange])

  const handleInputChange = useCallback((e) => {
    const file = e.target.files?.[0]
    if (file) handleFile(file)
  }, [handleFile])

  const handleDrop = useCallback((e) => {
    e.preventDefault()
    setDragOver(false)
    const file = e.dataTransfer?.files?.[0]
    if (file) handleFile(file)
  }, [handleFile])

  const handleRemove = useCallback(() => {
    onChange?.('')
    if (inputRef.current) inputRef.current.value = ''
  }, [onChange])

  return (
    <div className="admin-form-group">
      <label>{label}</label>

      {/* URL input */}
      <input
        type="text"
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
        className="admin-input"
        placeholder="/images/exemplo.jpg ou https://..."
      />

      {/* Upload area */}
      <div
        className={`admin-image-upload${dragOver ? ' drag-over' : ''}`}
        onClick={() => inputRef.current?.click()}
        onDragOver={(e) => { e.preventDefault(); setDragOver(true) }}
        onDragLeave={() => setDragOver(false)}
        onDrop={handleDrop}
        style={{
          cursor: 'pointer',
          opacity: uploading ? 0.6 : 1,
          borderColor: dragOver ? 'var(--admin-primary)' : undefined,
        }}
      >
        <input
          ref={inputRef}
          type="file"
          accept="image/jpeg,image/png,image/webp,image/gif"
          onChange={handleInputChange}
          style={{ display: 'none' }}
        />
        {uploading ? (
          <p style={{ color: 'var(--admin-text-muted)', fontSize: 13 }}>
            A carregar e comprimir...
          </p>
        ) : (
          <p style={{ color: 'var(--admin-text-muted)', fontSize: 13 }}>
            <Upload size={16} style={{ display: 'inline', verticalAlign: 'middle', marginRight: 4 }} />
            Clique ou arraste uma imagem (JPEG, PNG, WebP, GIF — máx. 5MB)
          </p>
        )}
      </div>

      {/* Preview */}
      {value && (
        <div style={{ position: 'relative', marginTop: 8, display: 'inline-block' }}>
          <img
            src={value}
            alt="Preview"
            className="admin-image-preview"
            style={{ display: 'block' }}
            onError={(e) => { e.target.style.display = 'none' }}
          />
          <button
            type="button"
            onClick={handleRemove}
            style={{
              position: 'absolute', top: 8, right: 8,
              background: 'rgba(0,0,0,0.6)', color: 'white',
              border: 'none', borderRadius: '50%', width: 24, height: 24,
              cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center',
            }}
          >
            <X size={14} />
          </button>
        </div>
      )}

      {error && (
        <div style={{ color: '#dc2626', fontSize: 13, marginTop: 4 }}>{error}</div>
      )}
    </div>
  )
}
