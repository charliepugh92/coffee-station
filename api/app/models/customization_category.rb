class CustomizationCategory < ApplicationRecord
  belongs_to :station
  has_many :customization_options, -> { order(:position) }, dependent: :destroy
  # Drop the join rows when a category is deleted — bases simply stop enabling it,
  # rather than the delete failing on the base_categories foreign key.
  has_many :base_categories, dependent: :destroy

  enum :selection_mode, { single: 0, multi: 1 }

  validates :name, presence: true, length: { maximum: 60 }
end
