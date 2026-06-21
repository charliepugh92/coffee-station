# frozen_string_literal: true

module Mutations
  module Menu
    class DeleteCategory < Mutations::BaseMutation
      description "Delete a customization category"

      argument :id, ID, required: true, description: "Target record ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the operation succeeded"

      def resolve(id:)
        find_owned_category!(id).destroy
        { success: true, errors: [] }
      end
    end
  end
end
