# frozen_string_literal: true

# Composition layer — no fields are defined here directly once domains exist.
# Each `implements` line attaches a domain schema module (a GraphQL interface)
# that owns a group of related query fields. The baseline `api_version` field
# keeps the query root valid before any domain is built.
module Schemas
  class QueryType < Types::Objects::BaseObject
    description "Root query type"

    implements Schemas::Users::Queries
    implements Schemas::Stations::Queries
    implements Schemas::Sessions::Queries
    implements Schemas::Orders::Queries

    field :api_version, String, null: false, description: "The running API version string"

    def api_version
      "0.1.0"
    end
  end
end
