<script setup lang="ts">
import { ref } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import RateOrderDocument from '@/graphql/gql/feedback/mutations/RateOrder.graphql'
import AddCommentDocument from '@/graphql/gql/feedback/mutations/AddComment.graphql'
import type {
  RateOrderMutation,
  RateOrderMutationVariables,
  AddCommentMutation,
  AddCommentMutationVariables,
} from '@/graphql/generated/types'

const props = defineProps<{ token: string; stars?: number | null }>()
const emit = defineEmits<{ changed: [] }>()

const current = ref(props.stars ?? 0)
const comment = ref('')
const sent = ref(false)

async function rate(n: number) {
  current.value = n
  await apolloClient.mutate<RateOrderMutation, RateOrderMutationVariables>({
    mutation: RateOrderDocument,
    variables: { orderToken: props.token, stars: n },
  })
  emit('changed')
}

async function submitComment() {
  if (!comment.value.trim()) return
  await apolloClient.mutate<AddCommentMutation, AddCommentMutationVariables>({
    mutation: AddCommentDocument,
    variables: { orderToken: props.token, body: comment.value },
  })
  comment.value = ''
  sent.value = true
  emit('changed')
}
</script>

<template>
  <div class="mt-4 border-t border-stone-100 pt-4">
    <p class="text-sm text-stone-500">
      How was it?
    </p>
    <div class="mt-1 flex justify-center gap-1">
      <button
        v-for="n in 5"
        :key="n"
        type="button"
        class="text-2xl"
        :class="n <= current ? 'text-amber-400' : 'text-stone-300'"
        @click="rate(n)"
      >
        ★
      </button>
    </div>
    <form
      class="mt-2 flex gap-2"
      @submit.prevent="submitComment"
    >
      <input
        v-model="comment"
        placeholder="Leave a comment"
        class="flex-1 rounded border border-stone-300 px-2 py-1 text-sm"
      >
      <button class="rounded bg-stone-700 px-3 py-1 text-xs text-white">
        Send
      </button>
    </form>
    <p
      v-if="sent"
      class="mt-1 text-xs text-green-600"
    >
      Thanks for the feedback!
    </p>
  </div>
</template>
