<script setup lang="ts">
import { computed, ref } from 'vue'
import type { Platform } from '@/utils/inAppBrowser'

const props = defineProps<{ platform: Platform; app: string | null }>()
const emit = defineEmits<{ continueAnyway: [] }>()

// Two-step failsafe: the first click only reveals the confirm step, the second
// actually continues. Deliberately slower than just opening the real browser.
const confirming = ref(false)
const copied = ref(false)

const menuHint = computed(() =>
  props.platform === 'ios'
    ? 'Tap the “aA” or “•••” menu at the top, then choose “Open in Safari”.'
    : props.platform === 'android'
      ? 'Tap the “⋮” menu at the top right, then choose “Open in Chrome” (or your browser).'
      : 'Use your phone’s browser (Safari, Chrome, …) to open this page.',
)

const appName = computed(() => props.app ?? 'this app')

async function copyLink() {
  const url = window.location.href
  try {
    await navigator.clipboard.writeText(url)
    copied.value = true
    setTimeout(() => (copied.value = false), 2500)
  } catch {
    // Clipboard API is often blocked in webviews — fall back to a temp textarea.
    const el = document.createElement('textarea')
    el.value = url
    document.body.appendChild(el)
    el.select()
    try {
      document.execCommand('copy')
      copied.value = true
      setTimeout(() => (copied.value = false), 2500)
    } catch {
      // give up silently; the steps above still let them open it manually
    }
    document.body.removeChild(el)
  }
}
</script>

<template>
  <div class="fixed inset-0 z-50 overflow-y-auto bg-surface text-ink">
    <!-- Arrow pointing at the in-app browser's menu (top-right of the screen). -->
    <div
      class="pointer-events-none fixed right-3 top-2 flex flex-col items-end"
      aria-hidden="true"
    >
      <i class="ti ti-arrow-up-right animate-bounce text-4xl text-roast" />
      <span class="mt-1 font-accent text-sm text-roast">menu is up here</span>
    </div>

    <div class="mx-auto flex min-h-full max-w-md flex-col justify-center px-6 py-20">
      <div class="text-5xl">
        ☕
      </div>
      <h1 class="mt-4 font-display text-2xl leading-tight">
        Open in your browser for the best experience
      </h1>
      <p class="mt-2 text-muted">
        You’re viewing this inside {{ appName }}. To keep your order history and get
        “your drink is ready” notifications, open this page in your phone’s browser.
      </p>

      <ol class="mt-6 space-y-3">
        <li class="flex gap-3 rounded-lg border-[0.5px] border-border bg-card p-3">
          <span class="font-display text-roast">1</span>
          <span class="text-sm">{{ menuHint }}</span>
        </li>
        <li class="flex gap-3 rounded-lg border-[0.5px] border-border bg-card p-3">
          <span class="font-display text-roast">2</span>
          <span class="text-sm">Order from there — your name and past orders will stick.</span>
        </li>
      </ol>

      <button
        type="button"
        class="mt-6 rounded-lg bg-roast px-4 py-3 text-base font-semibold text-surface hover:bg-roast/90 active:scale-[.99]"
        @click="copyLink"
      >
        <i class="ti ti-link" />
        {{ copied ? 'Link copied — paste it in your browser' : 'Copy link' }}
      </button>

      <!-- Friction-ful failsafe against a wrong detection. Not a convenient bypass. -->
      <div class="mt-10 text-center">
        <button
          v-if="!confirming"
          type="button"
          class="text-sm text-muted underline underline-offset-2 hover:text-ink"
          @click="confirming = true"
        >
          Order here instead
        </button>
        <div
          v-else
          class="space-y-2"
        >
          <p class="text-sm text-muted">
            Opening in your browser keeps your order history &amp; notifications. Continue here anyway?
          </p>
          <button
            type="button"
            class="text-sm font-semibold text-error underline underline-offset-2"
            @click="emit('continueAnyway')"
          >
            Yes, continue here
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
