<script setup lang="ts">
import { ref, computed } from 'vue'
import { useMenuMutations } from '@/composables/useMenuMutations'
import type { StationDetailFragment } from '@/graphql/generated/types'
import BaseRow from '@/components/menu/BaseRow.vue'
import type { BaseEdit } from '@/components/menu/baseForm'
import { downscaleImage } from '@/utils/downscaleImage'

const props = defineProps<{ station: StationDetailFragment }>()
const emit = defineEmits<{ changed: [] }>()
const menu = useMenuMutations()

const name = ref('')
const description = ref('')
const surcharge = ref('')
const selectedCategories = ref<string[]>([])

const categories = computed(() => props.station.customizationCategories)

function categoryNames(ids: string[]): string {
  const names = ids
    .map((id) => categories.value.find((c) => c.id === id)?.name)
    .filter(Boolean)
  return names.length ? names.join(', ') : 'no extra options'
}

async function addBase() {
  if (!name.value) return
  await menu.upsertBase({
    stationId: props.station.id,
    attrs: {
      name: name.value,
      description: description.value || undefined,
      surchargeCents: surcharge.value ? Number(surcharge.value) : undefined,
    },
    categoryIds: selectedCategories.value,
  })
  name.value = ''
  description.value = ''
  surcharge.value = ''
  selectedCategories.value = []
  emit('changed')
}

async function saveBase(id: string, attrs: BaseEdit, categoryIds: string[]) {
  await menu.upsertBase({ stationId: props.station.id, id, attrs, categoryIds })
  emit('changed')
}

async function removeBase(id: string) {
  await menu.deleteBase({ id })
  emit('changed')
}

async function onImage(baseId: string, event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  const processed = await downscaleImage(file)
  await menu.uploadBaseImage({ baseId, file: processed })
  emit('changed')
}
</script>

<template>
  <div>
    <h3 class="font-display text-xl leading-tight">
      Base drinks
    </h3>
    <p class="mt-1 text-xs text-muted">
      A base (e.g. Latte, Cappuccino, Espresso) sets which categories a guest can
      customize. Leave all categories unchecked for a base with no add-ons.
    </p>
    <ul class="mt-3 space-y-2">
      <BaseRow
        v-for="b in station.bases"
        :key="b.id"
        :base="b"
        :categories="categories"
        :category-label="categoryNames(b.categories.map((c) => c.id))"
        @image="onImage(b.id, $event)"
        @remove="removeBase(b.id)"
        @save="(attrs, ids) => saveBase(b.id, attrs, ids)"
      />
    </ul>
    <form
      class="mt-3 space-y-2 rounded-lg border border-dashed border-border p-4"
      @submit.prevent="addBase"
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
      <button class="w-full rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99] sm:w-auto">
        Add base
      </button>
    </form>
  </div>
</template>
