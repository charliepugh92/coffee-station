# frozen_string_literal: true

module Mutations
  module Push
    class UnregisterSubscription < Mutations::BaseMutation
      description "Remove a push subscription by endpoint (the endpoint is itself the capability)"

      argument :endpoint, String, required: true, description: "Push service endpoint URL to remove"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the operation succeeded"

      def resolve(endpoint:)
        PushSubscription.where(endpoint:).destroy_all
        { success: true, errors: [] }
      end
    end
  end
end
