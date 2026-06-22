<script setup lang="ts">
defineProps<{
  label: string
  type?: string
  autocomplete?: string
  placeholder?: string
  required?: boolean
}>()
const model = defineModel<string>({ required: true })
</script>

<template>
  <label class="block text-sm">
    <span class="text-ink">{{ label }}</span>
    <input
      v-model="model"
      :type="type ?? 'text'"
      :required="required"
      :autocomplete="autocomplete"
      :placeholder="placeholder"
      class="mt-1 w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
    >
  </label>
</template>
