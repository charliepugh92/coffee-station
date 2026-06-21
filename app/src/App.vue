<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
</script>

<template>
  <div class="min-h-screen bg-stone-50 text-stone-900">
    <header class="flex items-center justify-between border-b border-stone-200 px-6 py-4">
      <RouterLink
        to="/"
        class="text-xl font-semibold tracking-tight"
      >
        Davey's Coffee
      </RouterLink>
      <nav class="flex items-center gap-4 text-sm">
        <RouterLink
          to="/my-orders"
          class="text-stone-600 hover:text-stone-900"
        >
          Your orders
        </RouterLink>
        <RouterLink
          v-if="auth.isAuthenticated"
          to="/dashboard"
          class="text-stone-600 hover:text-stone-900"
        >
          Dashboard
        </RouterLink>
        <RouterLink
          v-else
          to="/login"
          class="text-stone-600 hover:text-stone-900"
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
