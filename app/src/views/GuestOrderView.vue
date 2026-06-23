<script setup lang="ts">
import { useRoute, useRouter } from 'vue-router'
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

const route = useRoute()
const router = useRouter()
const token = route.params.token as string
const guest = useGuestStore()

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
  // Land on the stable order page so the URL is reloadable/shareable and matches
  // the push deep-link, where the guest can track status and enable alerts.
  router.push({ name: 'order-status', params: { token: orderToken } })
}
</script>

<template>
  <section class="mx-auto max-w-lg">
    <p
      v-if="loading"
      class="text-muted"
    >
      Loading the menu…
    </p>
    <p
      v-else-if="!result?.sessionByToken"
      class="rounded-md bg-sunken p-4 text-muted"
    >
      This coffee link isn't valid.
    </p>
    <p
      v-else-if="result.sessionByToken.status === 'CLOSED'"
      class="rounded-md bg-sunken p-4 text-muted"
    >
      ☕ This station is closed right now — check back later!
    </p>
    <div v-else>
      <h2 class="font-display text-2xl">
        {{ result.sessionByToken.station.name }}
      </h2>
      <p
        v-if="result.sessionByToken.station.description"
        class="mt-1 mb-4 text-sm text-muted"
      >
        {{ result.sessionByToken.station.description }}
      </p>
      <OrderForm
        :session-token="token"
        :categories="result.sessionByToken.station.customizationCategories"
        :presets="result.sessionByToken.station.menuPresets"
        :bases="result.sessionByToken.station.bases"
        :default-name="guest.lastName"
        @placed="onPlaced"
      />
    </div>
  </section>
</template>
