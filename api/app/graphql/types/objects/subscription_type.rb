# frozen_string_literal: true

module Types
  module Objects
    class SubscriptionType < BaseObject
      description "Realtime events delivered over ActionCable"

      # Real subscription fields (orderAdded / orderUpdated / sessionUpdated) are
      # wired in the realtime milestone. A placeholder keeps the root valid.
      field :heartbeat, Boolean, null: false, description: "Placeholder keepalive field"

      def heartbeat
        true
      end
    end
  end
end
