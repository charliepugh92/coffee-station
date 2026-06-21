import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { DefaultApolloClient } from '@vue/apollo-composable'
import './style.css'
import App from './App.vue'
import router from './router'
import { apolloClient } from './utils/apolloClient'
import { useAuthStore } from './stores/auth'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.provide(DefaultApolloClient, apolloClient)

// Restore the session on load (route guards await this when needed).
useAuthStore().fetchCurrentUser()

app.mount('#app')
