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
    <h3 class="font-display text-xl leading-tight">
      Curated presets
    </h3>
    <ul class="mt-3 space-y-2">
      <li
        v-for="p in station.menuPresets"
        :key="p.id"
        class="flex items-center gap-3 rounded-lg border-[0.5px] border-border bg-card p-3"
      >
        <img
          v-if="p.imageUrl"
          :src="p.imageUrl"
          alt=""
          class="h-10 w-10 rounded-md object-cover"
        >
        <div class="flex-1 text-sm text-ink">
          <div class="font-semibold">
            {{ p.name }}
          </div>
          <div class="text-xs text-muted">
            {{ p.options.map((o) => o.name).join(', ') }}
          </div>
        </div>
        <label
          class="flex cursor-pointer items-center text-muted hover:text-ink"
          aria-label="Add photo"
        >
          <i
            class="ti ti-camera text-base"
            aria-hidden="true"
          />
          <input
            type="file"
            accept="image/*"
            class="hidden"
            @change="onImage(p.id, $event)"
          >
        </label>
        <button
          class="text-base text-error hover:text-error/80"
          aria-label="Remove preset"
          @click="removePreset(p.id)"
        >
          <i
            class="ti ti-x"
            aria-hidden="true"
          />
        </button>
      </li>
    </ul>
    <form
      class="mt-3 space-y-2 rounded-lg border border-dashed border-border p-4"
      @submit.prevent="addPreset"
    >
      <input
        v-model="name"
        placeholder="Preset name"
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <input
        v-model="description"
        placeholder="Description (optional)"
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <div class="flex flex-wrap gap-x-3 gap-y-2">
        <label
          v-for="opt in allOptions"
          :key="opt.id"
          class="flex items-center gap-1.5 text-xs text-ink"
        >
          <input
            v-model="selected"
            type="checkbox"
            :value="opt.id"
            class="accent-roast"
          >{{ opt.label }}
        </label>
      </div>
      <button class="rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]">
        Add preset
      </button>
    </form>
  </div>
</template>
