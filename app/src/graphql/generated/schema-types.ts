export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  ISO8601DateTime: { input: string; output: string; }
};

/** Root mutation type */
export type Mutation = {
  __typename?: 'Mutation';
  /** No-op health-check mutation */
  ping: Scalars['Boolean']['output'];
};

/** Root query type */
export type Query = UserQueries & {
  __typename?: 'Query';
  /** The running API version string */
  apiVersion: Scalars['String']['output'];
  /** The currently authenticated host, or null if unauthenticated */
  me?: Maybe<User>;
};

/** Realtime events delivered over ActionCable */
export type Subscription = {
  __typename?: 'Subscription';
  /** Placeholder keepalive field */
  heartbeat: Scalars['Boolean']['output'];
};

/** A primary user — a coffee-station host */
export type User = {
  __typename?: 'User';
  /** When the account was created */
  createdAt: Scalars['ISO8601DateTime']['output'];
  /** Name shown to guests on the host's stations */
  displayName: Scalars['String']['output'];
  /** Login email */
  email: Scalars['String']['output'];
  /** Unique user ID */
  id: Scalars['ID']['output'];
};

/** Current-user queries */
export type UserQueries = {
  /** The currently authenticated host, or null if unauthenticated */
  me?: Maybe<User>;
};
