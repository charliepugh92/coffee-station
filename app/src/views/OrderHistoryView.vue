<script setup lang="ts">
import { ref, computed } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { apolloClient } from '@/utils/apolloClient'
import OrderHistoryDocument from '@/graphql/gql/orders/queries/OrderHistory.graphql'
import MyStationsDocument from '@/graphql/gql/stations/queries/MyStations.graphql'
import DeleteOrderDocument from '@/graphql/gql/orders/mutations/DeleteOrder.graphql'
import type {
  OrderHistoryQuery,
  OrderHistoryQueryVariables,
  MyStationsQuery,
  DeleteOrderMutation,
  DeleteOrderMutationVariables,
} from '@/graphql/generated/types'
import HostOrderCard from '@/components/order/HostOrderCard.vue'

const stationFilter = ref('')

const { result: stationsResult } = useQuery<MyStationsQuery>(MyStationsDocument)
const stations = computed(() => stationsResult.value?.myStations ?? [])

const { result, loading, refetch } = useQuery<OrderHistoryQuery, OrderHistoryQueryVariables>(
  OrderHistoryDocument,
  () => ({ stationId: stationFilter.value || undefined }),
)
const orders = computed(() => result.value?.orderHistory ?? [])

async function remove(orderId: string, guestName: string) {
  if (!window.confirm(`Delete ${guestName}'s order and its photo? This can't be undone.`)) return
  await apolloClient.mutate<DeleteOrderMutation, DeleteOrderMutationVariables>({
    mutation: DeleteOrderDocument,
    variables: { orderId },
  })
  await refetch()
}
</script>

<template>
  <section class="mx-auto max-w-3xl">
    <RouterLink
      to="/dashboard"
      class="inline-flex items-center gap-1 text-sm text-muted hover:text-ink"
    >
      <i
        class="ti ti-arrow-left"
        aria-hidden="true"
      />
      Dashboard
    </RouterLink>
    <div class="mt-2 flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
      <h2 class="font-display text-2xl">
        Order history
      </h2>
      <div
        v-if="stations.length"
        class="relative w-full sm:w-56"
      >
        <select
          v-model="stationFilter"
          class="w-full appearance-none rounded-md border-[0.5px] border-border bg-card px-3 py-2 pr-9 text-sm text-ink focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
        >
          <option value="">
            All stations
          </option>
          <option
            v-for="s in stations"
            :key="s.id"
            :value="s.id"
          >
            {{ s.name }}
          </option>
        </select>
        <i
          class="ti ti-chevron-down pointer-events-none absolute top-1/2 right-3 -translate-y-1/2 text-muted"
          aria-hidden="true"
        />
      </div>
    </div>

    <p
      v-if="loading"
      class="mt-6 text-sm text-muted"
    >
      Loading orders…
    </p>
    <p
      v-else-if="!orders.length"
      class="mt-6 rounded-md bg-sunken p-4 text-sm text-muted"
    >
      No orders yet.
    </p>
    <div
      v-else
      class="mt-6 grid grid-cols-1 gap-4 sm:grid-cols-2"
    >
      <HostOrderCard
        v-for="o in orders"
        :key="o.id"
        :order="o"
        @delete="remove"
      />
    </div>
  </section>
</template>
