<script setup lang="ts">
import { ref, computed } from 'vue'
import { useMenuMutations } from '@/composables/useMenuMutations'
import type { StationDetailFragment } from '@/graphql/generated/types'

const props = defineProps<{ station: StationDetailFragment }>()
const emit = defineEmits<{ changed: [] }>()
const menu = useMenuMutations()

const name = ref('')
const description = ref('')
const selected = ref<string[]>([])

const allOptions = computed(() =>
  props.station.customizationCategories.flatMap((c) =>
    c.options.map((o) => ({ id: o.id, label: `${c.name}: ${o.name}` })),
  ),
)

async function addPreset() {
  if (!name.value) return
  await menu.upsertPreset({
    stationId: props.station.id,
    attrs: { name: name.value, description: description.value || undefined },
    optionIds: selected.value,
  })
  name.value = ''
  description.value = ''
  selected.value = []
  emit('changed')
}

async function removePreset(id: string) {
  await menu.deletePreset({ id })
  emit('changed')
}

async function onImage(presetId: string, event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  await menu.uploadPresetImage({ presetId, file })
  emit('changed')
}
</script>

<template>
  <div>
    <h3 class="font-semibold">
      Curated presets
    </h3>
    <ul class="mt-2 space-y-2">
      <li
        v-for="p in station.menuPresets"
        :key="p.id"
        class="flex items-center gap-3 rounded border border-stone-200 p-2"
      >
        <img
          v-if="p.imageUrl"
          :src="p.imageUrl"
          alt=""
          class="h-10 w-10 rounded object-cover"
        >
        <div class="flex-1 text-sm">
          <div class="font-medium">
            {{ p.name }}
          </div>
          <div class="text-xs text-stone-400">
            {{ p.options.map((o) => o.name).join(', ') }}
          </div>
        </div>
        <label class="cursor-pointer text-xs text-stone-500 hover:text-stone-800">
          photo
          <input
            type="file"
            accept="image/*"
            class="hidden"
            @change="onImage(p.id, $event)"
          >
        </label>
        <button
          class="text-xs text-red-400 hover:text-red-600"
          @click="removePreset(p.id)"
        >
          ×
        </button>
      </li>
    </ul>
    <form
      class="mt-3 space-y-2 rounded border border-dashed border-stone-300 p-3"
      @submit.prevent="addPreset"
    >
      <input
        v-model="name"
        placeholder="Preset name"
        class="w-full rounded border border-stone-300 px-2 py-1 text-sm"
      >
      <input
        v-model="description"
        placeholder="Description (optional)"
        class="w-full rounded border border-stone-300 px-2 py-1 text-sm"
      >
      <div class="flex flex-wrap gap-2">
        <label
          v-for="opt in allOptions"
          :key="opt.id"
          class="flex items-center gap-1 text-xs"
        >
          <input
            v-model="selected"
            type="checkbox"
            :value="opt.id"
          >{{ opt.label }}
        </label>
      </div>
      <button class="rounded bg-stone-700 px-3 py-1 text-xs text-white">
        Add preset
      </button>
    </form>
  </div>
</template>
