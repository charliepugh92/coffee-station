require "rails_helper"

RSpec.describe Station, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:customization_categories).dependent(:destroy) }
  it { is_expected.to have_many(:menu_presets).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }

  it "rejects a slug scoped-duplicate for the same user", :aggregate_failures do
    user = create(:user)
    create(:station, user:, slug: "bar")
    dup = build(:station, user:, slug: "bar")
    expect(dup).not_to be_valid
    expect(dup.errors[:slug]).to be_present
  end

  it "allows the same slug for different users" do
    create(:station, slug: "bar")
    expect(build(:station, slug: "bar")).to be_valid
  end
end
