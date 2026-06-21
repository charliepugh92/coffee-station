# frozen_string_literal: true

module Mutations
  module Stations
    class CreateStation < Mutations::BaseMutation
      description "Create a new coffee station owned by the current host"

      argument :attrs, Types::InputObjects::StationAttrsInput, required: true, description: "Station attributes"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :station, Types::Objects::StationType, null: true, description: "The resulting station"

      def resolve(attrs:)
        require_auth!
        station = current_user.stations.build(attrs.to_h)
        if station.save
          { station:, errors: [] }
        else
          { station: nil, errors: station.errors.full_messages }
        end
      end
    end
  end
end
