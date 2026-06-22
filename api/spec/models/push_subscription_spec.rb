require "rails_helper"

RSpec.describe PushSubscription do
  let(:user) { create(:user) }

  describe ".register" do
    it "creates a subscription for the subscriber", :aggregate_failures do
      sub = described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "p", auth: "a")
      expect(sub).to be_persisted
      expect(sub.subscriber).to eq(user)
      expect(sub.p256dh_key).to eq("p")
    end

    it "upserts by endpoint instead of duplicating", :aggregate_failures do
      described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "old", auth: "old")
      described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "new", auth: "new")
      expect(described_class.where(endpoint: "https://push/1").count).to eq(1)
      expect(described_class.find_by(endpoint: "https://push/1").p256dh_key).to eq("new")
    end

    it "re-points an endpoint at a new subscriber" do
      order = create(:order)
      described_class.register(subscriber: user, endpoint: "https://push/1", p256dh: "p", auth: "a")
      described_class.register(subscriber: order, endpoint: "https://push/1", p256dh: "p", auth: "a")
      expect(described_class.find_by(endpoint: "https://push/1").subscriber).to eq(order)
    end
  end

  it "requires endpoint and keys" do
    sub = described_class.new(subscriber: user)
    expect(sub).not_to be_valid
  end

  it "is removed when its order is destroyed" do
    order = create(:order)
    described_class.register(subscriber: order, endpoint: "https://push/2", p256dh: "p", auth: "a")
    expect { order.destroy }.to change(described_class, :count).by(-1)
  end
end
