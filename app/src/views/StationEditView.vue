<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery } from '@vue/apollo-composable'
import { useMenuMutations } from '@/composables/useMenuMutations'
import StationDocument from '@/graphql/gql/stations/queries/Station.graphql'
import type { StationQuery, StationQueryVariables, SelectionModeEnum } from '@/graphql/generated/types'
import CategoryCard from '@/components/menu/CategoryCard.vue'
import PresetSection from '@/components/menu/PresetSection.vue'
import BaseSection from '@/components/menu/BaseSection.vue'
import SessionControl from '@/components/menu/SessionControl.vue'

const route = useRoute()
const id = route.params.id as string
const { result, refetch } = useQuery<StationQuery, StationQueryVariables>(StationDocument, { id })
const menu = useMenuMutations()

const catName = ref('')
const catMode = ref<SelectionModeEnum>('SINGLE')
const catRequired = ref(false)

async function addCategory() {
  if (!catName.value) return
  await menu.upsertCategory({
    stationId: id,
    attrs: { name: catName.value, selectionMode: catMode.value, required: catRequired.value },
  })
  catName.value = ''
  catRequired.value = false
  refetch()
}
</script>

<template>
  <section
    v-if="result?.station"
    class="mx-auto max-w-2xl"
  >
    <RouterLink
      to="/dashboard"
      class="inline-flex items-center gap-1 text-sm text-muted hover:text-ink"
    >
      <i
        class="ti ti-arrow-left"
        aria-hidden="true"
      />
      Stations
    </RouterLink>
    <div class="mt-2 flex items-center justify-between">
      <h2 class="font-display text-2xl">
        {{ result.station.name }}
      </h2>
      <RouterLink
        :to="`/stations/${id}/board`"
        class="inline-flex items-center gap-1 text-sm text-muted hover:text-ink"
      >
        Order board
        <i
          class="ti ti-arrow-right"
          aria-hidden="true"
        />
      </RouterLink>
    </div>

    <SessionControl
      class="mt-3"
      :station="result.station"
      @changed="refetch"
    />

    <form
      class="mt-4 flex flex-col gap-2 sm:flex-row sm:flex-wrap sm:items-center"
      @submit.prevent="addCategory"
    >
      <input
        v-model="catName"
        placeholder="New category (e.g. Milk)"
        class="w-full rounded-md border-[0.5px] border-border bg-card px-3 py-2 text-base text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none sm:flex-1"
      >
      <div class="relative w-full sm:w-auto">
        <select
          v-model="catMode"
          class="w-full appearance-none rounded-md border-[0.5px] border-border bg-card px-3 py-2 pr-9 text-sm text-ink focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none sm:w-auto"
        >
          <option value="SINGLE">
            single
          </option>
          <option value="MULTI">
            multi
          </option>
        </select>
        <i
          class="ti ti-chevron-down pointer-events-none absolute top-1/2 right-3 -translate-y-1/2 text-muted"
          aria-hidden="true"
        />
      </div>
      <label class="flex items-center gap-1.5 text-sm text-ink">
        <input
          v-model="catRequired"
          type="checkbox"
          class="accent-roast"
        >required
      </label>
      <button class="w-full rounded-lg bg-roast px-4 py-2 text-base font-semibold text-surface hover:bg-roast/90 active:scale-[.99] sm:w-auto">
        Add
      </button>
    </form>

    <div class="mt-4 space-y-3">
      <CategoryCard
        v-for="c in result.station.customizationCategories"
        :key="c.id"
        :category="c"
        @changed="refetch"
      />
    </div>

    <BaseSection
      class="mt-8"
      :station="result.station"
      @changed="refetch"
    />

    <PresetSection
      class="mt-8"
      :station="result.station"
      @changed="refetch"
    />
  </section>
</template>
