/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Base URL of the Rails API (REST, GraphQL, and ActionCable all derive from it). */
  readonly VITE_API_URL: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
