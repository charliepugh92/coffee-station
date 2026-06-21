# frozen_string_literal: true

module Mutations
  module Menu
    class DeletePreset < Mutations::BaseMutation
      description "Delete a menu preset"

      argument :id, ID, required: true, description: "Target record ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the operation succeeded"

      def resolve(id:)
        find_owned_preset!(id).destroy
        { success: true, errors: [] }
      end
    end
  end
end
