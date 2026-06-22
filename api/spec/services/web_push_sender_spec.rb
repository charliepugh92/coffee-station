require "rails_helper"

RSpec.describe WebPushSender do
  let(:subscription) { PushSubscription.register(subscriber: create(:user), endpoint: "https://push/x", p256dh: "p", auth: "a") }
  let(:payload) { { title: "Hi", body: "there" } }

  it "sends the payload via WebPush with our VAPID creds" do
    allow(WebPush).to receive(:payload_send)
    described_class.deliver(subscription, payload)
    expect(WebPush).to have_received(:payload_send).with(hash_including(endpoint: "https://push/x", message: payload.to_json))
  end

  it "destroys a subscription the push service no longer recognises" do
    allow(WebPush).to receive(:payload_send).and_raise(WebPush::ExpiredSubscription.new(double(body: "Gone"), "host"))
    expect { described_class.deliver(subscription, payload) }.to change { PushSubscription.exists?(subscription.id) }.from(true).to(false)
  end

  it "swallows transient delivery errors without deleting the row" do
    allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(double(body: "Boom"), "host"))
    expect { described_class.deliver(subscription, payload) }.not_to change { PushSubscription.exists?(subscription.id) }
  end
end
