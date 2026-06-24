<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { usePushNotifications } from '@/composables/usePushNotifications'

const props = withDefaults(
  defineProps<{
    // 'host' for the order board, or a guest order token to be notified about.
    target: { kind: 'host' } | { kind: 'guest'; orderToken: string }
    label?: string
  }>(),
  { label: 'Enable notifications' },
)

const { supported, permission, subscribed, needsInstall, subscribe } = usePushNotifications()
const busy = ref(false)

async function onEnable() {
  busy.value = true
  try {
    await subscribe(props.target)
  } finally {
    busy.value = false
  }
}

// If this browser already granted permission, (re)link THIS target on mount.
// Without it a returning user — whose permission is already 'granted' — only ever
// sees the static "Notifications on" text and never registers the new order/host,
// so their completed order has no push subscription and no notification fires.
// subscribe() reuses the existing browser endpoint, so this is idempotent; the
// !subscribed guard stops it re-running (2 network calls) on every SPA re-mount.
onMounted(() => {
  if (permission.value === 'granted' && !subscribed.value) void onEnable()
})
</script>

<template>
  <div v-if="supported">
    <!-- iOS Safari: push only works once added to the home screen. -->
    <p
      v-if="needsInstall"
      class="text-xs text-muted"
    >
      <i
        class="ti ti-device-mobile-share"
        aria-hidden="true"
      />
      Add this page to your Home Screen to get alerts.
    </p>
    <p
      v-else-if="permission === 'denied'"
      class="text-xs text-muted"
    >
      Notifications are blocked in your browser settings.
    </p>
    <p
      v-else-if="permission === 'granted'"
      class="inline-flex items-center gap-1 text-xs text-muted"
    >
      <i
        class="ti ti-bell-ringing"
        aria-hidden="true"
      />
      Notifications on
    </p>
    <button
      v-else
      type="button"
      :disabled="busy"
      class="inline-flex items-center gap-1.5 rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99] disabled:opacity-45"
      @click="onEnable"
    >
      <i
        class="ti ti-bell"
        aria-hidden="true"
      />
      {{ busy ? 'Enabling…' : label }}
    </button>
  </div>
</template>
