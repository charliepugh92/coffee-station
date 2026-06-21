# frozen_string_literal: true

module Types
  module Objects
    class BaseObject < GraphQL::Schema::Object
      edge_type_class(Types::Connections::BaseEdge)
      connection_type_class(Types::Connections::BaseConnection)
      field_class Types::Fields::BaseField

      private

      # Absolute URL for an Active Storage attachment, or nil if none is attached.
      # API-only mode has no request to infer the host from, so pass it explicitly.
      def attachment_url(attachment)
        return nil unless attachment.attached?

        Rails.application.routes.url_helpers.rails_blob_url(attachment, host: api_host)
      end

      def api_host
        ENV.fetch("API_HOST", "localhost:3000")
      end
    end
  end
end
