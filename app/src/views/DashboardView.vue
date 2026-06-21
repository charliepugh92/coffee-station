<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'

const auth = useAuthStore()
const router = useRouter()

async function logout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <section>
    <h2 class="text-lg font-semibold">
      Welcome back, {{ auth.user?.displayName }}
    </h2>
    <p class="mt-1 text-sm text-stone-500">
      Your coffee stations will live here. (Coming next.)
    </p>
    <button
      class="mt-4 rounded border border-stone-300 px-3 py-1 text-sm hover:bg-stone-100"
      @click="logout"
    >
      Sign out
    </button>
  </section>
</template>
