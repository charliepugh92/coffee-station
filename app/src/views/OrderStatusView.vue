<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import OrderStatus from '@/components/order/OrderStatus.vue'

// Stable, shareable page for a single order, keyed by its guest token. This is
// where the "ready" push notification deep-links, and where a returning
// customer lands to track status and enable notifications.
const route = useRoute()
const token = computed(() => route.params.token as string)
</script>

<template>
  <section class="mx-auto max-w-lg">
    <OrderStatus :token="token" />
  </section>
</template>
