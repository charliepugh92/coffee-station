<script setup lang="ts">
import { ref } from 'vue'
import { apolloClient } from '@/utils/apolloClient'
import { useAuthStore } from '@/stores/auth'
import UpdateAccountDocument from '@/graphql/gql/auth/mutations/UpdateAccount.graphql'
import type { UpdateAccountMutation, UpdateAccountMutationVariables } from '@/graphql/generated/types'
import LabeledInput from '@/components/account/LabeledInput.vue'
import FormFeedback from '@/components/account/FormFeedback.vue'
import SignedInDevices from '@/components/account/SignedInDevices.vue'

const auth = useAuthStore()

// Profile (email + display name) form.
const email = ref(auth.user?.email ?? '')
const displayName = ref(auth.user?.displayName ?? '')
const profilePassword = ref('')
const profileError = ref<string | null>(null)
const profileSaved = ref(false)
const savingProfile = ref(false)

// Password-change form.
const newPassword = ref('')
const newPasswordConfirm = ref('')
const passwordCurrent = ref('')
const passwordError = ref<string | null>(null)
const passwordSaved = ref(false)
const savingPassword = ref(false)

const buttonClass =
  'rounded-lg bg-roast px-4 py-2 text-base font-semibold text-surface hover:bg-roast/90 active:scale-[.99] disabled:opacity-45'

async function saveProfile() {
  profileError.value = null
  profileSaved.value = false
  savingProfile.value = true
  try {
    const { data } = await apolloClient.mutate<UpdateAccountMutation, UpdateAccountMutationVariables>({
      mutation: UpdateAccountDocument,
      variables: { email: email.value, displayName: displayName.value, currentPassword: profilePassword.value },
    })
    const res = data?.updateAccount
    if (!res?.user || res.errors.length) {
      profileError.value = res?.errors.join(', ') ?? 'Could not update your profile'
      return
    }
    auth.user = res.user
    profilePassword.value = ''
    profileSaved.value = true
  } finally {
    savingProfile.value = false
  }
}

async function savePassword() {
  passwordError.value = null
  passwordSaved.value = false
  if (newPassword.value !== newPasswordConfirm.value) {
    passwordError.value = "New passwords don't match"
    return
  }
  savingPassword.value = true
  try {
    const { data } = await apolloClient.mutate<UpdateAccountMutation, UpdateAccountMutationVariables>({
      mutation: UpdateAccountDocument,
      variables: { password: newPassword.value, currentPassword: passwordCurrent.value },
    })
    const res = data?.updateAccount
    if (!res?.user || res.errors.length) {
      passwordError.value = res?.errors.join(', ') ?? 'Could not update your password'
      return
    }
    newPassword.value = ''
    newPasswordConfirm.value = ''
    passwordCurrent.value = ''
    passwordSaved.value = true
  } finally {
    savingPassword.value = false
  }
}
</script>

<template>
  <section class="mx-auto max-w-lg">
    <RouterLink
      to="/dashboard"
      class="inline-flex items-center gap-1 text-sm text-muted hover:text-ink"
    >
      <i
        class="ti ti-arrow-left"
        aria-hidden="true"
      />
      Dashboard
    </RouterLink>
    <h2 class="mt-2 font-display text-2xl">
      Account settings
    </h2>

    <form
      class="mt-6 space-y-3 rounded-lg border-[0.5px] border-border bg-card p-4"
      @submit.prevent="saveProfile"
    >
      <h3 class="font-display text-lg leading-tight">
        Profile
      </h3>
      <LabeledInput
        v-model="displayName"
        label="Display name"
        autocomplete="name"
      />
      <LabeledInput
        v-model="email"
        label="Email"
        type="email"
        autocomplete="email"
      />
      <LabeledInput
        v-model="profilePassword"
        label="Current password"
        type="password"
        autocomplete="current-password"
        placeholder="Confirm with your current password"
        required
      />
      <FormFeedback
        :error="profileError"
        :success="profileSaved ? 'Profile updated.' : null"
      />
      <button
        type="submit"
        :disabled="savingProfile"
        :class="buttonClass"
      >
        Save profile
      </button>
    </form>

    <form
      class="mt-4 space-y-3 rounded-lg border-[0.5px] border-border bg-card p-4"
      @submit.prevent="savePassword"
    >
      <h3 class="font-display text-lg leading-tight">
        Change password
      </h3>
      <LabeledInput
        v-model="newPassword"
        label="New password"
        type="password"
        autocomplete="new-password"
        required
      />
      <LabeledInput
        v-model="newPasswordConfirm"
        label="Confirm new password"
        type="password"
        autocomplete="new-password"
        required
      />
      <LabeledInput
        v-model="passwordCurrent"
        label="Current password"
        type="password"
        autocomplete="current-password"
        required
      />
      <FormFeedback
        :error="passwordError"
        :success="passwordSaved ? 'Password updated.' : null"
      />
      <button
        type="submit"
        :disabled="savingPassword"
        :class="buttonClass"
      >
        Change password
      </button>
    </form>

    <SignedInDevices />
  </section>
</template>
