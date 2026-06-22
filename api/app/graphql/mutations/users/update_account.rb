# frozen_string_literal: true

module Mutations
  module Users
    class UpdateAccount < Mutations::BaseMutation
      description "Update the current host's account — email, display name and/or password (requires the current password)"

      argument :current_password, String, required: true, description: "The account's current password, for confirmation"
      argument :display_name, String, required: false, description: "New display name"
      argument :email, String, required: false, description: "New login email"
      argument :password, String, required: false, description: "New password (omit to keep the current one)"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :user, Types::Objects::UserType, null: true, description: "The updated account"

      def resolve(current_password:, email: nil, display_name: nil, password: nil)
        require_auth!
        user = current_user
        return { user: nil, errors: [ "Current password is incorrect" ] } unless user.valid_password?(current_password)

        user.email = email if email.present?
        user.display_name = display_name if display_name.present?
        user.password = password if password.present?

        if user.save
          { user:, errors: [] }
        else
          { user: nil, errors: user.errors.full_messages }
        end
      end
    end
  end
end
