<script setup lang="ts">
import type { PresetFieldsFragment } from '@/graphql/generated/types'

// Presets are pre-filtered to the ones compatible with the chosen base.
defineProps<{ presets: PresetFieldsFragment[] }>()
// '' means "build it myself" (no preset).
const emit = defineEmits<{ select: [id: string] }>()
</script>

<template>
  <div class="space-y-3">
    <p class="text-sm text-ink">
      Pick a recipe
    </p>
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
      <button
        type="button"
        class="flex items-center gap-3 rounded-lg border-[0.5px] border-border bg-card p-3 text-left hover:border-roast hover:bg-accent-tint/40 active:scale-[.99]"
        @click="emit('select', '')"
      >
        <span class="flex h-14 w-14 shrink-0 items-center justify-center rounded-md bg-sunken text-muted">
          <i
            class="ti ti-wand text-xl"
            aria-hidden="true"
          />
        </span>
        <span class="min-w-0">
          <span class="block font-semibold text-ink">Build it myself</span>
          <span class="mt-0.5 block text-sm text-muted">Start from scratch and choose every option.</span>
        </span>
      </button>
      <button
        v-for="p in presets"
        :key="p.id"
        type="button"
        class="flex items-center gap-3 rounded-lg border-[0.5px] border-border bg-card p-3 text-left hover:border-roast hover:bg-accent-tint/40 active:scale-[.99]"
        @click="emit('select', p.id)"
      >
        <img
          v-if="p.imageUrl"
          :src="p.imageUrl"
          alt=""
          class="h-14 w-14 shrink-0 rounded-md object-cover"
        >
        <span
          v-else
          class="flex h-14 w-14 shrink-0 items-center justify-center rounded-md bg-sunken text-muted"
        >
          <i
            class="ti ti-coffee text-xl"
            aria-hidden="true"
          />
        </span>
        <span class="min-w-0">
          <span class="block font-semibold text-ink">{{ p.name }}</span>
          <span
            v-if="p.description"
            class="mt-0.5 block text-sm text-muted"
          >{{ p.description }}</span>
        </span>
      </button>
    </div>
  </div>
</template>
