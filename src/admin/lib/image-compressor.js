// src/admin/lib/image-compressor.js

/**
 * Compress image before upload
 * @param {File} file - Image file to compress
 * @param {number} maxWidth - Maximum width (default: 1200px)
 * @param {number} quality - JPEG quality 0-1 (default: 0.8)
 * @returns {Promise<Blob>} Compressed image blob
 */
export async function compressImage(file, maxWidth = 1200, quality = 0.8) {
  return new Promise((resolve) => {
    const img = new Image();
    img.src = URL.createObjectURL(file);

    img.onload = () => {
      const canvas = document.createElement('canvas');
      let width = img.width;
      let height = img.height;

      // Resize if width > maxWidth
      if (width > maxWidth) {
        height = (maxWidth / width) * height;
        width = maxWidth;
      }

      canvas.width = width;
      canvas.height = height;

      const ctx = canvas.getContext('2d');
      ctx.drawImage(img, 0, 0, width, height);

      canvas.toBlob(
        (blob) => {
          URL.revokeObjectURL(img.src);
          resolve(blob);
        },
        file.type,
        quality
      );
    };

    img.onerror = () => {
      URL.revokeObjectURL(img.src);
      resolve(file); // Return original if compression fails
    };
  });
}

/**
 * Upload image to Supabase Storage
 * @param {Blob} file - Image blob
 * @param {string} bucket - Storage bucket name
 * @param {string} fileName - File name
 * @returns {Promise<{url: string, error?: string}>}
 */
export async function uploadImage(file, bucket, fileName) {
  const { supabaseClient } = await import('../../config.js');

  const { data, error } = await supabaseClient.storage
    .from(bucket)
    .upload(fileName, file, {
      cacheControl: '3600',
      upsert: true,
    });

  if (error) {
    return { url: null, error: error.message };
  }

  // Get public URL
  const { data: { publicUrl } } = supabaseClient.storage
    .from(bucket)
    .getPublicUrl(fileName);

  return { url: publicUrl, error: null };
}
