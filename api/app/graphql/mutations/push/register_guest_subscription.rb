# frozen_string_literal: true

module Mutations
  module Push
    class RegisterGuestSubscription < Mutations::BaseMutation
      description "Register this device to be notified when a guest's order is ready"

      argument :auth, String, required: true, description: "Client auth secret"
      argument :endpoint, String, required: true, description: "Push service endpoint URL"
      argument :order_token, String, required: true, description: "The order's guest token"
      argument :p256dh, String, required: true, description: "Client public key (p256dh)"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the device was registered"

      def resolve(order_token:, endpoint:, p256dh:, auth:)
        order = Order.find_by(guest_token: order_token)
        return { success: false, errors: [ "Order not found" ] } unless order

        PushSubscription.register(subscriber: order, endpoint:, p256dh:, auth:)
        { success: true, errors: [] }
      end
    end
  end
end
