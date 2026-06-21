# frozen_string_literal: true

module Types
  module Enums
    class OrderStatusEnum < BaseEnum
      description "Where an order is in its lifecycle"
      generate_from_rails_enum Order.statuses
    end
  end
end
