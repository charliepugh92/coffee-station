import { apolloClient } from '@/utils/apolloClient'
import UpsertCategoryDocument from '@/graphql/gql/menu/mutations/UpsertCategory.graphql'
import DeleteCategoryDocument from '@/graphql/gql/menu/mutations/DeleteCategory.graphql'
import UpsertOptionDocument from '@/graphql/gql/menu/mutations/UpsertOption.graphql'
import DeleteOptionDocument from '@/graphql/gql/menu/mutations/DeleteOption.graphql'
import UploadOptionImageDocument from '@/graphql/gql/menu/mutations/UploadOptionImage.graphql'
import UpsertPresetDocument from '@/graphql/gql/menu/mutations/UpsertPreset.graphql'
import UploadPresetImageDocument from '@/graphql/gql/menu/mutations/UploadPresetImage.graphql'
import DeletePresetDocument from '@/graphql/gql/menu/mutations/DeletePreset.graphql'
import UpsertBaseDocument from '@/graphql/gql/menu/mutations/UpsertBase.graphql'
import UploadBaseImageDocument from '@/graphql/gql/menu/mutations/UploadBaseImage.graphql'
import DeleteBaseDocument from '@/graphql/gql/menu/mutations/DeleteBase.graphql'
import type {
  UpsertCategoryMutation, UpsertCategoryMutationVariables,
  DeleteCategoryMutation, DeleteCategoryMutationVariables,
  UpsertOptionMutation, UpsertOptionMutationVariables,
  DeleteOptionMutation, DeleteOptionMutationVariables,
  UploadOptionImageMutation, UploadOptionImageMutationVariables,
  UpsertPresetMutation, UpsertPresetMutationVariables,
  UploadPresetImageMutation, UploadPresetImageMutationVariables,
  DeletePresetMutation, DeletePresetMutationVariables,
  UpsertBaseMutation, UpsertBaseMutationVariables,
  UploadBaseImageMutation, UploadBaseImageMutationVariables,
  DeleteBaseMutation, DeleteBaseMutationVariables,
} from '@/graphql/generated/types'

// Thin typed wrappers around the menu mutations. Each resolves once the server
// responds; callers refetch the Station query to refresh the menu.
export function useMenuMutations() {
  return {
    upsertCategory: (variables: UpsertCategoryMutationVariables) =>
      apolloClient.mutate<UpsertCategoryMutation, UpsertCategoryMutationVariables>({ mutation: UpsertCategoryDocument, variables }),
    deleteCategory: (variables: DeleteCategoryMutationVariables) =>
      apolloClient.mutate<DeleteCategoryMutation, DeleteCategoryMutationVariables>({ mutation: DeleteCategoryDocument, variables }),
    upsertOption: (variables: UpsertOptionMutationVariables) =>
      apolloClient.mutate<UpsertOptionMutation, UpsertOptionMutationVariables>({ mutation: UpsertOptionDocument, variables }),
    deleteOption: (variables: DeleteOptionMutationVariables) =>
      apolloClient.mutate<DeleteOptionMutation, DeleteOptionMutationVariables>({ mutation: DeleteOptionDocument, variables }),
    uploadOptionImage: (variables: UploadOptionImageMutationVariables) =>
      apolloClient.mutate<UploadOptionImageMutation, UploadOptionImageMutationVariables>({ mutation: UploadOptionImageDocument, variables }),
    upsertPreset: (variables: UpsertPresetMutationVariables) =>
      apolloClient.mutate<UpsertPresetMutation, UpsertPresetMutationVariables>({ mutation: UpsertPresetDocument, variables }),
    uploadPresetImage: (variables: UploadPresetImageMutationVariables) =>
      apolloClient.mutate<UploadPresetImageMutation, UploadPresetImageMutationVariables>({ mutation: UploadPresetImageDocument, variables }),
    deletePreset: (variables: DeletePresetMutationVariables) =>
      apolloClient.mutate<DeletePresetMutation, DeletePresetMutationVariables>({ mutation: DeletePresetDocument, variables }),
    upsertBase: (variables: UpsertBaseMutationVariables) =>
      apolloClient.mutate<UpsertBaseMutation, UpsertBaseMutationVariables>({ mutation: UpsertBaseDocument, variables }),
    uploadBaseImage: (variables: UploadBaseImageMutationVariables) =>
      apolloClient.mutate<UploadBaseImageMutation, UploadBaseImageMutationVariables>({ mutation: UploadBaseImageDocument, variables }),
    deleteBase: (variables: DeleteBaseMutationVariables) =>
      apolloClient.mutate<DeleteBaseMutation, DeleteBaseMutationVariables>({ mutation: DeleteBaseDocument, variables }),
  }
}
