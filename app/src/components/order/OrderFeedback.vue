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
  <div class="mt-4 border-t border-border pt-4">
    <p class="text-sm text-muted">
      How was it?
    </p>
    <div class="mt-1 flex justify-center gap-1">
      <button
        v-for="n in 5"
        :key="n"
        type="button"
        :aria-label="`Rate ${n} star${n === 1 ? '' : 's'}`"
        class="leading-none"
        @click="rate(n)"
      >
        <i
          class="ti ti-star text-[22px]"
          :class="n <= current ? 'text-caramel' : 'text-star-empty'"
        />
      </button>
    </div>
    <form
      class="mt-2 flex gap-2"
      @submit.prevent="submitComment"
    >
      <input
        v-model="comment"
        placeholder="Leave a comment"
        class="flex-1 rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm text-ink placeholder:text-muted focus:border-roast focus:ring-4 focus:ring-accent-tint focus:outline-none"
      >
      <button class="rounded-md border-[0.5px] border-border bg-card px-3 py-1.5 text-sm font-semibold text-ink hover:bg-sunken active:scale-[.99]">
        Send
      </button>
    </form>
    <p
      v-if="sent"
      class="mt-2 font-accent text-base text-success"
    >
      Thanks for the feedback!
    </p>
  </div>
</template>
