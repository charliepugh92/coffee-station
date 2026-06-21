<script setup lang="ts">
import { computed } from 'vue'
import { useQuery, useSubscription } from '@vue/apollo-composable'
import OrderByTokenDocument from '@/graphql/gql/orders/queries/OrderByToken.graphql'
import OrderUpdatedDocument from '@/graphql/gql/orders/subscriptions/OrderUpdated.graphql'
import type {
  OrderByTokenQuery,
  OrderByTokenQueryVariables,
  OrderUpdatedSubscription,
  OrderUpdatedSubscriptionVariables,
} from '@/graphql/generated/types'
import { orderStatusMessage } from '@/utils/orderStatus'
import OrderFeedback from '@/components/order/OrderFeedback.vue'

const props = defineProps<{ token: string }>()

const { result, refetch } = useQuery<OrderByTokenQuery, OrderByTokenQueryVariables>(
  OrderByTokenDocument,
  () => ({ token: props.token }),
)

// Live updates: the cache normalizes Order by id, so delivering the updated
// order here automatically refreshes the query result above (status, queue
// position, completion photo) with no refetch.
useSubscription<OrderUpdatedSubscription, OrderUpdatedSubscriptionVariables>(
  OrderUpdatedDocument,
  () => ({ orderToken: props.token }),
)

const order = computed(() => result.value?.orderByToken ?? null)
const message = computed(() => (order.value ? orderStatusMessage(order.value) : 'Loading…'))
</script>

<template>
  <div class="rounded-lg border border-stone-200 bg-white p-6 text-center">
    <p class="text-lg font-semibold text-stone-800">
      {{ message }}
    </p>
    <p
      v-if="order"
      class="mt-1 text-sm text-stone-400"
    >
      {{ order.stationName }} · for {{ order.guestName }}
    </p>
    <img
      v-if="order?.completionPhotoUrl"
      :src="order.completionPhotoUrl"
      alt="Your finished drink"
      class="mx-auto mt-4 max-h-56 rounded-lg object-cover"
    >
    <OrderFeedback
      v-if="order && (order.status === 'READY' || order.status === 'PICKED_UP')"
      :token="token"
      :stars="order.rating?.stars"
      @changed="refetch"
    />
  </div>
</template>
