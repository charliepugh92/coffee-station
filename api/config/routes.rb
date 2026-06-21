Rails.application.routes.draw do
  devise_for :users,
    controllers: {
      sessions: "users/sessions",
      registrations: "users/registrations",
      passwords: "users/passwords"
    }

  root to: "application#root"

  # GraphQL API Explorer (GraphiQL) — supports header editor for Bearer tokens.
  mount GraphiQL::Rails::Engine, at: "/explorer", graphql_path: "/graphql"

  # GraphQL endpoint (queries, mutations) — POST only.
  post "/graphql", to: "graphql#execute"

  # Action Cable WebSocket (GraphQL subscriptions ride this).
  mount ActionCable.server => "/cable"

  # Health check for load balancers / uptime monitors.
  get "up" => "rails/health#show", as: :rails_health_check
end
