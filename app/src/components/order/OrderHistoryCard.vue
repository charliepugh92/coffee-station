<script setup lang="ts">
import { ref } from 'vue'
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
import { statusPillClass, statusPillLabel } from '@/utils/orderStatus'
import { memorySummary } from '@/utils/orderMemory'
import OrderFeedback from '@/components/order/OrderFeedback.vue'

const props = defineProps<{ order: OrderFieldsFragment; token: string }>()
const emit = defineEmits<{ reordered: [orderId: string, token: string, stationName: string] }>()

// Live status for still-active orders; the cache auto-merges by Order id.
useSubscription<OrderUpdatedSubscription, OrderUpdatedSubscriptionVariables>(
  OrderUpdatedDocument,
  () => ({ orderToken: props.token }),
)

// Parts of a reorder the current menu could no longer reproduce, shown to the guest.
const warnings = ref<string[]>([])

async function reorder() {
  const { data } = await apolloClient.mutate<ReorderMutation, ReorderMutationVariables>({
    mutation: ReorderDocument,
    variables: { orderToken: props.token },
  })
  const res = data?.reorder
  if (!res?.order || !res.guestToken) return
  warnings.value = res.warnings
  emit('reordered', res.order.id, res.guestToken, res.order.stationName)
}
</script>

<template>
  <div class="rounded-lg border-[0.5px] border-border bg-card p-4">
    <div class="flex items-start justify-between gap-3">
      <div>
        <p class="font-display text-lg leading-tight">
          {{ order.stationName }}
        </p>
        <p class="mt-1 text-sm text-muted">
          {{ memorySummary(order.memory) }}
        </p>
      </div>
      <span
        class="rounded-sm px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em]"
        :class="statusPillClass(order.status)"
      >
        {{ statusPillLabel(order.status) }}
      </span>
    </div>
    <img
      v-if="order.completionPhotoUrl"
      :src="order.completionPhotoUrl"
      alt=""
      class="mt-3 max-h-40 rounded-lg object-cover"
    >
    <div class="mt-3 flex items-center gap-4">
      <button
        v-if="order.canReorder"
        class="rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]"
        @click="reorder"
      >
        Order again
      </button>
      <span
        v-else
        class="text-xs text-muted"
      >Station closed</span>
      <RouterLink
        v-if="order.status !== 'READY'"
        :to="{ name: 'order-status', params: { token } }"
        class="text-sm font-semibold text-roast hover:underline"
      >
        Track &amp; get notified →
      </RouterLink>
    </div>
    <div
      v-if="warnings.length"
      class="mt-2 rounded-md bg-sunken p-2 text-xs text-muted"
    >
      <p class="font-semibold text-ink">
        We couldn't fully recreate your order:
      </p>
      <p
        v-for="(w, i) in warnings"
        :key="i"
      >
        {{ w }}
      </p>
    </div>
    <OrderFeedback
      :token="token"
      :stars="order.rating?.stars"
    />
  </div>
</template>
