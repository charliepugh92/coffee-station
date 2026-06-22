<script setup lang="ts">
import { ref } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import UpdateOrderStatusDocument from '@/graphql/gql/orders/mutations/UpdateOrderStatus.graphql'
import CompleteOrderDocument from '@/graphql/gql/orders/mutations/CompleteOrder.graphql'
import DeleteOrderDocument from '@/graphql/gql/orders/mutations/DeleteOrder.graphql'
import type {
  UpdateOrderStatusMutation,
  UpdateOrderStatusMutationVariables,
  CompleteOrderMutation,
  CompleteOrderMutationVariables,
  DeleteOrderMutation,
  DeleteOrderMutationVariables,
  OrderStatusEnum,
} from '@/graphql/generated/types'
import { statusPillClass, statusPillLabel } from '@/utils/orderStatus'
import PhotoConfirmModal from '@/components/order/PhotoConfirmModal.vue'

interface BoardOrder {
  id: string
  guestName: string
  status: string
  queuePosition?: number | null
  notes?: string | null
  selections: { name: string }[]
  menuPreset?: { name: string } | null
  rating?: { stars: number } | null
  comments: { id: string; body: string }[]
}

const props = defineProps<{ order: BoardOrder }>()
const emit = defineEmits<{ changed: [] }>()

// PENDING → start is a plain status bump. IN_PROGRESS → ready goes through
// completeOrder so a photo is captured; READY is terminal (the order then drops
// off the board into the host's order history).
const NEXT: Record<string, { status: OrderStatusEnum; label: string } | undefined> = {
  PENDING: { status: 'IN_PROGRESS', label: 'Start' },
}

async function advance() {
  const next = NEXT[props.order.status]
  if (!next) return
  await apolloClient.mutate<UpdateOrderStatusMutation, UpdateOrderStatusMutationVariables>({
    mutation: UpdateOrderStatusDocument,
    variables: { orderId: props.order.id, status: next.status },
  })
  emit('changed')
}

async function remove() {
  if (!window.confirm(`Delete ${props.order.guestName}'s order? This can't be undone.`)) return
  await apolloClient.mutate<DeleteOrderMutation, DeleteOrderMutationVariables>({
    mutation: DeleteOrderDocument,
    variables: { orderId: props.order.id },
  })
  emit('changed')
}

// Marking ready captures a photo, then previews it for confirmation before the
// upload fires. Confirming runs completeOrder; only on success do we close and
// refetch, so a failed upload keeps the modal open instead of silently dropping
// the photo and leaving the order stuck in IN_PROGRESS.
const fileInput = ref<HTMLInputElement | null>(null)
const previewFile = ref<File | null>(null)
const previewUrl = ref('')
const submitting = ref(false)
const errorMsg = ref('')

function clearPreview() {
  if (previewUrl.value) URL.revokeObjectURL(previewUrl.value)
  previewUrl.value = ''
  previewFile.value = null
  errorMsg.value = ''
}

function onCapture(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  // Reset so re-selecting the same file (e.g. after Retake) still fires @change.
  input.value = ''
  if (!file) return
  if (previewUrl.value) URL.revokeObjectURL(previewUrl.value)
  previewFile.value = file
  previewUrl.value = URL.createObjectURL(file)
  errorMsg.value = ''
}

async function confirmComplete() {
  if (!previewFile.value || submitting.value) return
  submitting.value = true
  errorMsg.value = ''
  try {
    await apolloClient.mutate<CompleteOrderMutation, CompleteOrderMutationVariables>({
      mutation: CompleteOrderDocument,
      variables: { orderId: props.order.id, file: previewFile.value },
    })
    clearPreview()
    emit('changed')
  } catch {
    errorMsg.value = "Couldn't save the photo. Check your connection and try again."
  } finally {
    submitting.value = false
  }
}

function retake() {
  clearPreview()
  fileInput.value?.click()
}

function cancelPreview() {
  if (submitting.value) return
  clearPreview()
}
</script>

<template>
  <div class="flex items-start justify-between gap-3 rounded-lg border-[0.5px] border-border bg-card p-4">
    <div class="min-w-0">
      <div class="text-base font-semibold text-ink">
        {{ order.guestName }}
        <span
          v-if="order.queuePosition"
          class="ml-1 text-xs font-normal text-muted"
        >#{{ order.queuePosition }}</span>
      </div>
      <div class="mt-0.5 text-sm text-muted">
        {{ order.selections.map((s) => s.name).join(', ') || order.menuPreset?.name || '—' }}
      </div>
      <div
        v-if="order.notes"
        class="mt-1 font-accent text-base text-muted"
      >
        “{{ order.notes }}”
      </div>
      <div
        v-if="order.rating || order.comments.length"
        class="mt-1 flex flex-wrap items-center gap-x-2 gap-y-1"
      >
        <span
          v-if="order.rating"
          class="inline-flex items-center gap-0.5 text-caramel"
          :aria-label="`Rated ${order.rating.stars} of 5`"
        >
          <i
            v-for="n in order.rating.stars"
            :key="n"
            class="ti ti-star text-sm"
            aria-hidden="true"
          />
        </span>
        <span
          v-for="c in order.comments"
          :key="c.id"
          class="font-accent text-base text-muted"
        >“{{ c.body }}”</span>
      </div>
    </div>
    <div class="flex shrink-0 flex-col items-end gap-2">
      <span
        class="rounded-sm px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em]"
        :class="statusPillClass(order.status)"
      >
        {{ statusPillLabel(order.status) }}
      </span>
      <label
        v-if="order.status === 'IN_PROGRESS'"
        class="inline-flex cursor-pointer items-center gap-1.5 rounded-md bg-ink px-3 py-1.5 text-sm font-semibold text-surface hover:bg-ink/90"
      >
        Mark ready
        <i
          class="ti ti-camera text-base"
          aria-hidden="true"
        />
        <input
          ref="fileInput"
          type="file"
          accept="image/*"
          capture="environment"
          class="hidden"
          @change="onCapture"
        >
      </label>
      <button
        v-else-if="NEXT[order.status]"
        class="rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]"
        @click="advance"
      >
        {{ NEXT[order.status]?.label }}
      </button>
      <button
        class="text-xs text-muted hover:text-error"
        aria-label="Delete order"
        @click="remove"
      >
        Delete
      </button>
    </div>
  </div>

  <PhotoConfirmModal
    v-if="previewFile"
    :preview-url="previewUrl"
    :submitting="submitting"
    :error-msg="errorMsg"
    @confirm="confirmComplete"
    @retake="retake"
    @cancel="cancelPreview"
  />
</template>
