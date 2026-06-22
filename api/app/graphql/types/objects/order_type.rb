# frozen_string_literal: true

module Types
  module Objects
    class OrderType < BaseObject
      description "A guest's coffee order"

      field :base, BaseType, null: true, description: "The chosen base drink, if any"
      field :can_reorder, Boolean, null: false,
        description: "Whether the order's station is currently open, so it can be reordered"
      field :comments, [ CommentType ], null: false, description: "Guest comments on this order"
      field :completion_photo_url, String, null: true, description: "Photo of the finished drink, once ready"
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the order was placed"
      field :guest_name, String, null: false, description: "Name the guest gave"
      field :id, ID, null: false, description: "Unique order ID"
      field :menu_preset, MenuPresetType, null: true, description: "The preset the guest picked, if any"
      field :notes, String, null: true, description: "Free-text notes from the guest"
      field :queue_position, Integer, null: true,
        description: "1-based spot in the make-line, or null once ready/picked up"
      field :rating, RatingType, null: true, description: "The guest's rating, once left"
      field :selections, [ CustomizationOptionType ], null: false,
        description: "Chosen customization options", method: :customization_options
      field :station_id, ID, null: false, description: "ID of the station this order was placed at"
      field :station_name, String, null: false, description: "Name of the station this order was placed at"
      field :status, Types::Enums::OrderStatusEnum, null: false, description: "Lifecycle status"

      def completion_photo_url
        attachment_url(object.completion_photo)
      end

      def can_reorder
        object.session.station.open_session.present?
      end

      def station_id
        object.station.id
      end

      def station_name
        object.station.name
      end
    end
  end
end
