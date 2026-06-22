# frozen_string_literal: true

# Composition layer — no fields are defined here directly once domains exist.
# Each `implements` line attaches a domain schema module (a GraphQL interface)
# that owns a group of related mutation fields. The baseline `ping` field keeps
# the mutation root valid until the first real domain (auth) lands.
module Schemas
  class MutationType < Types::Objects::BaseObject
    description "Root mutation type"

    implements Schemas::Users::Mutations
    implements Schemas::Stations::Mutations
    implements Schemas::Menu::Mutations
    implements Schemas::Sessions::Mutations
    implements Schemas::Orders::Mutations
    implements Schemas::Feedback::Mutations

    field :ping, Boolean, null: false, description: "No-op health-check mutation"

    def ping
      true
    end
  end
end
