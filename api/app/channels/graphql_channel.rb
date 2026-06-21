# Executes GraphQL operations sent by the frontend's ActionCableLink. Queries and
# mutations get a single reply; subscriptions stream updates until the client
# unsubscribes. The connection is anonymous — per-subscription authorization is
# enforced inside each Subscriptions::* class via the tokens passed as arguments.
class GraphqlChannel < ApplicationCable::Channel
  def subscribed
    @subscription_ids = []
  end

  def unsubscribed
    @subscription_ids.each { |sid| ApiSchema.subscriptions.delete_subscription(sid) }
  end

  def execute(data)
    result = ApiSchema.execute(
      data["query"],
      context: { channel: self },
      variables: data["variables"] || {},
      operation_name: data["operationName"]
    )

    transmit({ result: result.to_h, more: result.subscription? })
    @subscription_ids << result.context[:subscription_id] if result.context[:subscription_id]
  end
end
