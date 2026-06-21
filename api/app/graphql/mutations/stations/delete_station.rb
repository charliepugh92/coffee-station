# frozen_string_literal: true

module Mutations
  module Stations
    class DeleteStation < Mutations::BaseMutation
      description "Permanently delete one of the current host's stations"

      argument :id, ID, required: true, description: "Target record ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the operation succeeded"

      def resolve(id:)
        find_owned_station!(id).destroy
        { success: true, errors: [] }
      end
    end
  end
end
