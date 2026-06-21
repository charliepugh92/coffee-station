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
  <div class="rounded border border-stone-200 p-3">
    <div class="flex items-center justify-between">
      <div>
        <span class="font-medium">{{ category.name }}</span>
        <span class="ml-2 text-xs text-stone-400">
          {{ category.selectionMode.toLowerCase() }}{{ category.required ? ' · required' : '' }}
        </span>
      </div>
      <button
        class="text-xs text-red-500 hover:text-red-700"
        @click="removeCategory"
      >
        Remove
      </button>
    </div>
    <ul class="mt-2 space-y-1">
      <li
        v-for="o in category.options"
        :key="o.id"
        class="flex items-center gap-2 text-sm"
      >
        <img
          v-if="o.imageUrl"
          :src="o.imageUrl"
          alt=""
          class="h-6 w-6 rounded object-cover"
        >
        <span class="flex-1">
          {{ o.name }}
          <span
            v-if="o.surchargeCents"
            class="text-stone-400"
          >+{{ (o.surchargeCents / 100).toFixed(2) }}</span>
        </span>
        <label class="cursor-pointer text-xs text-stone-500 hover:text-stone-800">
          photo
          <input
            type="file"
            accept="image/*"
            class="hidden"
            @change="onImage(o.id, $event)"
          >
        </label>
        <button
          class="text-xs text-red-400 hover:text-red-600"
          @click="removeOption(o.id)"
        >
          ×
        </button>
      </li>
    </ul>
    <form
      class="mt-2 flex gap-2"
      @submit.prevent="addOption"
    >
      <input
        v-model="optionName"
        placeholder="Add option"
        class="flex-1 rounded border border-stone-300 px-2 py-1 text-sm"
      >
      <input
        v-model="surcharge"
        type="number"
        placeholder="¢"
        class="w-16 rounded border border-stone-300 px-2 py-1 text-sm"
      >
      <button class="rounded bg-stone-700 px-2 py-1 text-xs text-white">
        Add
      </button>
    </form>
  </div>
</template>
