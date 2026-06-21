# frozen_string_literal: true

module Mutations
  module Menu
    class DeleteOption < Mutations::BaseMutation
      description "Delete a customization option"

      argument :id, ID, required: true, description: "Target record ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :success, Boolean, null: false, description: "Whether the operation succeeded"

      def resolve(id:)
        find_owned_option!(id).destroy
        { success: true, errors: [] }
      end
    end
  end
end
