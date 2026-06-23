// Downscale a picked/captured image on-device before upload. Phone cameras
// produce multi-MB, 12MP+ files; these photos only ever display small, so we cap
// the largest dimension and re-encode as JPEG. This keeps the raw file off the
// API's cheap server tier, where buffering a full-resolution upload into memory
// for ActiveStorage was exhausting RAM.
//
// Downscaling is an optimization, never a gate: any failure (non-raster file,
// decode error, null toBlob) falls back to returning the original File so an
// upload that works today can never be blocked by this.

interface DownscaleOptions {
  maxDimension?: number
  quality?: number
}

function jpegName(name: string): string {
  const base = name.replace(/\.[^./\\]+$/, '')
  return `${base || 'photo'}.jpg`
}

export async function downscaleImage(
  file: File,
  opts: DownscaleOptions = {},
): Promise<File> {
  const { maxDimension = 1600, quality = 0.8 } = opts

  // Only attempt raster images; leave anything else untouched.
  if (!file.type.startsWith('image/')) return file

  try {
    const bitmap = await createImageBitmap(file)
    const { width, height } = bitmap
    const longest = Math.max(width, height)
    const scale = longest > maxDimension ? maxDimension / longest : 1
    const targetW = Math.round(width * scale)
    const targetH = Math.round(height * scale)

    const canvas = document.createElement('canvas')
    canvas.width = targetW
    canvas.height = targetH
    const ctx = canvas.getContext('2d')
    if (!ctx) {
      bitmap.close()
      return file
    }
    ctx.drawImage(bitmap, 0, 0, targetW, targetH)
    bitmap.close()

    const blob = await new Promise<Blob | null>((resolve) =>
      canvas.toBlob(resolve, 'image/jpeg', quality),
    )
    if (!blob) return file

    return new File([blob], jpegName(file.name), {
      type: 'image/jpeg',
      lastModified: file.lastModified,
    })
  } catch {
    return file
  }
}
