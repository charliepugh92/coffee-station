import { describe, it, expect, afterEach, vi } from 'vitest'
import { urlBase64ToUint8Array, isPushSupported } from './push'

describe('urlBase64ToUint8Array', () => {
  it('decodes URL-safe base64 into the expected bytes', () => {
    // "hello" -> base64 "aGVsbG8=" -> url-safe "aGVsbG8"
    const bytes = urlBase64ToUint8Array('aGVsbG8')
    expect(Array.from(bytes)).toEqual([104, 101, 108, 108, 111])
  })

  it('handles the - and _ url-safe alphabet', () => {
    // bytes [251, 255] -> standard base64 "+/8=" -> url-safe "-_8"
    const bytes = urlBase64ToUint8Array('-_8')
    expect(Array.from(bytes)).toEqual([251, 255])
  })

  it('is backed by a real ArrayBuffer (valid BufferSource)', () => {
    expect(urlBase64ToUint8Array('aGVsbG8').buffer).toBeInstanceOf(ArrayBuffer)
  })
})

describe('isPushSupported', () => {
  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('is false when the Push APIs are absent', () => {
    vi.stubGlobal('navigator', {})
    vi.stubGlobal('window', {})
    expect(isPushSupported()).toBe(false)
  })

  it('is true when serviceWorker, PushManager and Notification all exist', () => {
    vi.stubGlobal('navigator', { serviceWorker: {} })
    vi.stubGlobal('window', { PushManager: class {}, Notification: class {} })
    expect(isPushSupported()).toBe(true)
  })
})
