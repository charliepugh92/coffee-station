<script setup lang="ts">
import { computed, onMounted, onUnmounted } from 'vue'
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
import PushToggle from '@/components/PushToggle.vue'

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

// On mobile a backgrounded tab is frozen; when it's restored (bfcache) the live
// subscription has missed the "ready" update and won't replay it, so the
// completion photo/status stay stale until a manual reload. Refetch on resume so
// the order's latest state (and its image) appears without the guest refreshing.
function refetchOnResume() {
  if (document.visibilityState === 'visible') refetch()
}
onMounted(() => {
  document.addEventListener('visibilitychange', refetchOnResume)
  window.addEventListener('pageshow', refetchOnResume)
})
onUnmounted(() => {
  document.removeEventListener('visibilitychange', refetchOnResume)
  window.removeEventListener('pageshow', refetchOnResume)
})
</script>

<template>
  <div class="rounded-lg border-[0.5px] border-border bg-card p-6 text-center">
    <span class="mx-auto mb-3 flex h-11 w-11 items-center justify-center rounded-full bg-accent-tint text-roast">
      <i
        class="ti ti-coffee text-[22px]"
        aria-hidden="true"
      />
    </span>
    <p class="font-display text-xl leading-tight">
      {{ message }}
    </p>
    <p
      v-if="order"
      class="mt-1 font-accent text-base text-muted"
    >
      {{ order.stationName }} · for {{ order.guestName }}
    </p>
    <img
      v-if="order?.completionPhotoUrl"
      :src="order.completionPhotoUrl"
      alt="Your finished drink"
      class="mx-auto mt-4 max-h-56 rounded-lg object-cover"
    >
    <div
      v-if="order && order.status !== 'READY'"
      class="mt-4 flex justify-center"
    >
      <PushToggle
        :target="{ kind: 'guest', orderToken: token }"
        label="Notify me when it's ready"
      />
    </div>
    <OrderFeedback
      v-if="order && order.status === 'READY'"
      :token="token"
      :stars="order.rating?.stars"
      @changed="refetch"
    />
  </div>
</template>
