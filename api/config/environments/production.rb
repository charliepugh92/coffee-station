require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on Cloudflare R2 (S3-compatible) so images survive
  # redeploys and instance spin-down (see config/storage.yml for the service).
  config.active_storage.service = :cloudflare

  # Skip image analysis on upload. Nothing in the app reads image metadata or
  # renders variants, but attach() otherwise enqueues an analyze job that
  # re-downloads the full image back from R2 and decodes it with libvips inside
  # the web worker — a memory spike on the 512MB tier that client-side
  # downscaling can't prevent (it's a server-side re-download). Empty analyzers
  # means the analyze step finds no analyzer and skips the download entirely.
  config.active_storage.analyzers = []

  # Render terminates SSL at its proxy, so trust X-Forwarded-Proto.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # config.cache_store = :mem_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # config.active_job.queue_adapter = :resque

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: "example.com" }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Allow requests to the Render-assigned host and our custom API domain. The
  # custom domain (api.daveys.coffee) lives in credentials as api_host — Render's
  # RENDER_EXTERNAL_HOSTNAME only ever holds the *.onrender.com name, so without
  # this the host check blocks requests arriving on the custom domain.
  config.hosts << /.*\.onrender\.com/
  config.hosts << ENV["RENDER_EXTERNAL_HOSTNAME"] if ENV["RENDER_EXTERNAL_HOSTNAME"].present?
  config.hosts << Rails.application.credentials.api_host if Rails.application.credentials.api_host.present?
  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Action Cable rejects cross-origin WebSocket handshakes unless the SPA origin
  # is whitelisted — without this, GraphQL subscriptions never connect in prod.
  config.action_cable.allowed_request_origins = Rails.application.frontend_origins
end
