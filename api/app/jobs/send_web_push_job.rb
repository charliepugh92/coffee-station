# frozen_string_literal: true

# One job per device so a single dead endpoint never blocks the others.
class SendWebPushJob < ApplicationJob
  queue_as :default

  def perform(subscription_id, payload)
    subscription = PushSubscription.find_by(id: subscription_id)
    return unless subscription

    WebPushSender.deliver(subscription, payload)
  end
end
