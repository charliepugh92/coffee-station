import { defineStore } from 'pinia'
import { ref } from 'vue'

function detectSupport(): boolean {
  return (
    typeof navigator !== 'undefined' &&
    'serviceWorker' in navigator &&
    'PushManager' in window &&
    'Notification' in window
  )
}

// Tracks browser notification permission and whether this device is currently
// subscribed. The server (PushSubscription rows) is the source of truth for
// delivery; this store only drives the UI.
export const usePushStore = defineStore('push', () => {
  const supported = ref(detectSupport())
  const permission = ref<NotificationPermission>(
    supported.value ? Notification.permission : 'denied',
  )
  const subscribed = ref(false)

  function setPermission(value: NotificationPermission) {
    permission.value = value
  }

  function setSubscribed(value: boolean) {
    subscribed.value = value
  }

  return { supported, permission, subscribed, setPermission, setSubscribed }
})
