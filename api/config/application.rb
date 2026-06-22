require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Api
  class Application < Rails::Application
    # Surface the active GraphQL operation/field in SQL query-log comments.
    config.active_record.query_log_tags_enabled = true
    config.active_record.query_log_tags = [
      # Rails query log tags:
      :application, :controller, :action, :job,
      # GraphQL-Ruby query log tags:
      current_graphql_operation: -> { GraphQL::Current.operation_name },
      current_graphql_field: -> { GraphQL::Current.field&.path },
      current_dataloader_source: -> { GraphQL::Current.dataloader_source_class }
    ]

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # Auth is JWT-only, but Devise's `sign_in` (used by the sessions/registrations
    # controllers) writes the user into the Warden session, which an API-only app
    # disables by default. Re-add a minimal cookie session so that write succeeds.
    # The session is NOT the source of truth for auth — every request is
    # authenticated from the Bearer JWT; this just satisfies Devise/Warden.
    config.session_store :cookie_store, key: "_coffee_station_session", same_site: :lax
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use config.session_store, config.session_options

    # Browser origins allowed to call the API (CORS) and open Action Cable
    # WebSockets. We accept both the apex and `www` forms of the configured
    # frontend host, since both DNS names resolve to the same SPA and we don't
    # want to care which one the visitor landed on. Driven by the single
    # `frontend_url` credential, falling back to the Vite dev server locally.
    def frontend_origins
      configured = Rails.application.credentials.frontend_url || "http://localhost:5173"
      Array(configured).flat_map { |url| origin_variants(url) }.uniq
    end

    private

    # Expand a URL into its apex + `www` origin variants ("scheme://host[:port]").
    # Bare hosts without a dot (e.g. "localhost") are returned unchanged.
    def origin_variants(url)
      uri = URI(url)
      host = uri.host
      return [ url ] unless host&.include?(".")

      bare = host.delete_prefix("www.")
      port = uri.port && uri.port != uri.default_port ? ":#{uri.port}" : ""
      [ bare, "www.#{bare}" ].map { |h| "#{uri.scheme}://#{h}#{port}" }
    end
  end
end
