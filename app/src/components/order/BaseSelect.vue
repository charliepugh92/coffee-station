<script setup lang="ts">
import type { BaseFieldsFragment } from '@/graphql/generated/types'

defineProps<{ bases: BaseFieldsFragment[] }>()
const emit = defineEmits<{ select: [id: string] }>()
</script>

<template>
  <div class="space-y-3">
    <p class="text-sm text-ink">
      Choose your drink
    </p>
    <div class="grid grid-cols-1 gap-3 sm:grid-cols-2">
      <button
        v-for="b in bases"
        :key="b.id"
        type="button"
        class="flex items-center gap-3 rounded-lg border-[0.5px] border-border bg-card p-3 text-left hover:border-roast hover:bg-accent-tint/40 active:scale-[.99]"
        @click="emit('select', b.id)"
      >
        <img
          v-if="b.imageUrl"
          :src="b.imageUrl"
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
          <span class="flex items-baseline gap-1">
            <span class="font-semibold text-ink">{{ b.name }}</span>
            <span
              v-if="b.surchargeCents"
              class="text-xs text-muted"
            >+{{ (b.surchargeCents / 100).toFixed(2) }}</span>
          </span>
          <span
            v-if="b.description"
            class="mt-0.5 block text-sm text-muted"
          >{{ b.description }}</span>
        </span>
      </button>
    </div>
  </div>
</template>
