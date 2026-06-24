require "rails_helper"

RSpec.describe PushDevice do
  it "requires an endpoint and crypto keys" do
    expect(described_class.new).not_to be_valid
  end

  it "destroys its subscriptions when the device is removed" do
    device = PushSubscription.register(subscriber: create(:user), endpoint: "https://push/d", p256dh: "p", auth: "a").push_device
    expect { device.destroy }.to change(PushSubscription, :count).by(-1)
  end
end
