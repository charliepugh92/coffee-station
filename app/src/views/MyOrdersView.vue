<script setup lang="ts">
import { computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import OrdersByTokensDocument from '@/graphql/gql/orders/queries/OrdersByTokens.graphql'
import type { OrdersByTokensQuery, OrdersByTokensQueryVariables } from '@/graphql/generated/types'
import { useGuestStore } from '@/stores/guest'
import OrderHistoryCard from '@/components/order/OrderHistoryCard.vue'

const guest = useGuestStore()
const tokens = computed(() => guest.orders.map((o) => o.orderToken))

const { result } = useQuery<OrdersByTokensQuery, OrdersByTokensQueryVariables>(
  OrdersByTokensDocument,
  () => ({ tokens: tokens.value }),
  () => ({ enabled: tokens.value.length > 0 }),
)

function tokenFor(orderId: string): string {
  return guest.orders.find((o) => o.orderId === orderId)?.orderToken ?? ''
}

function onReordered(orderId: string, token: string, stationName: string) {
  guest.remember({
    orderId,
    orderToken: token,
    guestName: guest.lastName,
    stationName,
    createdAt: new Date().toISOString(),
  })
}
</script>

<template>
  <section class="mx-auto max-w-lg">
    <h2 class="text-lg font-semibold">
      Your orders
    </h2>
    <p
      v-if="!tokens.length"
      class="mt-2 text-sm text-stone-500"
    >
      You haven't ordered yet. Orders you place are saved on this device so you can
      track them, reorder, and leave a review later.
    </p>
    <div
      v-else
      class="mt-4 space-y-3"
    >
      <OrderHistoryCard
        v-for="o in result?.ordersByTokens ?? []"
        :key="o.id"
        :order="o"
        :token="tokenFor(o.id)"
        @reordered="onReordered"
      />
    </div>
  </section>
</template>
