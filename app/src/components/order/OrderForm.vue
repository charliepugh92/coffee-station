<script setup lang="ts">
import { ref, computed } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import CreateOrderDocument from '@/graphql/gql/orders/mutations/CreateOrder.graphql'
import type {
  CategoryFieldsFragment,
  PresetFieldsFragment,
  BaseFieldsFragment,
  CreateOrderMutation,
  CreateOrderMutationVariables,
} from '@/graphql/generated/types'
import CategorySelect from '@/components/order/CategorySelect.vue'

const props = defineProps<{
  sessionToken: string
  categories: CategoryFieldsFragment[]
  presets: PresetFieldsFragment[]
  bases: BaseFieldsFragment[]
  defaultName: string
}>()
const emit = defineEmits<{ placed: [token: string, orderId: string, guestName: string] }>()

const name = ref(props.defaultName)
const notes = ref('')
const presetId = ref('')
const baseId = ref('')
const perCategory = ref<Record<string, string[]>>({})
const error = ref<string | null>(null)
const submitting = ref(false)

const hasBases = computed(() => props.bases.length > 0)
const selectedBase = computed(() => props.bases.find((b) => b.id === baseId.value))

// Which categories the guest can fill: scoped to the chosen base's enabled set
// (or the whole menu when the station has no bases). With bases defined but none
// picked yet, show nothing until a base is chosen.
const visibleCategories = computed(() => {
  if (!hasBases.value) return props.categories
  if (!selectedBase.value) return []
  const allowed = new Set(selectedBase.value.categories.map((c) => c.id))
  return props.categories.filter((c) => allowed.has(c.id))
})

// Preset bundling: a category that the preset names is locked (pre-filled,
// read-only); categories the preset leaves untouched stay user choice.
const presetOptionsByCategory = computed(() => {
  const map: Record<string, string[]> = {}
  const preset = props.presets.find((p) => p.id === presetId.value)
  if (!preset) return map
  for (const opt of preset.options) {
    const cat = props.categories.find((c) => c.options.some((o) => o.id === opt.id))
    if (cat) (map[cat.id] ??= []).push(opt.id)
  }
  return map
})
const lockedCategoryIds = computed(() => new Set(Object.keys(presetOptionsByCategory.value)))

function isLocked(categoryId: string): boolean {
  return lockedCategoryIds.value.has(categoryId)
}

// Final selections: preset choices for locked categories, the guest's own
// choices for the rest — across only the currently visible categories.
const optionIds = computed(() => {
  const ids: string[] = []
  for (const c of visibleCategories.value) {
    if (isLocked(c.id)) ids.push(...(presetOptionsByCategory.value[c.id] ?? []))
    else ids.push(...(perCategory.value[c.id] ?? []))
  }
  return ids
})

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
          baseId: baseId.value || undefined,
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
      class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
    >
    <label
      v-if="hasBases"
      class="block text-sm"
    >
      <span class="text-ink">Choose your base<span class="text-error">*</span></span>
      <div class="relative mt-1">
        <select
          v-model="baseId"
          required
          class="w-full appearance-none rounded-md border-[0.5px] border-border bg-card px-3 py-2 pr-9 text-base text-ink focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
        >
          <option
            value=""
            disabled
          >
            — pick a base —
          </option>
          <option
            v-for="b in bases"
            :key="b.id"
            :value="b.id"
          >
            {{ b.name }}{{ b.surchargeCents ? ` (+${(b.surchargeCents / 100).toFixed(2)})` : '' }}
          </option>
        </select>
        <i
          class="ti ti-chevron-down pointer-events-none absolute top-1/2 right-3 -translate-y-1/2 text-muted"
          aria-hidden="true"
        />
      </div>
    </label>
    <label
      v-if="presets.length"
      class="block text-sm"
    >
      <span class="text-ink">Start from a preset (optional)</span>
      <div class="relative mt-1">
        <select
          v-model="presetId"
          class="w-full appearance-none rounded-md border-[0.5px] border-border bg-card px-3 py-2 pr-9 text-base text-ink focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
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
        <i
          class="ti ti-chevron-down pointer-events-none absolute top-1/2 right-3 -translate-y-1/2 text-muted"
          aria-hidden="true"
        />
      </div>
    </label>
    <CategorySelect
      v-for="c in visibleCategories"
      :key="c.id"
      :category="c"
      :disabled="isLocked(c.id)"
      :model-value="isLocked(c.id) ? presetOptionsByCategory[c.id] : undefined"
      @change="perCategory[c.id] = $event"
    />
    <input
      v-model="notes"
      placeholder="Anything else? (optional)"
      class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
    >
    <p
      v-if="error"
      class="text-sm text-error"
    >
      {{ error }}
    </p>
    <button
      type="submit"
      :disabled="submitting"
      class="w-full rounded-lg bg-roast px-4 py-2 text-base font-semibold text-surface hover:bg-roast/90 active:scale-[.99] disabled:opacity-45"
    >
      Place order
    </button>
  </form>
</template>
