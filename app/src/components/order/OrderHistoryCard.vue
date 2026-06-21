<script setup lang="ts">
import { useSubscription } from '@vue/apollo-composable'
import { apolloClient } from '@/utils/apolloClient'
import OrderUpdatedDocument from '@/graphql/gql/orders/subscriptions/OrderUpdated.graphql'
import ReorderDocument from '@/graphql/gql/orders/mutations/Reorder.graphql'
import type {
  OrderFieldsFragment,
  OrderUpdatedSubscription,
  OrderUpdatedSubscriptionVariables,
  ReorderMutation,
  ReorderMutationVariables,
} from '@/graphql/generated/types'
import { orderStatusMessage } from '@/utils/orderStatus'
import OrderFeedback from '@/components/order/OrderFeedback.vue'

const props = defineProps<{ order: OrderFieldsFragment; token: string }>()
const emit = defineEmits<{ reordered: [orderId: string, token: string, stationName: string] }>()

// Live status for still-active orders; the cache auto-merges by Order id.
useSubscription<OrderUpdatedSubscription, OrderUpdatedSubscriptionVariables>(
  OrderUpdatedDocument,
  () => ({ orderToken: props.token }),
)

async function reorder() {
  const { data } = await apolloClient.mutate<ReorderMutation, ReorderMutationVariables>({
    mutation: ReorderDocument,
    variables: { orderToken: props.token },
  })
  const res = data?.reorder
  if (res?.order && res.guestToken) emit('reordered', res.order.id, res.guestToken, res.order.stationName)
}
</script>

<template>
  <div class="rounded-lg border border-stone-200 bg-white p-4">
    <div class="flex items-start justify-between">
      <div>
        <p class="font-medium">
          {{ order.stationName }}
        </p>
        <p class="text-sm text-stone-500">
          {{ order.selections.map((s) => s.name).join(', ') || order.menuPreset?.name || '—' }}
        </p>
      </div>
      <span class="text-xs text-stone-400">{{ orderStatusMessage(order) }}</span>
    </div>
    <img
      v-if="order.completionPhotoUrl"
      :src="order.completionPhotoUrl"
      alt=""
      class="mt-3 max-h-40 rounded object-cover"
    >
    <div class="mt-3">
      <button
        v-if="order.canReorder"
        class="rounded bg-stone-800 px-3 py-1 text-xs text-white"
        @click="reorder"
      >
        Order again
      </button>
      <span
        v-else
        class="text-xs text-stone-400"
      >Station closed</span>
    </div>
    <OrderFeedback
      :token="token"
      :stars="order.rating?.stars"
    />
  </div>
</template>
