require "rails_helper"

RSpec.describe UserSession, type: :model do
  let(:user) { create(:user) }

  def build_session(exp: 1.day.from_now, **attrs)
    user.user_sessions.create!(jti: SecureRandom.uuid, exp:, **attrs)
  end

  describe ".active" do
    it "includes unexpired sessions and excludes expired ones", :aggregate_failures do
      live = build_session(exp: 1.day.from_now)
      dead = build_session(exp: 1.day.ago)
      expect(described_class.active).to include(live)
      expect(described_class.active).not_to include(dead)
    end
  end

  describe "#touch_activity!" do
    let(:ua) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36" }

    it "stamps last_active_at and backfills a device label on first sight", :aggregate_failures do
      session = build_session
      session.touch_activity!(ua)
      expect(session.reload.last_active_at).to be_present
      expect(session.user_agent).to eq(ua)
      expect(session.device_label).to eq("Chrome on macOS")
    end

    it "does not overwrite an existing user_agent" do
      session = build_session(user_agent: "original", device_label: "Original")
      session.touch_activity!("a different ua")
      expect(session.reload.user_agent).to eq("original")
    end
  end

  describe ".device_label_for" do
    {
      "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Version/17.0 Mobile Safari/604.1" => "Safari on iPhone",
      "Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 Chrome/120.0 Mobile Safari/537.36" => "Chrome on Android",
      "Mozilla/5.0 (Windows NT 10.0) Gecko/20100101 Firefox/121.0" => "Firefox on Windows",
      "" => "Unknown device",
      "some-unrecognizable-agent" => "Unknown device"
    }.each do |ua, label|
      it "labels #{ua.inspect} as #{label.inspect}" do
        expect(described_class.device_label_for(ua)).to eq(label)
      end
    end
  end
end
