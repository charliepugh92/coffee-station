/** Internal type. DO NOT USE DIRECTLY. */
type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
/** Internal type. DO NOT USE DIRECTLY. */
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
import type * as Types from './schema-types';

export * from './schema-types';
export type MeQueryVariables = Exact<{ [key: string]: never; }>;


export type MeQuery = { me: { id: string, email: string, displayName: string, createdAt: string } | null };

export type CategoryFieldsFragment = { id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> };

export type OptionFieldsFragment = { id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null };

export type PresetFieldsFragment = { id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> };

export type StationDetailFragment = { id: string, name: string, slug: string | null, description: string | null, customizationCategories: Array<{ id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> }>, menuPresets: Array<{ id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> }> };

export type UserFieldsFragment = { id: string, email: string, displayName: string, createdAt: string };

export type DeleteCategoryMutationVariables = Exact<{
  id: string | number;
}>;


export type DeleteCategoryMutation = { deleteCategory: { success: boolean, errors: Array<string> } | null };

export type DeleteOptionMutationVariables = Exact<{
  id: string | number;
}>;


export type DeleteOptionMutation = { deleteOption: { success: boolean, errors: Array<string> } | null };

export type DeletePresetMutationVariables = Exact<{
  id: string | number;
}>;


export type DeletePresetMutation = { deletePreset: { success: boolean, errors: Array<string> } | null };

export type UploadOptionImageMutationVariables = Exact<{
  optionId: string | number;
  file: File;
}>;


export type UploadOptionImageMutation = { uploadOptionImage: { errors: Array<string>, option: { id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null } | null } | null };

export type UploadPresetImageMutationVariables = Exact<{
  presetId: string | number;
  file: File;
}>;


export type UploadPresetImageMutation = { uploadPresetImage: { errors: Array<string>, preset: { id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> } | null } | null };

export type UpsertCategoryMutationVariables = Exact<{
  stationId: string | number;
  id?: string | number | null | undefined;
  attrs: Types.CategoryAttrsInput;
}>;


export type UpsertCategoryMutation = { upsertCategory: { errors: Array<string>, category: { id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> } | null } | null };

export type UpsertOptionMutationVariables = Exact<{
  categoryId: string | number;
  id?: string | number | null | undefined;
  attrs: Types.OptionAttrsInput;
}>;


export type UpsertOptionMutation = { upsertOption: { errors: Array<string>, option: { id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null } | null } | null };

export type UpsertPresetMutationVariables = Exact<{
  stationId: string | number;
  id?: string | number | null | undefined;
  attrs: Types.PresetAttrsInput;
  optionIds?: Array<string | number> | string | number | null | undefined;
}>;


export type UpsertPresetMutation = { upsertPreset: { errors: Array<string>, preset: { id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> } | null } | null };

export type CreateStationMutationVariables = Exact<{
  attrs: Types.StationAttrsInput;
}>;


export type CreateStationMutation = { createStation: { errors: Array<string>, station: { id: string, name: string, slug: string | null, description: string | null } | null } | null };

export type DeleteStationMutationVariables = Exact<{
  id: string | number;
}>;


export type DeleteStationMutation = { deleteStation: { success: boolean, errors: Array<string> } | null };

export type MyStationsQueryVariables = Exact<{ [key: string]: never; }>;


export type MyStationsQuery = { myStations: Array<{ id: string, name: string, slug: string | null, description: string | null }> };

export type StationQueryVariables = Exact<{
  id: string | number;
}>;


export type StationQuery = { station: { id: string, name: string, slug: string | null, description: string | null, customizationCategories: Array<{ id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> }>, menuPresets: Array<{ id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> }> } | null };

export type ApiVersionQueryVariables = Exact<{ [key: string]: never; }>;


export type ApiVersionQuery = { apiVersion: string };
