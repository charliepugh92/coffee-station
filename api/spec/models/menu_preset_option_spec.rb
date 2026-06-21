require "rails_helper"

RSpec.describe MenuPresetOption, type: :model do
  subject { create(:menu_preset).menu_preset_options.build(customization_option: create(:customization_option)) }

  it { is_expected.to belong_to(:menu_preset) }
  it { is_expected.to belong_to(:customization_option) }
  it { is_expected.to validate_uniqueness_of(:customization_option_id).scoped_to(:menu_preset_id) }
end
