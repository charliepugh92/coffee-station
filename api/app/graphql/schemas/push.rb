# frozen_string_literal: true

module Schemas
  module Push
    module Mutations
      include Types::Interfaces::BaseInterface
      description "Web Push subscription mutations"
      graphql_name "PushMutations"

      field :register_guest_push_subscription, mutation: ::Mutations::Push::RegisterGuestSubscription,
        description: "Register this device to be notified when an order is ready"
      field :register_host_push_subscription, mutation: ::Mutations::Push::RegisterHostSubscription,
        description: "Register this device for the authenticated host's notifications"
      field :unregister_push_subscription, mutation: ::Mutations::Push::UnregisterSubscription,
        description: "Remove a push subscription by endpoint"
    end
  end
end
