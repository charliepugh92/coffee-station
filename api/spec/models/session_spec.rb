require "rails_helper"

RSpec.describe Session, type: :model do
  it { is_expected.to belong_to(:station) }
  it { is_expected.to define_enum_for(:status).with_values(open: 0, closed: 1) }

  it "mints a share token on create" do
    expect(create(:session).share_token).to be_present
  end

  it "is accepting orders only while open", :aggregate_failures do
    session = create(:session)
    expect(session.accepting_orders?).to be(true)
    session.close!
    expect(session.accepting_orders?).to be(false)
  end

  it "forbids two open sessions for the same station" do
    station = create(:station)
    create(:session, station:)
    expect { create(:session, station:) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "allows a new open session once the previous one is closed" do
    station = create(:station)
    create(:session, station:).close!
    expect { create(:session, station:) }.not_to raise_error
  end
end
