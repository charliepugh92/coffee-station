<script setup lang="ts">
import { computed, ref } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { useRouter } from 'vue-router'
import { apolloClient } from '@/utils/apolloClient'
import { useAuthStore } from '@/stores/auth'
import MySessionsDocument from '@/graphql/gql/auth/queries/MySessions.graphql'
import RevokeSessionDocument from '@/graphql/gql/auth/mutations/RevokeSession.graphql'
import type {
  MySessionsQuery,
  RevokeSessionMutation,
  RevokeSessionMutationVariables,
} from '@/graphql/generated/types'

type Session = NonNullable<MySessionsQuery['me']>['sessions'][number]

const auth = useAuthStore()
const router = useRouter()

const { result, loading, refetch } = useQuery<MySessionsQuery>(MySessionsDocument, {}, {
  fetchPolicy: 'network-only',
})
const sessions = computed<Session[]>(() => result.value?.me?.sessions ?? [])

const revokingId = ref<string | null>(null)

// "5 minutes ago" / "2 days ago", via the built-in formatter (no date lib in use).
function lastActive(iso: string | null): string {
  if (!iso) return 'not yet used'
  const rtf = new Intl.RelativeTimeFormat(undefined, { numeric: 'auto' })
  const mins = Math.round((Date.now() - new Date(iso).getTime()) / 60000)
  if (Math.abs(mins) < 60) return rtf.format(-mins, 'minute')
  const hours = Math.round(mins / 60)
  if (Math.abs(hours) < 24) return rtf.format(-hours, 'hour')
  return rtf.format(-Math.round(hours / 24), 'day')
}

async function signOutDevice(session: Session) {
  // Revoking the current device's own token invalidates this session, so route
  // it through the normal logout (also unsubscribes push + clears local auth).
  if (session.current) {
    await auth.logout()
    router.push({ name: 'login' })
    return
  }
  revokingId.value = session.id
  try {
    await apolloClient.mutate<RevokeSessionMutation, RevokeSessionMutationVariables>({
      mutation: RevokeSessionDocument,
      variables: { sessionId: session.id },
    })
    await refetch()
  } finally {
    revokingId.value = null
  }
}
</script>

<template>
  <section class="mt-4 space-y-3 rounded-lg border-[0.5px] border-border bg-card p-4">
    <div>
      <h3 class="font-display text-lg leading-tight">
        Signed-in devices
      </h3>
      <p class="text-sm text-muted">
        You stay signed in on every device. Sign out any you no longer use.
      </p>
    </div>

    <p
      v-if="loading && !sessions.length"
      class="text-sm text-muted"
    >
      Loading your devices…
    </p>

    <ul
      v-else
      class="divide-y divide-border"
    >
      <li
        v-for="session in sessions"
        :key="session.id"
        class="flex items-center justify-between gap-3 py-3 first:pt-0 last:pb-0"
      >
        <div class="min-w-0">
          <p class="flex items-center gap-2 truncate font-medium text-ink">
            {{ session.deviceLabel ?? 'Unknown device' }}
            <span
              v-if="session.current"
              class="rounded-full bg-success-tint px-2 py-0.5 text-xs font-semibold text-success"
            >
              This device
            </span>
          </p>
          <p class="text-sm text-muted">
            Active {{ lastActive(session.lastActiveAt) }}
          </p>
        </div>
        <button
          type="button"
          class="shrink-0 rounded-lg border-[0.5px] border-border px-3 py-1.5 text-sm font-semibold text-ink hover:bg-sunken disabled:opacity-45"
          :disabled="revokingId === session.id"
          @click="signOutDevice(session)"
        >
          Sign out
        </button>
      </li>
    </ul>
  </section>
</template>
