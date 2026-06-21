<script setup lang="ts">
import { ref } from 'vue'
import { useQuery } from '@vue/apollo-composable'
import { useRouter } from 'vue-router'
import { apolloClient } from '@/utils/apolloClient'
import { useAuthStore } from '@/stores/auth'
import MyStationsDocument from '@/graphql/gql/stations/queries/MyStations.graphql'
import CreateStationDocument from '@/graphql/gql/stations/mutations/CreateStation.graphql'
import DeleteStationDocument from '@/graphql/gql/stations/mutations/DeleteStation.graphql'
import type {
  MyStationsQuery,
  CreateStationMutation,
  CreateStationMutationVariables,
  DeleteStationMutation,
  DeleteStationMutationVariables,
} from '@/graphql/generated/types'

const auth = useAuthStore()
const router = useRouter()
const { result, refetch } = useQuery<MyStationsQuery>(MyStationsDocument)

const name = ref('')
const slug = ref('')
const error = ref<string | null>(null)

async function createStation() {
  error.value = null
  const { data } = await apolloClient.mutate<CreateStationMutation, CreateStationMutationVariables>({
    mutation: CreateStationDocument,
    variables: { attrs: { name: name.value, slug: slug.value || undefined } },
  })
  const res = data?.createStation
  if (res?.errors.length) {
    error.value = res.errors.join(', ')
    return
  }
  name.value = ''
  slug.value = ''
  await refetch()
}

async function remove(id: string) {
  if (!window.confirm('Delete this station and its whole menu?')) return
  await apolloClient.mutate<DeleteStationMutation, DeleteStationMutationVariables>({
    mutation: DeleteStationDocument,
    variables: { id },
  })
  await refetch()
}

async function logout() {
  await auth.logout()
  router.push('/login')
}
</script>

<template>
  <section class="mx-auto max-w-2xl">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-semibold">
        {{ auth.user?.displayName }}'s stations
      </h2>
      <button
        class="text-sm text-stone-500 hover:text-stone-800"
        @click="logout"
      >
        Sign out
      </button>
    </div>

    <form
      class="mt-4 flex gap-2"
      @submit.prevent="createStation"
    >
      <input
        v-model="name"
        placeholder="New station name"
        required
        class="flex-1 rounded border border-stone-300 px-3 py-2"
      >
      <input
        v-model="slug"
        placeholder="slug (optional)"
        class="w-40 rounded border border-stone-300 px-3 py-2"
      >
      <button class="rounded bg-stone-800 px-4 py-2 text-white">
        Create
      </button>
    </form>
    <p
      v-if="error"
      class="mt-2 text-sm text-red-600"
    >
      {{ error }}
    </p>

    <ul class="mt-6 divide-y divide-stone-200 border-y border-stone-200">
      <li
        v-for="s in result?.myStations ?? []"
        :key="s.id"
        class="flex items-center justify-between py-3"
      >
        <RouterLink
          :to="`/stations/${s.id}`"
          class="font-medium text-stone-800 hover:underline"
        >
          {{ s.name }}
        </RouterLink>
        <button
          class="text-sm text-red-500 hover:text-red-700"
          @click="remove(s.id)"
        >
          Delete
        </button>
      </li>
    </ul>
  </section>
</template>
