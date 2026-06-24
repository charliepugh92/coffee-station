require "rails_helper"

RSpec.describe PushSubscription do
  let(:user) { create(:user) }

  describe ".register" do
    it "creates a device-backed subscription for the subscriber", :aggregate_failures do
      sub = described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "p", auth: "a")
      expect(sub).to be_persisted
      expect(sub.subscriber).to eq(user)
      expect(sub.push_device.endpoint).to eq("https://push/1")
      expect(sub.push_device.p256dh_key).to eq("p")
    end

    it "upserts the device by endpoint instead of duplicating it", :aggregate_failures do
      described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "old", auth: "old")
      described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "new", auth: "new")
      expect(PushDevice.where(endpoint: "https://push/1").count).to eq(1)
      expect(PushDevice.find_by(endpoint: "https://push/1").p256dh_key).to eq("new")
      # Same device + same subscriber → still a single link.
      expect(described_class.count).to eq(1)
    end

    it "links one device to many subscribers instead of stealing it" do
      order = create(:order)
      described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "p", auth: "a")
      described_class.register(subscriber: order, endpoint: "https://push/1", p256dh: "p", auth: "a")
      device = PushDevice.find_by(endpoint: "https://push/1")
      # Both subscriptions coexist on the one browser — the whole point of the
      # device/join model (a returning guest's phone tracks a new order AND the host).
      expect(device.push_subscriptions.map(&:subscriber)).to contain_exactly(user, order)
    end
  end

  it "requires a device and a subscriber" do
    expect(described_class.new).not_to be_valid
  end

  it "is removed when its order is destroyed (the device survives)", :aggregate_failures do
    order = create(:order)
    described_class.register(subscriber: order, endpoint: "https://push/2", p256dh: "p", auth: "a")
    expect { order.destroy }.to change(described_class, :count).by(-1)
    expect(PushDevice.where(endpoint: "https://push/2")).to exist
  end
end
