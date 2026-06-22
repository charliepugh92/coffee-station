class Base < ApplicationRecord
  belongs_to :station
  has_one_attached :image
  has_many :base_categories, dependent: :destroy
  has_many :customization_categories, through: :base_categories

  validates :name, presence: true, length: { maximum: 80 }
  validates :surcharge_cents, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
