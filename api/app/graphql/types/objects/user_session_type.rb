# frozen_string_literal: true

module Types
  module Objects
    class UserSessionType < BaseObject
      description "A single signed-in device for the authenticated host"

      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When this device first signed in"
      field :current, Boolean, null: false, description: "Whether this is the device making the request"
      field :device_label, String, null: true, description: "Friendly device label, e.g. \"Chrome on macOS\""
      field :id, ID, null: false, description: "Unique session ID"
      field :last_active_at, GraphQL::Types::ISO8601DateTime, null: true, description: "When this device last made a request"

      def current
        object.jti == context[:current_jti]
      end
    end
  end
end
