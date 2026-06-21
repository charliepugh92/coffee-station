require "rails_helper"

RSpec.describe Rating, type: :model do
  subject { build(:rating) }

  it { is_expected.to belong_to(:order) }
  it { is_expected.to validate_inclusion_of(:stars).in_range(1..5) }
  it { is_expected.to validate_uniqueness_of(:order_id) }
end
