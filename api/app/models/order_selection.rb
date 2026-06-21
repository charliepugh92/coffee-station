class OrderSelection < ApplicationRecord
  belongs_to :order
  belongs_to :customization_option

  validates :customization_option_id, uniqueness: { scope: :order_id }
end
