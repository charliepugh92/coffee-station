# frozen_string_literal: true

module Mutations
  module Menu
    class UploadBaseImage < Mutations::BaseMutation
      description "Attach (or replace) the image for a base drink (multipart upload)"

      argument :base_id, ID, required: true, description: "Target base ID"
      argument :file, ::ApolloUploadServer::Upload, required: true, description: "The image file"

      field :base, Types::Objects::BaseType, null: true, description: "The resulting base"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(base_id:, file:)
        base = find_owned_base!(base_id)
        base.image.attach(io: file, filename: file.original_filename, content_type: file.content_type)
        { base:, errors: [] }
      end
    end
  end
end
