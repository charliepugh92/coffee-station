require "rails_helper"

RSpec.describe WebPushSender do
  let(:device) do
    PushSubscription.register(subscriber: create(:user), endpoint: "https://push/x", p256dh: "p", auth: "a").push_device
  end
  let(:payload) { { title: "Hi", body: "there" } }

  it "sends the payload via WebPush with our VAPID creds" do
    allow(WebPush).to receive(:payload_send)
    described_class.deliver(device, payload)
    expect(WebPush).to have_received(:payload_send).with(hash_including(endpoint: "https://push/x", message: payload.to_json))
  end

  it "destroys a device the push service no longer recognises" do
    allow(WebPush).to receive(:payload_send).and_raise(WebPush::ExpiredSubscription.new(double(body: "Gone"), "host"))
    expect { described_class.deliver(device, payload) }.to change { PushDevice.exists?(device.id) }.from(true).to(false)
  end

  it "swallows transient delivery errors without deleting the device" do
    allow(WebPush).to receive(:payload_send).and_raise(WebPush::ResponseError.new(double(body: "Boom"), "host"))
    expect { described_class.deliver(device, payload) }.not_to change { PushDevice.exists?(device.id) }
  end

  it "does not raise (or delete) when a VAPID key is rejected", :aggregate_failures do
    allow(WebPush).to receive(:payload_send).and_raise(WebPush::Unauthorized.new(double(body: "401"), "host"))
    expect { described_class.deliver(device, payload) }.not_to raise_error
    expect(PushDevice.exists?(device.id)).to be(true)
  end

  it "does not raise (or delete) when the push service times out", :aggregate_failures do
    allow(WebPush).to receive(:payload_send).and_raise(Net::ReadTimeout)
    expect { described_class.deliver(device, payload) }.not_to raise_error
    expect(PushDevice.exists?(device.id)).to be(true)
  end
end
