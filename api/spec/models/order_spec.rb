require "rails_helper"

RSpec.describe Order, type: :model do
  it { is_expected.to belong_to(:session) }
  it { is_expected.to belong_to(:base_option).class_name("CustomizationOption").optional }
  it { is_expected.to belong_to(:menu_preset).optional }
  it { is_expected.to have_many(:order_selections).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:guest_name) }
  it { is_expected.to define_enum_for(:status).with_values(pending: 0, in_progress: 1, ready: 2, picked_up: 3) }

  it "mints a guest token on create" do
    expect(create(:order).guest_token).to be_present
  end

  describe "#queue_position" do
    let(:session) { create(:session) }

    it "numbers un-finished orders oldest-first", :aggregate_failures do
      first = create(:order, session:, created_at: 2.minutes.ago)
      second = create(:order, session:, created_at: 1.minute.ago)
      expect(first.queue_position).to eq(1)
      expect(second.queue_position).to eq(2)
    end

    it "is nil once finished, and the rest move up", :aggregate_failures do
      first = create(:order, session:, created_at: 2.minutes.ago)
      second = create(:order, session:, created_at: 1.minute.ago)
      first.update!(status: :ready)
      expect(first.queue_position).to be_nil
      expect(second.reload.queue_position).to eq(1)
    end
  end
end
