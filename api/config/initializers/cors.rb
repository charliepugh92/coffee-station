# Be sure to restart your server when you modify this file.

# Allow the Vue frontend (Vite dev server, or the deployed origin) to call the API.
# `expose: Authorization` lets the SPA read the JWT issued by devise-jwt on login.
# The deployed origin lives in encrypted credentials (production.yml.enc); dev/test/CI
# have no such entry, so credentials return nil and we fall back to the Vite dev server.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins Rails.application.credentials.frontend_url || "http://localhost:5173"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ]
  end
end
