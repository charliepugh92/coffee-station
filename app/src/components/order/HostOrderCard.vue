<script setup lang="ts">
import type { OrderFieldsFragment } from '@/graphql/generated/types'
import { statusPillClass, statusPillLabel } from '@/utils/orderStatus'
import { memorySummary } from '@/utils/orderMemory'

defineProps<{ order: OrderFieldsFragment }>()
const emit = defineEmits<{ delete: [id: string, guestName: string] }>()

function formatDate(iso: string): string {
  return new Date(iso).toLocaleDateString(undefined, {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}
</script>

<template>
  <div class="flex flex-col overflow-hidden rounded-lg border-[0.5px] border-border bg-card">
    <img
      v-if="order.completionPhotoUrl"
      :src="order.completionPhotoUrl"
      alt="Finished drink"
      class="aspect-square w-full object-cover"
    >
    <div
      v-else
      class="flex aspect-square w-full items-center justify-center bg-sunken text-muted"
    >
      <i
        class="ti ti-camera-off text-2xl"
        aria-hidden="true"
      />
    </div>
    <div class="flex flex-1 flex-col gap-2 p-4">
      <div class="flex items-start justify-between gap-2">
        <div>
          <p class="font-semibold text-ink">
            {{ order.guestName }}
          </p>
          <p class="text-xs text-muted">
            {{ order.stationName }} · {{ formatDate(order.createdAt) }}
          </p>
        </div>
        <span
          class="shrink-0 rounded-sm px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em]"
          :class="statusPillClass(order.status)"
        >
          {{ statusPillLabel(order.status) }}
        </span>
      </div>

      <p class="text-sm text-ink">
        {{ memorySummary(order.memory) }}
      </p>
      <div v-if="order.notes">
        <p class="text-[10px] font-semibold uppercase tracking-wide text-muted">
          Notes
        </p>
        <p class="font-accent text-base text-muted">
          “{{ order.notes }}”
        </p>
      </div>

      <div
        v-if="order.rating"
        class="inline-flex items-center gap-0.5 text-caramel"
        :aria-label="`Rated ${order.rating.stars} of 5`"
      >
        <i
          v-for="n in order.rating.stars"
          :key="n"
          class="ti ti-star-filled text-sm"
          aria-hidden="true"
        />
      </div>
      <div v-if="order.comments.length">
        <p class="text-[10px] font-semibold uppercase tracking-wide text-muted">
          Feedback
        </p>
        <p
          v-for="c in order.comments"
          :key="c.id"
          class="font-accent text-base text-muted"
        >
          “{{ c.body }}”
        </p>
      </div>

      <button
        class="mt-auto self-start pt-1 text-xs text-muted hover:text-error"
        @click="emit('delete', order.id, order.guestName)"
      >
        Delete
      </button>
    </div>
  </div>
</template>
