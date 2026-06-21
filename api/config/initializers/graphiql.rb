# Configure the GraphiQL explorer mounted at /explorer.
GraphiQL::Rails.config.tap do |config|
  config.title = "Davey's Coffee API Explorer"
  config.header_editor_enabled = true   # lets you set an Authorization header
  config.should_persist_headers = true  # remembers the header across reloads
end
