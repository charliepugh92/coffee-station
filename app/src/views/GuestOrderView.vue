<script setup lang="ts">
import { useRoute } from 'vue-router'
import { useQuery } from '@vue/apollo-composable'
import SessionByTokenDocument from '@/graphql/gql/sessions/queries/SessionByToken.graphql'
import type { SessionByTokenQuery, SessionByTokenQueryVariables } from '@/graphql/generated/types'

const route = useRoute()
const token = route.params.token as string
const { result, loading } = useQuery<SessionByTokenQuery, SessionByTokenQueryVariables>(
  SessionByTokenDocument,
  { token },
)
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
        class="mt-1 text-sm text-stone-500"
      >
        {{ result.sessionByToken.station.description }}
      </p>
      <div
        v-for="c in result.sessionByToken.station.customizationCategories"
        :key="c.id"
        class="mt-4"
      >
        <h3 class="text-sm font-medium text-stone-700">
          {{ c.name }}
        </h3>
        <ul class="mt-1 text-sm text-stone-600">
          <li
            v-for="o in c.options"
            :key="o.id"
          >
            {{ o.name }}
            <span
              v-if="o.surchargeCents"
              class="text-stone-400"
            >+{{ (o.surchargeCents / 100).toFixed(2) }}</span>
          </li>
        </ul>
      </div>
    </div>
  </section>
</template>
