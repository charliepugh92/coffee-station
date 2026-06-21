# frozen_string_literal: true

module Schemas
  module Stations
    module Queries
      include Types::Interfaces::BaseInterface
      description "Station queries for the current host"
      graphql_name "StationQueries"

      field :my_stations, [ Types::Objects::StationType ], null: false,
        description: "All stations owned by the current host"
      field :station, Types::Objects::StationType, null: true,
        description: "One of the current host's stations by ID" do
        argument :id, ID, required: true, description: "Station ID"
      end

      def my_stations
        return [] unless context[:current_user]

        context[:current_user].stations.order(:created_at)
      end

      def station(id:)
        context[:current_user]&.stations&.find_by(id:)
      end
    end

    module Mutations
      include Types::Interfaces::BaseInterface
      description "Station mutations"
      graphql_name "StationMutations"

      field :create_station, mutation: ::Mutations::Stations::CreateStation,
        description: "Create a new station"
      field :delete_station, mutation: ::Mutations::Stations::DeleteStation,
        description: "Delete a station"
      field :update_station, mutation: ::Mutations::Stations::UpdateStation,
        description: "Update a station"
    end
  end
end
