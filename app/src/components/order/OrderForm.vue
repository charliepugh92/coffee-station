<script setup lang="ts">
import { ref, computed, watch } from 'vue'
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
import BaseSelect from '@/components/order/BaseSelect.vue'
import PresetSelect from '@/components/order/PresetSelect.vue'

const props = defineProps<{
  sessionToken: string
  categories: CategoryFieldsFragment[]
  presets: PresetFieldsFragment[]
  bases: BaseFieldsFragment[]
  defaultName: string
}>()
const emit = defineEmits<{ placed: [token: string, orderId: string, guestName: string] }>()

// Three-step flow: pick a base, pick a recipe (preset or "build it myself"),
// then fill in the customizations. Steps with nothing to choose are skipped.
type Step = 'base' | 'preset' | 'customize'

const name = ref(props.defaultName)
const notes = ref('')
const presetId = ref('')
const baseId = ref('')
const perCategory = ref<Record<string, string[]>>({})
const error = ref<string | null>(null)
const submitting = ref(false)

const hasBases = computed(() => props.bases.length > 0)
const selectedBase = computed(() => props.bases.find((b) => b.id === baseId.value))
const selectedPreset = computed(() => props.presets.find((p) => p.id === presetId.value))

// Which categories the guest can fill: scoped to the chosen base's enabled set
// (or the whole menu when the station has no bases). With bases defined but none
// picked yet, show nothing until a base is chosen.
const visibleCategories = computed(() => {
  if (!hasBases.value) return props.categories
  if (!selectedBase.value) return []
  const allowed = new Set(selectedBase.value.categories.map((c) => c.id))
  return props.categories.filter((c) => allowed.has(c.id))
})

// The categories the chosen base enables, or null when there's no base (whole
// menu allowed). A preset is only offered when every category it touches is
// available for the chosen base — e.g. a Cortado without Syrups can't take a
// syrup preset like "Raspberry Mocha".
const allowedCategoryIds = computed(() =>
  selectedBase.value ? new Set(selectedBase.value.categories.map((c) => c.id)) : null,
)

function presetCategoryIds(preset: PresetFieldsFragment): string[] {
  const ids = new Set<string>()
  for (const opt of preset.options) {
    const cat = props.categories.find((c) => c.options.some((o) => o.id === opt.id))
    if (cat) ids.add(cat.id)
  }
  return [...ids]
}

function isPresetCompatible(preset: PresetFieldsFragment): boolean {
  const allowed = allowedCategoryIds.value
  if (!allowed) return true
  return presetCategoryIds(preset).every((id) => allowed.has(id))
}

// Presets offered on the recipe step: only those valid for the chosen base.
const compatiblePresets = computed(() => props.presets.filter(isPresetCompatible))

// Switching base can strand a now-incompatible preset selection — drop it.
watch(baseId, () => {
  const preset = props.presets.find((p) => p.id === presetId.value)
  if (preset && !isPresetCompatible(preset)) presetId.value = ''
})

// --- Step navigation ---
// When there are no bases the flow opens on the recipe step (every preset is
// compatible without a base); with no presets either, straight to customize.
function initialStep(): Step {
  if (hasBases.value) return 'base'
  return compatiblePresets.value.length ? 'preset' : 'customize'
}
const step = ref<Step>(initialStep())

function chooseBase(id: string) {
  baseId.value = id
  // Skip the recipe step when the chosen base has no valid presets.
  step.value = compatiblePresets.value.length ? 'preset' : 'customize'
}

function choosePreset(id: string) {
  presetId.value = id // '' = build it myself
  step.value = 'customize'
}

function backFromPreset() {
  if (!hasBases.value) return
  baseId.value = ''
  step.value = 'base'
}

function backFromCustomize() {
  if (compatiblePresets.value.length) step.value = 'preset'
  else if (hasBases.value) {
    baseId.value = ''
    step.value = 'base'
  }
}

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
  <BaseSelect
    v-if="step === 'base'"
    :bases="bases"
    @select="chooseBase"
  />
  <div
    v-else-if="step === 'preset'"
    class="space-y-3"
  >
    <button
      v-if="hasBases"
      type="button"
      class="text-xs text-muted hover:text-ink"
      @click="backFromPreset"
    >
      ← Change base
    </button>
    <PresetSelect
      :presets="compatiblePresets"
      @select="choosePreset"
    />
  </div>
  <form
    v-else
    class="space-y-4"
    @submit.prevent="submit"
  >
    <div
      v-if="selectedBase || selectedPreset"
      class="flex items-center justify-between gap-2 rounded-md bg-sunken px-3 py-2"
    >
      <span class="min-w-0 text-sm font-semibold text-ink">
        {{ [selectedPreset?.name, selectedBase?.name].filter(Boolean).join(' · ') }}
        <span
          v-if="selectedBase?.surchargeCents"
          class="font-normal text-muted"
        >+{{ (selectedBase.surchargeCents / 100).toFixed(2) }}</span>
      </span>
      <button
        type="button"
        class="shrink-0 text-xs text-muted hover:text-ink"
        @click="backFromCustomize"
      >
        ← Back
      </button>
    </div>
    <input
      v-model="name"
      placeholder="Your name"
      required
      class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
    >
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
