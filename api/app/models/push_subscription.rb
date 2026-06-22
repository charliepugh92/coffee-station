class PushSubscription < ApplicationRecord
  # A host's device (subscriber: User) or a guest's tracked order (subscriber: Order).
  belongs_to :subscriber, polymorphic: true

  validates :endpoint, :p256dh_key, :auth_key, presence: true

  # Upsert by endpoint — re-subscribing the same browser refreshes its keys and
  # owner rather than piling up duplicate rows.
  def self.register(subscriber:, endpoint:, p256dh:, auth:)
    sub = find_or_initialize_by(endpoint:)
    sub.update!(subscriber:, p256dh_key: p256dh, auth_key: auth)
    sub
  end
end
