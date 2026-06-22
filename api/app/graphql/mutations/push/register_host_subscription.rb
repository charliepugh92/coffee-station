# frozen_string_literal: true

module Mutations
  module Push
    class RegisterHostSubscription < Mutations::BaseMutation
      description "Register this device for the authenticated host's push notifications"

      argument :auth, String, required: true, description: "Client auth secret"
      argument :endpoint, String, required: true, description: "Push service endpoint URL"
      argument :p256dh, String, required: true, description: "Client public key (p256dh)"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the device was registered"

      def resolve(endpoint:, p256dh:, auth:)
        require_auth!
        PushSubscription.register(subscriber: current_user, endpoint:, p256dh:, auth:)
        { success: true, errors: [] }
      end
    end
  end
end
