module GraphqlHelpers
  # A no-op stand-in for an ActionCable channel, so subscription queries can be
  # executed in tests without a real WebSocket transport (exercises `subscribe`).
  class StubChannel
    def stream_from(*, **)
      nil
    end
  end

  def execute_query(query_string, variables: {}, context: {})
    ApiSchema.execute(query_string, variables: variables, context: context)
  end

  def auth_context(user)
    { current_user: user }
  end

  def subscription_context(extra = {})
    { channel: StubChannel.new }.merge(extra)
  end

  # Dig into the data hash of a result using a camelCase field path.
  def gql_data(result, *keys)
    keys.reduce(result["data"]) { |node, key| node&.fetch(key, nil) }
  end

  def gql_errors(result)
    result["errors"] || []
  end
end
