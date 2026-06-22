<script setup lang="ts">
import { ref, watch } from 'vue'
import type { CategoryFieldsFragment } from '@/graphql/generated/types'

const props = defineProps<{
  category: CategoryFieldsFragment
  // When the category is locked by a preset it renders read-only.
  disabled?: boolean
  // Controlled selection (e.g. a preset pre-fill).
  modelValue?: string[]
}>()
const emit = defineEmits<{ change: [ids: string[]] }>()

const singleVal = ref('')
const multiVal = ref<string[]>([])

// Hydrate internal state from a controlled value (a preset pre-fill).
watch(
  () => props.modelValue,
  (v) => {
    if (!v) return
    if (props.category.selectionMode === 'SINGLE') singleVal.value = v[0] ?? ''
    else multiVal.value = [...v]
  },
  { immediate: true },
)

watch(singleVal, (v) => emit('change', v ? [v] : []))
watch(multiVal, (v) => emit('change', [...v]), { deep: true })
</script>

<template>
  <fieldset :class="{ 'opacity-60': disabled }">
    <legend class="text-sm font-semibold text-ink">
      {{ category.name }}<span
        v-if="category.required"
        class="text-error"
      >*</span>
      <span
        v-if="disabled"
        class="ml-1 text-xs font-normal text-muted"
      >· set by preset</span>
    </legend>
    <div class="mt-1 space-y-1">
      <label
        v-for="o in category.options"
        :key="o.id"
        class="flex items-center gap-2 text-sm text-ink"
      >
        <input
          v-if="category.selectionMode === 'SINGLE'"
          v-model="singleVal"
          type="radio"
          :value="o.id"
          :disabled="disabled"
          class="accent-roast"
        >
        <input
          v-else
          v-model="multiVal"
          type="checkbox"
          :value="o.id"
          :disabled="disabled"
          class="accent-roast"
        >
        {{ o.name }}
        <span
          v-if="o.surchargeCents"
          class="text-muted"
        >+{{ (o.surchargeCents / 100).toFixed(2) }}</span>
      </label>
    </div>
  </fieldset>
</template>
