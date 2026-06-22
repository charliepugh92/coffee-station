# frozen_string_literal: true

module Schemas
  module Users
    module Queries
      include Types::Interfaces::BaseInterface
      description "Current-user queries"
      graphql_name "UserQueries"

      field :me, Types::Objects::UserType, null: true,
        description: "The currently authenticated host, or null if unauthenticated"

      def me
        context[:current_user]
      end
    end

    module Mutations
      include Types::Interfaces::BaseInterface
      description "Current-user mutations"
      graphql_name "UserMutations"

      field :update_account, mutation: ::Mutations::Users::UpdateAccount,
        description: "Update the current host's email, display name and/or password"
    end
  end
end
