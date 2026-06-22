class BaseCategory < ApplicationRecord
  belongs_to :base
  belongs_to :customization_category

  validates :customization_category_id, uniqueness: { scope: :base_id }
end
