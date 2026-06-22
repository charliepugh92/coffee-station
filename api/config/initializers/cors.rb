# Be sure to restart your server when you modify this file.

# Allow the Vue frontend (Vite dev server, or the deployed origin) to call the API.
# `expose: Authorization` lets the SPA read the JWT issued by devise-jwt on login.
# Origins come from `frontend_url` (encrypted credentials in prod; Vite dev server
# otherwise) and include both the apex and `www` variants — see Api::Application#frontend_origins.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*Rails.application.frontend_origins)

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ]
  end
end
