class CustomizationCategory < ApplicationRecord
  belongs_to :station
  has_many :customization_options, -> { order(:position) }, dependent: :destroy

  enum :selection_mode, { single: 0, multi: 1 }

  validates :name, presence: true, length: { maximum: 60 }
end
