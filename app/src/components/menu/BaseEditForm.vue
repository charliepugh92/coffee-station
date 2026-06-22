<script setup lang="ts">
import { ref } from 'vue'
import type { BaseFieldsFragment, CategoryFieldsFragment } from '@/graphql/generated/types'
import type { BaseEdit } from './baseForm'

// Mounted fresh each time editing starts, so refs seed straight from the base.
const props = defineProps<{ base: BaseFieldsFragment; categories: CategoryFieldsFragment[] }>()
const emit = defineEmits<{ save: [attrs: BaseEdit, categoryIds: string[]]; cancel: [] }>()

const name = ref(props.base.name)
const description = ref(props.base.description ?? '')
const surcharge = ref(props.base.surchargeCents != null ? String(props.base.surchargeCents) : '')
const selectedCategories = ref<string[]>(props.base.categories.map((c) => c.id))

function save() {
  if (!name.value) return
  emit(
    'save',
    {
      name: name.value,
      description: description.value || undefined,
      surchargeCents: surcharge.value ? Number(surcharge.value) : undefined,
    },
    selectedCategories.value,
  )
}
</script>

<template>
  <form
    class="space-y-2"
    @submit.prevent="save"
  >
    <div class="flex flex-col gap-2 sm:flex-row">
      <input
        v-model="name"
        placeholder="Base name (e.g. Latte)"
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none sm:flex-1"
      >
      <input
        v-model="surcharge"
        type="number"
        placeholder="¢"
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none sm:w-16"
      >
    </div>
    <input
      v-model="description"
      placeholder="Description (optional)"
      class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
    >
    <div
      v-if="categories.length"
      class="flex flex-wrap gap-x-3 gap-y-2"
    >
      <label
        v-for="c in categories"
        :key="c.id"
        class="flex items-center gap-1.5 text-xs text-ink"
      >
        <input
          v-model="selectedCategories"
          type="checkbox"
          :value="c.id"
          class="accent-roast"
        >{{ c.name }}
      </label>
    </div>
    <div class="flex gap-2">
      <button class="rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]">
        Save
      </button>
      <button
        type="button"
        class="rounded-md px-3 py-1.5 text-sm text-muted hover:text-ink"
        @click="emit('cancel')"
      >
        Cancel
      </button>
    </div>
  </form>
</template>
