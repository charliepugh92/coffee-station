class PushSubscription < ApplicationRecord
  # Join between a browser (PushDevice) and who it wants notifications for:
  # a host's device (subscriber: User) or a guest's tracked order (subscriber: Order).
  belongs_to :push_device
  belongs_to :subscriber, polymorphic: true

  # Link a browser endpoint to a subscriber. Re-subscribing the same browser
  # refreshes the device's keys and ADDS a link to the new subscriber instead of
  # stealing the device from a previous one — so a returning guest's phone can
  # track a new order while still being subscribed to the host queue / past orders.
  #
  # create_or_find_by! (not find_or_create_by!) so concurrent registers of the
  # same endpoint/link — two tabs, a double-tap, or auto-subscribe-on-mount racing
  # a manual tap — resolve against the unique indexes instead of raising
  # RecordNotUnique and 500ing the mutation (which would leave the device
  # un-subscribed: exactly the bug this rebuild targets).
  def self.register(subscriber:, endpoint:, p256dh:, auth:)
    # Set keys in the create block so the initial insert passes validation; on a
    # concurrent-conflict the existing device is found (block not run), so update!
    # afterwards refreshes its keys either way.
    device = PushDevice.create_or_find_by!(endpoint:) do |d|
      d.p256dh_key = p256dh
      d.auth_key = auth
    end
    device.update!(p256dh_key: p256dh, auth_key: auth)
    create_or_find_by!(push_device: device, subscriber:)
  end
end
