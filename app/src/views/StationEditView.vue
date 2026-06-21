<script setup lang="ts">
import { ref } from 'vue'
import { useRoute } from 'vue-router'
import { useQuery } from '@vue/apollo-composable'
import { useMenuMutations } from '@/composables/useMenuMutations'
import StationDocument from '@/graphql/gql/stations/queries/Station.graphql'
import type { StationQuery, StationQueryVariables, SelectionModeEnum } from '@/graphql/generated/types'
import CategoryCard from '@/components/menu/CategoryCard.vue'
import PresetSection from '@/components/menu/PresetSection.vue'

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
      class="text-sm text-stone-500 hover:text-stone-800"
    >
      ← Stations
    </RouterLink>
    <h2 class="mt-2 text-lg font-semibold">
      {{ result.station.name }}
    </h2>

    <form
      class="mt-4 flex flex-wrap items-center gap-2"
      @submit.prevent="addCategory"
    >
      <input
        v-model="catName"
        placeholder="New category (e.g. Milk)"
        class="flex-1 rounded border border-stone-300 px-3 py-2"
      >
      <select
        v-model="catMode"
        class="rounded border border-stone-300 px-2 py-2 text-sm"
      >
        <option value="SINGLE">
          single
        </option>
        <option value="MULTI">
          multi
        </option>
      </select>
      <label class="flex items-center gap-1 text-sm text-stone-600">
        <input
          v-model="catRequired"
          type="checkbox"
        >required
      </label>
      <button class="rounded bg-stone-800 px-4 py-2 text-white">
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

    <PresetSection
      class="mt-8"
      :station="result.station"
      @changed="refetch"
    />
  </section>
</template>
