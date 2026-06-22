<script setup lang="ts">
// Presentational confirm step for the "mark ready" photo: shows the captured
// image and defers the actual upload to the parent via the confirm event, so a
// failed save can keep this open (errorMsg) for retry.
defineProps<{ previewUrl: string; submitting: boolean; errorMsg: string }>()
const emit = defineEmits<{ confirm: []; retake: []; cancel: [] }>()
</script>

<template>
  <Teleport to="body">
    <div
      class="fixed inset-0 z-50 flex items-center justify-center bg-ink/60 p-4"
      @click.self="emit('cancel')"
    >
      <div class="w-full max-w-sm overflow-hidden rounded-lg border-[0.5px] border-border bg-card shadow-xl">
        <div class="flex items-center justify-between border-b-[0.5px] border-border px-4 py-3">
          <h3 class="text-base font-semibold text-ink">
            Confirm photo
          </h3>
          <button
            type="button"
            class="text-muted hover:text-ink disabled:opacity-50"
            :disabled="submitting"
            aria-label="Cancel"
            @click="emit('cancel')"
          >
            <i
              class="ti ti-x text-lg"
              aria-hidden="true"
            />
          </button>
        </div>

        <div class="bg-sunken p-3">
          <img
            :src="previewUrl"
            alt="Photo of the finished drink"
            class="mx-auto max-h-[60vh] w-full rounded-md object-contain"
          >
        </div>

        <p
          v-if="errorMsg"
          class="mx-4 mt-3 rounded-md bg-error-tint px-3 py-2 text-sm text-error"
        >
          {{ errorMsg }}
        </p>

        <div class="flex items-center justify-end gap-2 p-4">
          <button
            type="button"
            class="rounded-md border-[0.5px] border-border px-3 py-1.5 text-sm font-semibold text-ink hover:bg-sunken disabled:opacity-50"
            :disabled="submitting"
            @click="emit('retake')"
          >
            Retake
          </button>
          <button
            type="button"
            class="inline-flex items-center gap-1.5 rounded-md bg-ink px-3 py-1.5 text-sm font-semibold text-surface hover:bg-ink/90 disabled:opacity-60"
            :disabled="submitting"
            @click="emit('confirm')"
          >
            <i
              :class="submitting ? 'ti ti-loader-2 animate-spin' : 'ti ti-check'"
              class="text-base"
              aria-hidden="true"
            />
            {{ submitting ? 'Saving…' : 'Confirm — mark ready' }}
          </button>
        </div>
      </div>
    </div>
  </Teleport>
</template>
