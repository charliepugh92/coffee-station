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
import { downscaleImage } from '@/utils/downscaleImage'
import { type OrderMemory } from '@/utils/orderMemory'
import PhotoConfirmModal from '@/components/order/PhotoConfirmModal.vue'
import OrderBoardRowDetails from '@/components/order/OrderBoardRowDetails.vue'

interface BoardOrder {
  id: string
  guestName: string
  status: string
  queuePosition?: number | null
  notes?: string | null
  memory: OrderMemory
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

async function onCapture(event: Event) {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  // Reset so re-selecting the same file (e.g. after Retake) still fires @change.
  input.value = ''
  if (!file) return
  // Downscale before previewing so what's shown is exactly what gets uploaded.
  const processed = await downscaleImage(file)
  if (previewUrl.value) URL.revokeObjectURL(previewUrl.value)
  previewFile.value = processed
  previewUrl.value = URL.createObjectURL(processed)
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

// Mark ready without a photo — same mutation, file omitted. Useful when there's
// no time to snap a photo, and it sidesteps the upload path entirely.
async function completeWithoutPhoto() {
  if (submitting.value) return
  submitting.value = true
  errorMsg.value = ''
  try {
    await apolloClient.mutate<CompleteOrderMutation, CompleteOrderMutationVariables>({
      mutation: CompleteOrderDocument,
      variables: { orderId: props.order.id, file: null },
    })
    emit('changed')
  } catch {
    errorMsg.value = "Couldn't mark ready. Check your connection and try again."
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
    <OrderBoardRowDetails :order="order" />
    <div class="flex shrink-0 flex-col items-end gap-2">
      <span
        class="rounded-sm px-2 py-1 text-[11px] font-semibold uppercase tracking-[.08em]"
        :class="statusPillClass(order.status)"
      >
        {{ statusPillLabel(order.status) }}
      </span>
      <template v-if="order.status === 'IN_PROGRESS'">
        <div class="flex items-center gap-1.5">
          <!-- A <button> (not a <label>) so it's keyboard-focusable; it opens the
               hidden file input programmatically. -->
          <button
            type="button"
            :disabled="submitting"
            class="inline-flex items-center gap-1.5 rounded-md bg-ink px-3 py-1.5 text-sm font-semibold text-surface hover:bg-ink/90 disabled:opacity-45"
            @click="fileInput?.click()"
          >
            Mark ready
            <i
              class="ti ti-camera text-base"
              aria-hidden="true"
            />
          </button>
          <input
            ref="fileInput"
            type="file"
            accept="image/*"
            capture="environment"
            class="hidden"
            @change="onCapture"
          >
          <button
            type="button"
            :disabled="submitting"
            aria-label="Mark ready without a photo"
            title="Mark ready without a photo"
            class="inline-flex items-center justify-center rounded-md border-[0.5px] border-border p-1.5 text-muted hover:border-ink/30 hover:text-ink disabled:opacity-45"
            @click="completeWithoutPhoto"
          >
            <i
              :class="submitting ? 'ti ti-loader-2 animate-spin' : 'ti ti-check'"
              class="text-base"
              aria-hidden="true"
            />
          </button>
        </div>
        <p
          v-if="errorMsg && !previewFile"
          class="max-w-[12rem] text-right text-xs text-error"
        >
          {{ errorMsg }}
        </p>
      </template>
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
