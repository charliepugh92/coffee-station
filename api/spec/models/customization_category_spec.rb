require "rails_helper"

RSpec.describe CustomizationCategory, type: :model do
  it { is_expected.to belong_to(:station) }
  it { is_expected.to have_many(:customization_options).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to define_enum_for(:selection_mode).with_values(single: 0, multi: 1) }
end
