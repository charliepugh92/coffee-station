<script setup lang="ts">
import { ref, watch } from 'vue'
import type { CategoryFieldsFragment } from '@/graphql/generated/types'

defineProps<{ category: CategoryFieldsFragment }>()
const emit = defineEmits<{ change: [ids: string[]] }>()

const singleVal = ref('')
const multiVal = ref<string[]>([])

watch(singleVal, (v) => emit('change', v ? [v] : []))
watch(multiVal, (v) => emit('change', [...v]), { deep: true })
</script>

<template>
  <fieldset>
    <legend class="text-sm font-medium text-stone-700">
      {{ category.name }}<span
        v-if="category.required"
        class="text-red-500"
      >*</span>
    </legend>
    <div class="mt-1 space-y-1">
      <label
        v-for="o in category.options"
        :key="o.id"
        class="flex items-center gap-2 text-sm text-stone-600"
      >
        <input
          v-if="category.selectionMode === 'SINGLE'"
          v-model="singleVal"
          type="radio"
          :value="o.id"
        >
        <input
          v-else
          v-model="multiVal"
          type="checkbox"
          :value="o.id"
        >
        {{ o.name }}
        <span
          v-if="o.surchargeCents"
          class="text-stone-400"
        >+{{ (o.surchargeCents / 100).toFixed(2) }}</span>
      </label>
    </div>
  </fieldset>
</template>
