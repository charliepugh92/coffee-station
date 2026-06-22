<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery, useSubscription } from '@vue/apollo-composable'
import StationBoardDocument from '@/graphql/gql/stations/queries/StationBoard.graphql'
import OrderAddedDocument from '@/graphql/gql/orders/subscriptions/OrderAdded.graphql'
import type {
  StationBoardQuery,
  StationBoardQueryVariables,
  OrderAddedSubscription,
  OrderAddedSubscriptionVariables,
} from '@/graphql/generated/types'
import OrderBoardRow from '@/components/order/OrderBoardRow.vue'

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

// The board is the live make-line: only orders still being worked. Once an order
// is completed (READY) it leaves the queue and lives in the host's order history.
const activeOrders = computed(
  () => result.value?.station?.openSession?.orders.filter((o) => o.status !== 'READY') ?? [],
)
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
        v-if="!activeOrders.length"
        class="text-sm text-muted"
      >
        No orders yet.
      </p>
      <OrderBoardRow
        v-for="o in activeOrders"
        :key="o.id"
        :order="o"
        @changed="refetch"
      />
    </div>
  </section>
</template>
