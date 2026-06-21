# frozen_string_literal: true

module Mutations
  module Stations
    class UpdateStation < Mutations::BaseMutation
      description "Update one of the current host's stations"

      argument :attrs, Types::InputObjects::StationAttrsInput, required: true, description: "Station attributes"
      argument :id, ID, required: true, description: "Target record ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :station, Types::Objects::StationType, null: true, description: "The resulting station"

      def resolve(id:, attrs:)
        station = find_owned_station!(id)
        if station.update(attrs.to_h)
          { station:, errors: [] }
        else
          { station: nil, errors: station.errors.full_messages }
        end
      end
    end
  end
end
