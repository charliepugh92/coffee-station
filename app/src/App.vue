<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { detectInAppBrowser } from '@/utils/inAppBrowser'
import InAppBrowserGate from '@/components/InAppBrowserGate.vue'

const auth = useAuthStore()
const route = useRoute()

// In-app browsers (Messenger, Instagram, …) break per-device order memory and
// Web Push, so we block customer-facing pages and steer them to a real browser.
const detection = detectInAppBrowser()
const bypass = ref(false) // in-memory failsafe only — resets on reload
const showGate = computed(
  () => detection.inApp && !bypass.value && route.meta.customerFacing === true,
)
</script>

<template>
  <InAppBrowserGate
    v-if="showGate"
    :platform="detection.platform"
    :app="detection.app"
    @continue-anyway="bypass = true"
  />
  <div
    v-else
    class="min-h-screen bg-surface text-ink"
  >
    <header class="flex items-center justify-between border-b border-border px-6 py-4">
      <RouterLink
        to="/"
        class="flex items-center gap-3"
      >
        <img
          src="/favicon.svg"
          alt=""
          class="h-8 w-8"
        >
        <span class="font-display text-2xl leading-none">Davey's Coffee</span>
      </RouterLink>
      <nav class="flex items-center gap-5 text-sm text-muted">
        <RouterLink
          to="/my-orders"
          class="hover:text-ink"
        >
          Your orders
        </RouterLink>
        <RouterLink
          v-if="auth.isAuthenticated"
          to="/dashboard"
          class="hover:text-ink"
        >
          Dashboard
        </RouterLink>
        <RouterLink
          v-else
          to="/login"
          class="hover:text-ink"
        >
          Host sign in
        </RouterLink>
      </nav>
    </header>
    <main class="p-6">
      <RouterView />
    </main>
  </div>
</template>
