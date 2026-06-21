class Rating < ApplicationRecord
  belongs_to :order

  validates :stars, inclusion: { in: 1..5 }
  validates :order_id, uniqueness: true
end
