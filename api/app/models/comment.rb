class Comment < ApplicationRecord
  belongs_to :order

  validates :body, presence: true, length: { maximum: 500 }
end
