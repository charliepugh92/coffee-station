# Be sure to restart your server when you modify this file.

# Allow the Vue frontend (Vite dev server, or the deployed origin) to call the API.
# `expose: Authorization` lets the SPA read the JWT issued by devise-jwt on login.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL", "http://localhost:5173")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ]
  end
end
