# frozen_string_literal: true

module Mutations
  module Menu
    class UploadPresetImage < Mutations::BaseMutation
      description "Attach (or replace) the image for a menu preset (multipart upload)"

      argument :file, ::ApolloUploadServer::Upload, required: true, description: "The image file"
      argument :preset_id, ID, required: true, description: "Target preset ID"

      field :errors, [ String ], null: false, description: "Validation errors, if any"
      field :preset, Types::Objects::MenuPresetType, null: true, description: "The resulting preset"

      def resolve(preset_id:, file:)
        preset = find_owned_preset!(preset_id)
        preset.image.attach(io: file, filename: file.original_filename, content_type: file.content_type)
        { preset:, errors: [] }
      end
    end
  end
end
