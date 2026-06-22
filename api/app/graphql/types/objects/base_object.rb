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
      # The public host/protocol live in encrypted credentials (production.yml.enc);
      # dev/test/CI have no such entry, so credentials return nil and we fall back to
      # localhost http.
      def attachment_url(attachment)
        return nil unless attachment.attached?

        Rails.application.routes.url_helpers.rails_blob_url(attachment, host: api_host, protocol: api_protocol)
      end

      def api_host
        Rails.application.credentials.api_host || "localhost:3000"
      end

      def api_protocol
        Rails.application.credentials.api_protocol || "http"
      end
    end
  end
end
