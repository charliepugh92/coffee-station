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
      class="text-sm text-stone-500 hover:text-stone-800"
    >
      ← Station
    </RouterLink>
    <h2 class="mt-2 text-lg font-semibold">
      {{ result?.station?.name }} — order board
    </h2>

    <p
      v-if="!result?.station?.openSession"
      class="mt-4 text-stone-500"
    >
      This station isn't open. Open it from the station page to take orders.
    </p>
    <div
      v-else
      class="mt-4 space-y-2"
    >
      <p
        v-if="!result.station.openSession.orders.length"
        class="text-stone-400"
      >
        No orders yet.
      </p>
      <div
        v-for="o in result.station.openSession.orders"
        :key="o.id"
        class="flex items-center justify-between rounded border border-stone-200 bg-white p-3"
      >
        <div>
          <div class="font-medium">
            {{ o.guestName }}
            <span
              v-if="o.queuePosition"
              class="text-xs text-stone-400"
            >#{{ o.queuePosition }}</span>
          </div>
          <div class="text-sm text-stone-500">
            {{ o.selections.map((s) => s.name).join(', ') || o.menuPreset?.name || '—' }}
          </div>
          <div
            v-if="o.notes"
            class="text-xs text-stone-400"
          >
            “{{ o.notes }}”
          </div>
        </div>
        <div class="flex items-center gap-3">
          <span class="text-xs uppercase tracking-wide text-stone-400">{{ o.status.replace('_', ' ') }}</span>
          <label
            v-if="o.status === 'IN_PROGRESS'"
            class="cursor-pointer rounded bg-stone-800 px-3 py-1 text-xs text-white"
          >
            Mark ready 📷
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
            class="rounded bg-stone-800 px-3 py-1 text-xs text-white"
            @click="advance(o.id, o.status)"
          >
            {{ NEXT[o.status]?.label }}
          </button>
        </div>
      </div>
    </div>
  </section>
</template>
