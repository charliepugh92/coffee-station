<script setup lang="ts">
import { useQuery } from '@vue/apollo-composable'
import ApiVersionDocument from '@/graphql/gql/system/queries/ApiVersion.graphql'
import type { ApiVersionQuery } from '@/graphql/generated/types'

const { result } = useQuery<ApiVersionQuery>(ApiVersionDocument)
</script>

<template>
  <section class="max-w-2xl">
    <p class="font-accent text-2xl text-caramel">
      small-batch · hometown · your pour
    </p>
    <p class="mt-3 text-base text-muted">
      A small-batch, hometown coffee station. Open the bar, share a link, and let
      the neighborhood order their pour.
    </p>
    <p class="mt-6 text-xs uppercase tracking-wide text-muted">
      API v{{ result?.apiVersion ?? '…' }}
    </p>
  </section>
</template>
