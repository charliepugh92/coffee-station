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

export type OrderFieldsFragment = { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> };

export type PresetFieldsFragment = { id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> };

export type StationDetailFragment = { id: string, name: string, slug: string | null, description: string | null, openSession: { id: string, status: Types.SessionStatusEnum, shareToken: string | null } | null, customizationCategories: Array<{ id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> }>, menuPresets: Array<{ id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> }> };

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

export type CompleteOrderMutationVariables = Exact<{
  orderId: string | number;
  file: File;
}>;


export type CompleteOrderMutation = { completeOrder: { errors: Array<string>, order: { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> } | null } | null };

export type CreateOrderMutationVariables = Exact<{
  sessionToken: string;
  attrs: Types.OrderInput;
}>;


export type CreateOrderMutation = { createOrder: { guestToken: string | null, errors: Array<string>, order: { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> } | null } | null };

export type UpdateOrderStatusMutationVariables = Exact<{
  orderId: string | number;
  status: Types.OrderStatusEnum;
}>;


export type UpdateOrderStatusMutation = { updateOrderStatus: { errors: Array<string>, order: { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> } | null } | null };

export type OrderByTokenQueryVariables = Exact<{
  token: string;
}>;


export type OrderByTokenQuery = { orderByToken: { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> } | null };

export type OrderAddedSubscriptionVariables = Exact<{
  sessionToken: string;
}>;


export type OrderAddedSubscription = { orderAdded: { order: { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> } } };

export type OrderUpdatedSubscriptionVariables = Exact<{
  orderToken: string;
}>;


export type OrderUpdatedSubscription = { orderUpdated: { order: { id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> } } };

export type CloseSessionMutationVariables = Exact<{
  id: string | number;
}>;


export type CloseSessionMutation = { closeSession: { errors: Array<string>, session: { id: string, status: Types.SessionStatusEnum } | null } | null };

export type OpenSessionMutationVariables = Exact<{
  stationId: string | number;
}>;


export type OpenSessionMutation = { openSession: { errors: Array<string>, session: { id: string, status: Types.SessionStatusEnum, shareToken: string | null } | null } | null };

export type SessionByTokenQueryVariables = Exact<{
  token: string;
}>;


export type SessionByTokenQuery = { sessionByToken: { id: string, status: Types.SessionStatusEnum, station: { name: string, description: string | null, customizationCategories: Array<{ id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> }>, menuPresets: Array<{ id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> }> } } | null };

export type SessionUpdatedSubscriptionVariables = Exact<{
  sessionToken: string;
}>;


export type SessionUpdatedSubscription = { sessionUpdated: { session: { id: string, status: Types.SessionStatusEnum } } };

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


export type StationQuery = { station: { id: string, name: string, slug: string | null, description: string | null, openSession: { id: string, status: Types.SessionStatusEnum, shareToken: string | null } | null, customizationCategories: Array<{ id: string, name: string, selectionMode: Types.SelectionModeEnum, required: boolean, position: number, options: Array<{ id: string, name: string, surchargeCents: number | null, position: number, imageUrl: string | null }> }>, menuPresets: Array<{ id: string, name: string, description: string | null, position: number, imageUrl: string | null, options: Array<{ id: string, name: string }> }> } | null };

export type StationBoardQueryVariables = Exact<{
  id: string | number;
}>;


export type StationBoardQuery = { station: { id: string, name: string, openSession: { id: string, status: Types.SessionStatusEnum, shareToken: string | null, orders: Array<{ id: string, guestName: string, status: Types.OrderStatusEnum, queuePosition: number | null, notes: string | null, completionPhotoUrl: string | null, createdAt: string, stationName: string, baseOption: { id: string, name: string } | null, menuPreset: { id: string, name: string } | null, selections: Array<{ id: string, name: string }> }> } | null } | null };

export type ApiVersionQueryVariables = Exact<{ [key: string]: never; }>;


export type ApiVersionQuery = { apiVersion: string };
