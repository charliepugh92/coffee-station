import { computed } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import { usePushStore } from '@/stores/push'
import { isPushSupported, urlBase64ToUint8Array, isIosSafari, isStandalone } from '@/utils/push'
import VapidPublicKeyDocument from '@/graphql/gql/system/queries/VapidPublicKey.graphql'
import RegisterHostPushDocument from '@/graphql/gql/push/mutations/RegisterHostPush.graphql'
import RegisterGuestPushDocument from '@/graphql/gql/push/mutations/RegisterGuestPush.graphql'
import UnregisterPushDocument from '@/graphql/gql/push/mutations/UnregisterPush.graphql'
import type {
  VapidPublicKeyQuery,
  RegisterHostPushMutation,
  RegisterHostPushMutationVariables,
  RegisterGuestPushMutation,
  RegisterGuestPushMutationVariables,
  UnregisterPushMutation,
  UnregisterPushMutationVariables,
} from '@/graphql/generated/types'

type Target = { kind: 'host' } | { kind: 'guest'; orderToken: string }

async function getRegistration(): Promise<ServiceWorkerRegistration> {
  // Idempotent — register() resolves to the existing registration if present.
  await navigator.serviceWorker.register('/sw.js')
  // register() can resolve while the worker is still installing; on a fresh
  // device pushManager.subscribe() then throws because there's no active worker
  // yet. serviceWorker.ready only settles once a worker is active.
  return navigator.serviceWorker.ready
}

async function fetchVapidKey(): Promise<string | null> {
  const { data } = await apolloClient.query<VapidPublicKeyQuery>({
    query: VapidPublicKeyDocument,
    fetchPolicy: 'cache-first',
  })
  return data.vapidPublicKey ?? null
}

function serialize(sub: PushSubscription) {
  const json = sub.toJSON()
  return {
    endpoint: json.endpoint as string,
    p256dh: json.keys?.p256dh as string,
    auth: json.keys?.auth as string,
  }
}

// Drives the "enable notifications" flow for a host (order board) or a guest
// (a single tracked order). The composable owns permission + subscription
// mechanics; callers just await subscribe()/unsubscribe().
export function usePushNotifications() {
  const store = usePushStore()

  const canPrompt = computed(
    () => store.supported && store.permission !== 'granted' && store.permission !== 'denied',
  )
  // iOS only allows push from an installed home-screen PWA.
  const needsInstall = computed(() => store.supported && isIosSafari() && !isStandalone())

  async function subscribe(target: Target): Promise<boolean> {
    if (!isPushSupported()) return false

    try {
      const permission = await Notification.requestPermission()
      store.setPermission(permission)
      if (permission !== 'granted') return false

      const key = await fetchVapidKey()
      if (!key) return false

      const reg = await getRegistration()
      const sub =
        (await reg.pushManager.getSubscription()) ??
        (await reg.pushManager.subscribe({
          userVisibleOnly: true,
          applicationServerKey: urlBase64ToUint8Array(key),
        }))

      const { endpoint, p256dh, auth } = serialize(sub)

      if (target.kind === 'host') {
        const { data } = await apolloClient.mutate<RegisterHostPushMutation, RegisterHostPushMutationVariables>({
          mutation: RegisterHostPushDocument,
          variables: { endpoint, p256dh, auth },
        })
        store.setSubscribed(!!data?.registerHostPushSubscription?.success)
      } else {
        const { data } = await apolloClient.mutate<RegisterGuestPushMutation, RegisterGuestPushMutationVariables>({
          mutation: RegisterGuestPushDocument,
          variables: { orderToken: target.orderToken, endpoint, p256dh, auth },
        })
        store.setSubscribed(!!data?.registerGuestPushSubscription?.success)
      }
      return store.subscribed
    } catch (err) {
      // Permission/subscribe/registration can all reject (e.g. no active worker
      // yet, blocked push service). Fail soft so the UI just stays un-toggled.
      console.error('Push subscription failed', err)
      store.setSubscribed(false)
      return false
    }
  }

  async function unsubscribe(): Promise<void> {
    if (!isPushSupported()) return
    const reg = await navigator.serviceWorker.getRegistration()
    const sub = await reg?.pushManager.getSubscription()
    if (!sub) return
    const { endpoint } = serialize(sub)
    await sub.unsubscribe()
    await apolloClient.mutate<UnregisterPushMutation, UnregisterPushMutationVariables>({
      mutation: UnregisterPushDocument,
      variables: { endpoint },
    })
    store.setSubscribed(false)
  }

  return { supported: computed(() => store.supported), permission: computed(() => store.permission), canPrompt, needsInstall, subscribe, unsubscribe }
}
