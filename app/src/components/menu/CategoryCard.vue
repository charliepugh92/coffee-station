<script setup lang="ts">
import { ref } from 'vue'
import { useMenuMutations } from '@/composables/useMenuMutations'
import type { CategoryFieldsFragment } from '@/graphql/generated/types'

const props = defineProps<{ category: CategoryFieldsFragment }>()
const emit = defineEmits<{ changed: [] }>()
const menu = useMenuMutations()

const optionName = ref('')
const surcharge = ref('')

async function addOption() {
  if (!optionName.value) return
  await menu.upsertOption({
    categoryId: props.category.id,
    attrs: { name: optionName.value, surchargeCents: surcharge.value ? Number(surcharge.value) : undefined },
  })
  optionName.value = ''
  surcharge.value = ''
  emit('changed')
}

async function removeOption(id: string) {
  await menu.deleteOption({ id })
  emit('changed')
}

async function onImage(optionId: string, event: Event) {
  const file = (event.target as HTMLInputElement).files?.[0]
  if (!file) return
  await menu.uploadOptionImage({ optionId, file })
  emit('changed')
}

async function removeCategory() {
  await menu.deleteCategory({ id: props.category.id })
  emit('changed')
}
</script>

<template>
  <div class="rounded-lg border-[0.5px] border-border bg-card p-4">
    <div class="flex items-center justify-between">
      <div>
        <span class="font-semibold text-ink">{{ category.name }}</span>
        <span class="ml-2 text-xs text-muted">
          {{ category.selectionMode.toLowerCase() }}{{ category.required ? ' · required' : '' }}
        </span>
      </div>
      <button
        class="text-sm text-error hover:text-error/80"
        @click="removeCategory"
      >
        Remove
      </button>
    </div>
    <ul class="mt-3 space-y-1.5">
      <li
        v-for="o in category.options"
        :key="o.id"
        class="flex items-center gap-2 text-sm text-ink"
      >
        <img
          v-if="o.imageUrl"
          :src="o.imageUrl"
          alt=""
          class="h-6 w-6 rounded-sm object-cover"
        >
        <span class="flex-1">
          {{ o.name }}
          <span
            v-if="o.surchargeCents"
            class="text-muted"
          >+{{ (o.surchargeCents / 100).toFixed(2) }}</span>
        </span>
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
            @change="onImage(o.id, $event)"
          >
        </label>
        <button
          class="text-base text-error hover:text-error/80"
          aria-label="Remove option"
          @click="removeOption(o.id)"
        >
          <i
            class="ti ti-x"
            aria-hidden="true"
          />
        </button>
      </li>
    </ul>
    <form
      class="mt-3 flex flex-wrap gap-2"
      @submit.prevent="addOption"
    >
      <input
        v-model="optionName"
        placeholder="Add option"
        class="min-w-0 flex-1 rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <input
        v-model="surcharge"
        type="number"
        placeholder="¢"
        class="w-16 shrink-0 rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <button class="shrink-0 rounded-md bg-roast px-3 py-1.5 text-sm font-semibold text-surface hover:bg-roast/90 active:scale-[.99]">
        Add
      </button>
    </form>
  </div>
</template>
