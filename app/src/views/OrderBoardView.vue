<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery, useSubscription } from '@vue/apollo-composable'
import { apolloClient } from '@/utils/apolloClient'
import StationBoardDocument from '@/graphql/gql/stations/queries/StationBoard.graphql'
import OrderAddedDocument from '@/graphql/gql/orders/subscriptions/OrderAdded.graphql'
import UpdateOrderStatusDocument from '@/graphql/gql/orders/mutations/UpdateOrderStatus.graphql'
import CompleteOrderDocument from '@/graphql/gql/orders/mutations/CompleteOrder.graphql'
import type {
  StationBoardQuery,
  StationBoardQueryVariables,
  OrderAddedSubscription,
  OrderAddedSubscriptionVariables,
  UpdateOrderStatusMutation,
  UpdateOrderStatusMutationVariables,
  CompleteOrderMutation,
  CompleteOrderMutationVariables,
  OrderStatusEnum,
} from '@/graphql/generated/types'
import { statusPillClass, statusPillLabel } from '@/utils/orderStatus'

const route = useRoute()
const id = route.params.id as string
const { result, refetch } = useQuery<StationBoardQuery, StationBoardQueryVariables>(StationBoardDocument, { id })

// Live board: when a guest places an order, refetch to pull the new card and
// recompute queue positions. Enabled once the share token is known.
const shareToken = computed(() => result.value?.station?.openSession?.shareToken ?? '')
const { onResult: onOrderAdded } = useSubscription<OrderAddedSubscription, OrderAddedSubscriptionVariables>(
  OrderAddedDocument,
  () => ({ sessionToken: shareToken.value }),
  () => ({ enabled: !!shareToken.value }),
)
// TODO(style §8): flash the new row's bg-accent-tint for 200ms before settling.
onOrderAdded(() => refetch())

// PENDING → start, READY → picked up are plain status bumps. IN_PROGRESS → ready
// goes through completeOrder so a photo is captured.
const NEXT: Record<string, { status: OrderStatusEnum; label: string } | undefined> = {
  PENDING: { status: 'IN_PROGRESS', label: 'Start' },
  READY: { status: 'PICKED_UP', label: 'Picked up' },
}

async function advance(orderId: string, status: string) {
  const next = NEXT[status]
  if (!next) return
  await apolloClient.mutate<UpdateOrderStatusMutation, UpdateOrderStatusMutationVariables>({
    mutation: UpdateOrderStatusDocument,
    variables: { orderId, status: next.status },
  })
  refetch()
}

async function complete(orderId: string, event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  await apolloClient.mutate<CompleteOrderMutation, CompleteOrderMutationVariables>({
    mutation: CompleteOrderDocument,
    variables: { orderId, file },
  })
  refetch()
}
</script>

<template>
  <section class="mx-auto max-w-3xl">
    <RouterLink
      :to="`/stations/${id}`"
      class="inline-flex items-center gap-1 text-sm text-muted hover:text-ink"
    >
      <i
        class="ti ti-arrow-left"
        aria-hidden="true"
      />
      Station
    </RouterLink>
    <h2 class="mt-2 font-display text-2xl">
      {{ result?.station?.name }} — order board
    </h2>

    <p
      v-if="!result?.station?.openSession"
      class="mt-4 rounded-md bg-sunken p-4 text-sm text-muted"
    >
      This station isn't open. Open it from the station page to take orders.
    </p>
    <div
      v-else
      class="mt-4 space-y-2"
    >
      <p
        v-if="!result.station.openSession.orders.length"
        class="text-sm text-muted"
      >
        No orders yet.
      </p>
      <div
        v-for="o in result.station.openSession.orders"
        :key="o.id"
        class="flex items-start justify-between gap-3 rounded-lg border-[0.5px] border-border bg-card p-4"
      >
        <div class="min-w-0">
          <div class="text-base font-semibold text-ink">
            {{ o.guestName }}
            <span
              v-if="o.queuePosition"
              class="ml-1 text-xs font-normal text-muted"
            >#{{ o.queuePosition }}</span>
          </div>
          <div class="mt-0.5 text-sm text-muted">
            {{ o.selections.map((s) => s.name).join(', ') || o.menuPreset?.name || '—' }}
          </div>
          <div
            v-if="o.notes"
            class="mt-1 font-accent text-base text-muted"
          >
            “{{ o.notes }}”
          </div>
          <div
            v-if="o.rating || o.comments.length"
            class="mt-1 flex flex-wrap items-center gap-x-2 gap-y-1"
          >
            <span
              v-if="o.rating"
              class="inline-flex items-center gap-0.5 text-caramel"
              :aria-label="`Rated ${o.rating.stars} of 5`"
            >
              <i
                v-for="n in o.rating.stars"
                :key="n"
                class="ti ti-star text-sm"
                aria-hidden="true"
              />
            </span>
            <span
              v-for="c in o.comments"
              :key="c.id"
              class="font-accent text-base text-muted"
            >“{{ c.body }}”</span>
          </div>
        </div>
        <div class="flex shrink-0 flex-col items-end gap-2">
          <span
            class="rounded-sm px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em]"
            :class="statusPillClass(o.status)"
          >
            {{ statusPillLabel(o.status) }}
          </span>
          <label
            v-if="o.status === 'IN_PROGRESS'"
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
              @change="complete(o.id, $event)"
            >
          </label>
          <button
            v-else-if="NEXT[o.status]"
            class="rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]"
            @click="advance(o.id, o.status)"
          >
            {{ NEXT[o.status]?.label }}
          </button>
        </div>
      </div>
    </div>
  </section>
</template>
