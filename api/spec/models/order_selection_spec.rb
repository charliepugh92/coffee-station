require "rails_helper"

RSpec.describe OrderSelection, type: :model do
  subject { create(:order).order_selections.build(customization_option: create(:customization_option)) }

  it { is_expected.to belong_to(:order) }
  it { is_expected.to belong_to(:customization_option) }
  it { is_expected.to validate_uniqueness_of(:customization_option_id).scoped_to(:order_id) }
end
