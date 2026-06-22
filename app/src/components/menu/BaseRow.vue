<script setup lang="ts">
import type { BaseFieldsFragment } from '@/graphql/generated/types'

defineProps<{ base: BaseFieldsFragment; categoryLabel: string }>()
const emit = defineEmits<{ image: [event: Event]; remove: [] }>()
</script>

<template>
  <li class="flex items-center gap-3 rounded-lg border-[0.5px] border-border bg-card p-3">
    <img
      v-if="base.imageUrl"
      :src="base.imageUrl"
      alt=""
      class="h-10 w-10 rounded-md object-cover"
    >
    <div class="flex-1 text-sm text-ink">
      <div class="font-semibold">
        {{ base.name }}
        <span
          v-if="base.surchargeCents"
          class="text-muted"
        >+{{ (base.surchargeCents / 100).toFixed(2) }}</span>
      </div>
      <div class="text-xs text-muted">
        {{ categoryLabel }}
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
        @change="emit('image', $event)"
      >
    </label>
    <button
      class="text-base text-error hover:text-error/80"
      aria-label="Remove base"
      @click="emit('remove')"
    >
      <i
        class="ti ti-x"
        aria-hidden="true"
      />
    </button>
  </li>
</template>
