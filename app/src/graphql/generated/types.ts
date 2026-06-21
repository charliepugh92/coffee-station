/** Internal type. DO NOT USE DIRECTLY. */
type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
/** Internal type. DO NOT USE DIRECTLY. */
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
export * from './schema-types';
export type MeQueryVariables = Exact<{ [key: string]: never; }>;


export type MeQuery = { me: { id: string, email: string, displayName: string, createdAt: string } | null };

export type UserFieldsFragment = { id: string, email: string, displayName: string, createdAt: string };

export type ApiVersionQueryVariables = Exact<{ [key: string]: never; }>;


export type ApiVersionQuery = { apiVersion: string };
