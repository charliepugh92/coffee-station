<script setup lang="ts">
import { apolloClient } from '@/utils/apolloClient'
import UpdateOrderStatusDocument from '@/graphql/gql/orders/mutations/UpdateOrderStatus.graphql'
import CompleteOrderDocument from '@/graphql/gql/orders/mutations/CompleteOrder.graphql'
import type {
  UpdateOrderStatusMutation,
  UpdateOrderStatusMutationVariables,
  CompleteOrderMutation,
  CompleteOrderMutationVariables,
  OrderStatusEnum,
} from '@/graphql/generated/types'
import { statusPillClass, statusPillLabel } from '@/utils/orderStatus'

interface BoardOrder {
  id: string
  guestName: string
  status: string
  queuePosition?: number | null
  notes?: string | null
  selections: { name: string }[]
  menuPreset?: { name: string } | null
  rating?: { stars: number } | null
  comments: { id: string; body: string }[]
}

const props = defineProps<{ order: BoardOrder }>()
const emit = defineEmits<{ changed: [] }>()

// PENDING → start, READY → picked up are plain status bumps. IN_PROGRESS →
// ready goes through completeOrder so a photo is captured.
const NEXT: Record<string, { status: OrderStatusEnum; label: string } | undefined> = {
  PENDING: { status: 'IN_PROGRESS', label: 'Start' },
  READY: { status: 'PICKED_UP', label: 'Picked up' },
}

async function advance() {
  const next = NEXT[props.order.status]
  if (!next) return
  await apolloClient.mutate<UpdateOrderStatusMutation, UpdateOrderStatusMutationVariables>({
    mutation: UpdateOrderStatusDocument,
    variables: { orderId: props.order.id, status: next.status },
  })
  emit('changed')
}

async function complete(event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  await apolloClient.mutate<CompleteOrderMutation, CompleteOrderMutationVariables>({
    mutation: CompleteOrderDocument,
    variables: { orderId: props.order.id, file },
  })
  emit('changed')
}
</script>

<template>
  <div class="flex items-start justify-between gap-3 rounded-lg border-[0.5px] border-border bg-card p-4">
    <div class="min-w-0">
      <div class="text-base font-semibold text-ink">
        {{ order.guestName }}
        <span
          v-if="order.queuePosition"
          class="ml-1 text-xs font-normal text-muted"
        >#{{ order.queuePosition }}</span>
      </div>
      <div class="mt-0.5 text-sm text-muted">
        {{ order.selections.map((s) => s.name).join(', ') || order.menuPreset?.name || '—' }}
      </div>
      <div
        v-if="order.notes"
        class="mt-1 font-accent text-base text-muted"
      >
        “{{ order.notes }}”
      </div>
      <div
        v-if="order.rating || order.comments.length"
        class="mt-1 flex flex-wrap items-center gap-x-2 gap-y-1"
      >
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
    <div class="flex shrink-0 flex-col items-end gap-2">
      <span
        class="rounded-sm px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em]"
        :class="statusPillClass(order.status)"
      >
        {{ statusPillLabel(order.status) }}
      </span>
      <label
        v-if="order.status === 'IN_PROGRESS'"
        class="inline-flex cursor-pointer items-center gap-1.5 rounded-md bg-ink px-3 py-1.5 text-sm font-semibold text-surface hover:bg-ink/90"
      >
        Mark ready
        <i
          class="ti ti-camera text-base"
          aria-hidden="true"
        />
        <input
          type="file"
          accept="image/*"
          capture="environment"
          class="hidden"
          @change="complete"
        >
      </label>
      <button
        v-else-if="NEXT[order.status]"
        class="rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]"
        @click="advance"
      >
        {{ NEXT[order.status]?.label }}
      </button>
    </div>
  </div>
</template>
