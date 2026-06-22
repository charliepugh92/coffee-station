<script setup lang="ts">
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { ApiError } from '@/utils/api'

const props = defineProps<{ mode: 'login' | 'register' }>()

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const email = ref('')
const password = ref('')
const displayName = ref('')
const error = ref<string | null>(null)
const submitting = ref(false)

async function submit() {
  error.value = null
  submitting.value = true
  try {
    if (props.mode === 'register') {
      await auth.signup(email.value, password.value, displayName.value)
    } else {
      await auth.login(email.value, password.value)
    }
    router.push((route.query.redirect as string) || '/dashboard')
  } catch (e) {
    error.value = e instanceof ApiError ? e.message : 'Something went wrong'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="mx-auto max-w-sm">
    <h2 class="font-display text-2xl">
      {{ mode === 'register' ? 'Create your station account' : 'Sign in' }}
    </h2>
    <form
      class="mt-4 space-y-3"
      @submit.prevent="submit"
    >
      <input
        v-if="mode === 'register'"
        v-model="displayName"
        type="text"
        placeholder="Display name"
        required
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <input
        v-model="email"
        type="email"
        placeholder="Email"
        required
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <input
        v-model="password"
        type="password"
        placeholder="Password"
        required
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <p
        v-if="error"
        class="text-sm text-error"
      >
        {{ error }}
      </p>
      <button
        type="submit"
        :disabled="submitting"
        class="w-full rounded-lg bg-roast px-4 py-2 text-base font-semibold text-surface hover:bg-roast/90 active:scale-[.99] disabled:opacity-45"
      >
        {{ mode === 'register' ? 'Sign up' : 'Sign in' }}
      </button>
    </form>
    <p class="mt-3 text-sm text-muted">
      <RouterLink
        v-if="mode === 'login'"
        to="/register"
        class="hover:text-ink"
      >
        Need an account? Sign up
      </RouterLink>
      <RouterLink
        v-else
        to="/login"
        class="hover:text-ink"
      >
        Already have an account? Sign in
      </RouterLink>
    </p>
  </section>
</template>
