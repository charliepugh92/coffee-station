import { describe, it, expect } from 'vitest'
import { detectInAppBrowser } from './inAppBrowser'

const MESSENGER_IOS =
  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 [FBAN/MessengerForiOS;FBAV/440.0]'
const INSTAGRAM_ANDROID =
  'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36 Instagram 300.0'
const ANDROID_WEBVIEW =
  'Mozilla/5.0 (Linux; Android 14; Pixel 8; wv) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36'
const SAFARI_IOS =
  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 Version/17.0 Mobile Safari/604.1'
const CHROME_DESKTOP =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/537.36 Chrome/120.0 Safari/537.36'

describe('detectInAppBrowser', () => {
  it('flags Facebook/Messenger webview on iOS', () => {
    const r = detectInAppBrowser(MESSENGER_IOS)
    expect(r.inApp).toBe(true)
    expect(r.platform).toBe('ios')
    // Facebook signature is checked before Messenger, both are acceptable host apps.
    expect(['Facebook', 'Messenger']).toContain(r.app)
  })

  it('flags the Instagram in-app browser on Android', () => {
    const r = detectInAppBrowser(INSTAGRAM_ANDROID)
    expect(r).toMatchObject({ inApp: true, app: 'Instagram', platform: 'android' })
  })

  it('flags a generic Android WebView', () => {
    expect(detectInAppBrowser(ANDROID_WEBVIEW).inApp).toBe(true)
  })

  it('does NOT flag real mobile Safari', () => {
    expect(detectInAppBrowser(SAFARI_IOS)).toMatchObject({ inApp: false, platform: 'ios' })
  })

  it('does NOT flag desktop Chrome', () => {
    expect(detectInAppBrowser(CHROME_DESKTOP)).toMatchObject({ inApp: false, platform: 'other' })
  })
})
