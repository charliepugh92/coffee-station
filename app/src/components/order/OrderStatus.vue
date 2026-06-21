<script setup lang="ts">
import { computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import OrderByTokenDocument from '@/graphql/gql/orders/queries/OrderByToken.graphql'
import type { OrderByTokenQuery, OrderByTokenQueryVariables } from '@/graphql/generated/types'
import { orderStatusMessage } from '@/utils/orderStatus'

const props = defineProps<{ token: string }>()

const { result } = useQuery<OrderByTokenQuery, OrderByTokenQueryVariables>(
  OrderByTokenDocument,
  () => ({ token: props.token }),
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
  </div>
</template>
