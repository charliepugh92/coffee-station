require "rails_helper"

RSpec.describe MenuPreset, type: :model do
  it { is_expected.to belong_to(:station) }
  it { is_expected.to have_many(:customization_options).through(:menu_preset_options) }
  it { is_expected.to validate_presence_of(:name) }
end
