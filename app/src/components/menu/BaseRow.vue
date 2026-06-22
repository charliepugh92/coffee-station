<script setup lang="ts">
import { ref } from 'vue'
import type { BaseFieldsFragment, CategoryFieldsFragment } from '@/graphql/generated/types'
import type { BaseEdit } from './baseForm'
import BaseEditForm from './BaseEditForm.vue'

defineProps<{
  base: BaseFieldsFragment
  categoryLabel: string
  categories: CategoryFieldsFragment[]
}>()
const emit = defineEmits<{
  image: [event: Event]
  remove: []
  save: [attrs: BaseEdit, categoryIds: string[]]
}>()

const editing = ref(false)

function onSave(attrs: BaseEdit, categoryIds: string[]) {
  emit('save', attrs, categoryIds)
  editing.value = false
}
</script>

<template>
  <li class="rounded-lg border-[0.5px] border-border bg-card p-3">
    <div
      v-if="!editing"
      class="flex items-center gap-3"
    >
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
        <div
          v-if="base.description"
          class="text-xs text-muted"
        >
          {{ base.description }}
        </div>
        <div class="text-xs text-muted">
          {{ categoryLabel }}
        </div>
      </div>
      <button
        class="text-muted hover:text-ink"
        aria-label="Edit base"
        @click="editing = true"
      >
        <i
          class="ti ti-pencil text-base"
          aria-hidden="true"
        />
      </button>
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
    </div>

    <BaseEditForm
      v-else
      :base="base"
      :categories="categories"
      @save="onSave"
      @cancel="editing = false"
    />
  </li>
</template>
