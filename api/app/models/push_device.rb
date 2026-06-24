class PushDevice < ApplicationRecord
  # One browser's Web Push registration (endpoint + crypto keys). Linked to any
  # number of subscribers (a host User and/or guest Orders) through
  # push_subscriptions, so one phone can be notified for many things at once.
  has_many :push_subscriptions, dependent: :destroy

  validates :endpoint, :p256dh_key, :auth_key, presence: true
end
