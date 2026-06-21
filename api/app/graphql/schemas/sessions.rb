# frozen_string_literal: true

module Schemas
  module Sessions
    module Queries
      include Types::Interfaces::BaseInterface
      description "Public session lookup for guests"
      graphql_name "SessionQueries"

      field :session_by_token, Types::Objects::SessionType, null: true,
        description: "Look up a session (and its station's menu) by its public share token" do
        argument :token, String, required: true, description: "The session's share token from the guest link"
      end

      def session_by_token(token:)
        Session.find_by(share_token: token)
      end
    end

    module Mutations
      include Types::Interfaces::BaseInterface
      description "Session open/close mutations"
      graphql_name "SessionMutations"

      field :close_session, mutation: ::Mutations::Sessions::CloseSession,
        description: "Close a session"
      field :open_session, mutation: ::Mutations::Sessions::OpenSession,
        description: "Open a station for orders"
    end
  end
end
