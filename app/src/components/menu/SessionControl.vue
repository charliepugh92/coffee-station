<script setup lang="ts">
import { computed, ref, watchEffect } from 'vue'
import QRCode from 'qrcode'
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

const qrDataUrl = ref('')
watchEffect(async () => {
  qrDataUrl.value = shareLink.value
    ? await QRCode.toDataURL(shareLink.value, { width: 160, margin: 1 })
    : ''
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
  <div class="rounded-lg border-[0.5px] border-border bg-card p-4">
    <template v-if="station.openSession">
      <div class="flex items-center justify-between">
        <span class="rounded-sm bg-success-tint px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em] text-success">
          Open
        </span>
        <button
          class="text-sm text-error hover:text-error/80"
          @click="close"
        >
          Close station
        </button>
      </div>
      <div class="mt-3 flex items-center gap-2">
        <code class="flex-1 truncate rounded-md bg-sunken px-2 py-1 font-mono text-xs text-muted">{{ shareLink }}</code>
        <button
          class="inline-flex items-center gap-1 rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm font-semibold text-ink hover:bg-sunken"
          @click="copyLink"
        >
          <i
            class="ti ti-copy text-base"
            aria-hidden="true"
          />
          Copy
        </button>
      </div>
      <div
        v-if="qrDataUrl"
        class="mx-auto mt-4 w-fit rounded-lg border-[0.5px] border-border bg-surface p-3"
      >
        <img
          :src="qrDataUrl"
          alt="Scan to order"
          class="block h-40 w-40"
        >
      </div>
    </template>
    <div
      v-else
      class="flex items-center justify-between"
    >
      <span class="rounded-sm bg-picked-up px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em] text-muted">
        Closed
      </span>
      <button
        class="rounded-lg bg-roast px-4 py-2 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]"
        @click="open"
      >
        Open station
      </button>
    </div>
  </div>
</template>
