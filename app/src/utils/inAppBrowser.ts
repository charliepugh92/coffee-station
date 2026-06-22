// Pure, side-effect-free in-app-browser (webview) detection. Kept separate from
// any DOM/Vue so it can be unit-tested by passing a UA string directly.
//
// In-app browsers (Messenger, Instagram, Facebook, etc.) sandbox localStorage and
// service workers, which silently breaks the per-device order history and Web Push.
// We detect them so we can steer customers to their real browser.

export type Platform = 'ios' | 'android' | 'other'

export interface InAppBrowserInfo {
  inApp: boolean
  // Friendly name of the host app when known, e.g. "Messenger", "Instagram".
  app: string | null
  platform: Platform
}

// Ordered most-specific first. Conservative on purpose — only well-known in-app
// signatures, plus the generic Android WebView marker (`; wv`), to avoid
// false-positiving real browsers.
const SIGNATURES: ReadonlyArray<readonly [RegExp, string]> = [
  [/FBAN|FBAV|FB_IAB|FBIOS|FBDV/i, 'Facebook'],
  [/MessengerForiOS|Messenger\/|\[FBAN\/Messenger/i, 'Messenger'],
  [/Instagram/i, 'Instagram'],
  [/\bLine\//i, 'LINE'],
  [/WhatsApp/i, 'WhatsApp'],
  [/Snapchat/i, 'Snapchat'],
  [/Twitter|TwitterAndroid/i, 'Twitter'],
  [/Pinterest/i, 'Pinterest'],
  [/musical_ly|Bytedance|TikTok|BytedanceWebview/i, 'TikTok'],
  [/GSA\//i, 'Google App'],
  [/; wv\)/i, 'in-app browser'], // generic Android WebView
]

function platformOf(ua: string): Platform {
  if (/iPhone|iPad|iPod/i.test(ua)) return 'ios'
  if (/Android/i.test(ua)) return 'android'
  return 'other'
}

export function detectInAppBrowser(
  ua: string = typeof navigator !== 'undefined' ? navigator.userAgent : '',
): InAppBrowserInfo {
  const platform = platformOf(ua)
  for (const [pattern, app] of SIGNATURES) {
    if (pattern.test(ua)) return { inApp: true, app, platform }
  }
  return { inApp: false, app: null, platform }
}
