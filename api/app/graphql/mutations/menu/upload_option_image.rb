# frozen_string_literal: true

module Mutations
  module Menu
    class UploadOptionImage < Mutations::BaseMutation
      description "Attach (or replace) the image for a customization option (multipart upload)"

      argument :file, ::ApolloUploadServer::Upload, required: true, description: "The image file"
      argument :option_id, ID, required: true, description: "Target option ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :option, Types::Objects::CustomizationOptionType, null: true, description: "The resulting option"

      def resolve(option_id:, file:)
        option = find_owned_option!(option_id)
        option.image.attach(io: file, filename: file.original_filename, content_type: file.content_type)
        { option:, errors: [] }
      end
    end
  end
end
