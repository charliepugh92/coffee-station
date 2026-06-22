<script setup lang="ts">
import { memoryCustomisation, type OrderMemory } from '@/utils/orderMemory'

defineProps<{
  order: {
    guestName: string
    queuePosition?: number | null
    notes?: string | null
    memory: OrderMemory
    rating?: { stars: number } | null
    comments: { id: string; body: string }[]
  }
}>()
</script>

<template>
  <div class="min-w-0">
    <div class="text-base font-semibold text-ink">
      {{ order.guestName }}
      <span
        v-if="order.queuePosition"
        class="ml-1 text-xs font-normal text-muted"
      >#{{ order.queuePosition }}</span>
    </div>
    <div
      v-if="order.memory.baseName"
      class="mt-0.5 text-sm font-medium text-ink"
    >
      {{ order.memory.baseName }}
    </div>
    <div
      v-if="memoryCustomisation(order.memory)"
      class="text-sm text-muted"
    >
      {{ memoryCustomisation(order.memory) }}
    </div>
    <div
      v-if="order.notes"
      class="mt-1"
    >
      <span class="text-[10px] font-semibold uppercase tracking-wide text-muted">Notes</span>
      <span class="ml-1 font-accent text-base text-muted">“{{ order.notes }}”</span>
    </div>
    <div
      v-if="order.rating || order.comments.length"
      class="mt-1"
    >
      <span class="text-[10px] font-semibold uppercase tracking-wide text-muted">Feedback</span>
      <div class="flex flex-wrap items-center gap-x-2 gap-y-1">
        <span
          v-if="order.rating"
          class="inline-flex items-center gap-0.5 text-caramel"
          :aria-label="`Rated ${order.rating.stars} of 5`"
        >
          <i
            v-for="n in order.rating.stars"
            :key="n"
            class="ti ti-star text-sm"
            aria-hidden="true"
          />
        </span>
        <span
          v-for="c in order.comments"
          :key="c.id"
          class="font-accent text-base text-muted"
        >“{{ c.body }}”</span>
      </div>
    </div>
  </div>
</template>
