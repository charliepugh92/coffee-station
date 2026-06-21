<script setup lang="ts">
import { computed } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import OpenSessionDocument from '@/graphql/gql/sessions/mutations/OpenSession.graphql'
import CloseSessionDocument from '@/graphql/gql/sessions/mutations/CloseSession.graphql'
import type {
  StationDetailFragment,
  OpenSessionMutation,
  OpenSessionMutationVariables,
  CloseSessionMutation,
  CloseSessionMutationVariables,
} from '@/graphql/generated/types'

const props = defineProps<{ station: StationDetailFragment }>()
const emit = defineEmits<{ changed: [] }>()

const shareLink = computed(() => {
  const token = props.station.openSession?.shareToken
  return token ? `${window.location.origin}/s/${token}` : null
})

async function open() {
  await apolloClient.mutate<OpenSessionMutation, OpenSessionMutationVariables>({
    mutation: OpenSessionDocument,
    variables: { stationId: props.station.id },
  })
  emit('changed')
}

async function close() {
  const id = props.station.openSession?.id
  if (!id) return
  await apolloClient.mutate<CloseSessionMutation, CloseSessionMutationVariables>({
    mutation: CloseSessionDocument,
    variables: { id },
  })
  emit('changed')
}

async function copyLink() {
  if (shareLink.value) await navigator.clipboard.writeText(shareLink.value)
}
</script>

<template>
  <div class="rounded border border-stone-200 bg-white p-3">
    <template v-if="station.openSession">
      <div class="flex items-center justify-between">
        <span class="text-sm font-medium text-green-700">● Open for orders</span>
        <button
          class="text-xs text-red-500 hover:text-red-700"
          @click="close"
        >
          Close station
        </button>
      </div>
      <div class="mt-2 flex items-center gap-2">
        <code class="flex-1 truncate rounded bg-stone-100 px-2 py-1 text-xs text-stone-600">{{ shareLink }}</code>
        <button
          class="rounded border border-stone-300 px-2 py-1 text-xs hover:bg-stone-100"
          @click="copyLink"
        >
          Copy
        </button>
      </div>
    </template>
    <div
      v-else
      class="flex items-center justify-between"
    >
      <span class="text-sm text-stone-500">Closed</span>
      <button
        class="rounded bg-stone-800 px-3 py-1 text-sm text-white"
        @click="open"
      >
        Open station
      </button>
    </div>
  </div>
</template>
