<script setup lang="ts">
defineProps<{ error?: string | null; success?: string | null }>()
</script>

<template>
  <p
    v-if="error"
    class="text-sm text-error"
  >
    {{ error }}
  </p>
  <p
    v-else-if="success"
    class="text-sm text-success"
  >
    {{ success }}
  </p>
</template>
