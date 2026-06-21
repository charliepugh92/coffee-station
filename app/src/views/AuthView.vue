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
    <h2 class="text-lg font-semibold">
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
        class="w-full rounded border border-stone-300 px-3 py-2"
      >
      <input
        v-model="email"
        type="email"
        placeholder="Email"
        required
        class="w-full rounded border border-stone-300 px-3 py-2"
      >
      <input
        v-model="password"
        type="password"
        placeholder="Password"
        required
        class="w-full rounded border border-stone-300 px-3 py-2"
      >
      <p
        v-if="error"
        class="text-sm text-red-600"
      >
        {{ error }}
      </p>
      <button
        type="submit"
        :disabled="submitting"
        class="w-full rounded bg-stone-800 px-3 py-2 text-white disabled:opacity-50"
      >
        {{ mode === 'register' ? 'Sign up' : 'Sign in' }}
      </button>
    </form>
    <p class="mt-3 text-sm text-stone-500">
      <RouterLink
        v-if="mode === 'login'"
        to="/register"
      >
        Need an account? Sign up
      </RouterLink>
      <RouterLink
        v-else
        to="/login"
      >
        Already have an account? Sign in
      </RouterLink>
    </p>
  </section>
</template>
