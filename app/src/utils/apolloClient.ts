import { ApolloClient, InMemoryCache, split } from '@apollo/client/core'
import { getMainDefinition } from '@apollo/client/utilities'
import { createUploadLink } from 'apollo-upload-client'
import { createConsumer } from '@rails/actioncable'
import ActionCableLink from 'graphql-ruby-client/subscriptions/ActionCableLink'
import { getToken } from '@/utils/tokenStorage'
import fragmentTypes from '@/graphql/generated/fragment-types.json'

const API_URL = import.meta.env.VITE_API_URL ?? 'http://localhost:3000'
const WS_URL = API_URL.replace(/^http/, 'ws')

function getAuthHeaders(): Record<string, string> {
  const token = getToken()
  return token ? { Authorization: `Bearer ${token}` } : {}
}

// createUploadLink is a drop-in for createHttpLink that encodes File/Blob
// variables as multipart/form-data (option images, completion photos).
const httpLink = createUploadLink({
  uri: `${API_URL}/graphql`,
  fetch: (uri: RequestInfo | URL, options: RequestInit = {}) => {
    const existing = (options.headers as Record<string, string>) ?? {}
    return fetch(uri, { ...options, headers: { ...existing, ...getAuthHeaders() } })
  },
})

// GraphQL subscriptions ride Rails ActionCable. The consumer is anonymous —
// guests have no JWT, and per-subscription authorization happens server-side via
// the unguessable tokens passed as subscription variables. (graphql-ruby-client's
// ActionCableLink speaks the ActionCable protocol that Rails actually serves;
// graphql-ws — which puzler wires — is the wrong protocol here.)
const cable = createConsumer(`${WS_URL}/cable`)
const cableLink = new ActionCableLink({ cable })

// Subscription operations go to the cable link; everything else to the upload/http link.
const link = split(
  ({ query }) => {
    const def = getMainDefinition(query)
    return def.kind === 'OperationDefinition' && def.operation === 'subscription'
  },
  cableLink,
  httpLink,
)

export const apolloClient = new ApolloClient({
  link,
  cache: new InMemoryCache({ possibleTypes: fragmentTypes.possibleTypes }),
  defaultOptions: {
    watchQuery: { fetchPolicy: 'cache-and-network' },
  },
})
