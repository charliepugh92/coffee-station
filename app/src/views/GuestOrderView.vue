<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery, useSubscription } from '@vue/apollo-composable'
import SessionByTokenDocument from '@/graphql/gql/sessions/queries/SessionByToken.graphql'
import SessionUpdatedDocument from '@/graphql/gql/sessions/subscriptions/SessionUpdated.graphql'
import type {
  SessionByTokenQuery,
  SessionByTokenQueryVariables,
  SessionUpdatedSubscription,
  SessionUpdatedSubscriptionVariables,
} from '@/graphql/generated/types'
import { useGuestStore } from '@/stores/guest'
import OrderForm from '@/components/order/OrderForm.vue'
import OrderStatus from '@/components/order/OrderStatus.vue'

const route = useRoute()
const token = route.params.token as string
const guest = useGuestStore()
const placedToken = ref<string | null>(null)

const { result, loading } = useQuery<SessionByTokenQuery, SessionByTokenQueryVariables>(
  SessionByTokenDocument,
  { token },
)

// If the host closes the station while a guest is looking at the menu, the
// cache update flips this page to the "closed" state live (Session is
// normalized by id).
useSubscription<SessionUpdatedSubscription, SessionUpdatedSubscriptionVariables>(
  SessionUpdatedDocument,
  () => ({ sessionToken: token }),
)

function onPlaced(orderToken: string, orderId: string, guestName: string) {
  const stationName = result.value?.sessionByToken?.station.name ?? 'Coffee'
  guest.remember({ orderId, orderToken, guestName, stationName, createdAt: new Date().toISOString() })
  placedToken.value = orderToken
}
</script>

<template>
  <section class="mx-auto max-w-lg">
    <p
      v-if="loading"
      class="text-stone-400"
    >
      Loading the menu…
    </p>
    <p
      v-else-if="!result?.sessionByToken"
      class="text-stone-500"
    >
      This coffee link isn't valid.
    </p>
    <OrderStatus
      v-else-if="placedToken"
      :token="placedToken"
    />
    <p
      v-else-if="result.sessionByToken.status === 'CLOSED'"
      class="rounded bg-stone-100 p-4 text-stone-500"
    >
      ☕ This station is closed right now — check back later!
    </p>
    <div v-else>
      <h2 class="text-xl font-semibold">
        {{ result.sessionByToken.station.name }}
      </h2>
      <p
        v-if="result.sessionByToken.station.description"
        class="mt-1 mb-4 text-sm text-stone-500"
      >
        {{ result.sessionByToken.station.description }}
      </p>
      <OrderForm
        :session-token="token"
        :categories="result.sessionByToken.station.customizationCategories"
        :presets="result.sessionByToken.station.menuPresets"
        :default-name="guest.lastName"
        @placed="onPlaced"
      />
    </div>
  </section>
</template>
