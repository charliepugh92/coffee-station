<script setup lang="ts">
import { ref, computed } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import CreateOrderDocument from '@/graphql/gql/orders/mutations/CreateOrder.graphql'
import type {
  CategoryFieldsFragment,
  PresetFieldsFragment,
  CreateOrderMutation,
  CreateOrderMutationVariables,
} from '@/graphql/generated/types'
import CategorySelect from '@/components/order/CategorySelect.vue'

const props = defineProps<{
  sessionToken: string
  categories: CategoryFieldsFragment[]
  presets: PresetFieldsFragment[]
  defaultName: string
}>()
const emit = defineEmits<{ placed: [token: string, orderId: string, guestName: string] }>()

const name = ref(props.defaultName)
const notes = ref('')
const presetId = ref('')
const perCategory = ref<Record<string, string[]>>({})
const error = ref<string | null>(null)
const submitting = ref(false)

const optionIds = computed(() => Object.values(perCategory.value).flat())

async function submit() {
  error.value = null
  submitting.value = true
  try {
    const { data } = await apolloClient.mutate<CreateOrderMutation, CreateOrderMutationVariables>({
      mutation: CreateOrderDocument,
      variables: {
        sessionToken: props.sessionToken,
        attrs: {
          guestName: name.value,
          optionIds: optionIds.value,
          menuPresetId: presetId.value || undefined,
          notes: notes.value || undefined,
        },
      },
    })
    const res = data?.createOrder
    if (!res?.order || !res.guestToken || res.errors.length) {
      error.value = res?.errors.join(', ') ?? 'Could not place your order'
      return
    }
    emit('placed', res.guestToken, res.order.id, name.value)
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <form
    class="space-y-4"
    @submit.prevent="submit"
  >
    <input
      v-model="name"
      placeholder="Your name"
      required
      class="w-full rounded border border-stone-300 px-3 py-2"
    >
    <label
      v-if="presets.length"
      class="block text-sm"
    >
      <span class="text-stone-700">Start from a preset (optional)</span>
      <select
        v-model="presetId"
        class="mt-1 w-full rounded border border-stone-300 px-2 py-2"
      >
        <option value="">
          — build my own —
        </option>
        <option
          v-for="p in presets"
          :key="p.id"
          :value="p.id"
        >
          {{ p.name }}
        </option>
      </select>
    </label>
    <CategorySelect
      v-for="c in categories"
      :key="c.id"
      :category="c"
      @change="perCategory[c.id] = $event"
    />
    <input
      v-model="notes"
      placeholder="Anything else? (optional)"
      class="w-full rounded border border-stone-300 px-3 py-2"
    >
    <p
      v-if="error"
      class="text-sm text-red-600"
    >
      {{ error }}
    </p>
    <button
      type="submit"
      :disabled="submitting"
      class="w-full rounded bg-stone-800 px-4 py-2 text-white disabled:opacity-50"
    >
      Place order
    </button>
  </form>
</template>
