# frozen_string_literal: true

module Mutations
  module Sessions
    class OpenSession < Mutations::BaseMutation
      description "Open a station for orders, minting a fresh share link"

      argument :station_id, ID, required: true, description: "Station to open"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :session, Types::Objects::SessionType, null: true, description: "The newly opened session"

      def resolve(station_id:)
        station = find_owned_station!(station_id)
        return { session: nil, errors: [ "Station is already open" ] } if station.open_session

        session = station.sessions.create!(status: :open, opened_at: Time.current)
        trigger_session_updated(session)
        { session:, errors: [] }
      rescue ActiveRecord::RecordNotUnique
        { session: nil, errors: [ "Station is already open" ] }
      end
    end
  end
end
