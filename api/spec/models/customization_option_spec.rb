require "rails_helper"

RSpec.describe CustomizationOption, type: :model do
  it { is_expected.to belong_to(:customization_category) }
  it { is_expected.to validate_presence_of(:name) }

  it "delegates station to its category" do
    option = create(:customization_option)
    expect(option.station).to eq(option.customization_category.station)
  end
end
