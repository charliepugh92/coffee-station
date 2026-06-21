FactoryBot.define do
  factory :order do
    association :session
    sequence(:guest_name) { |n| "Guest #{n}" }
    status { :pending }
  end
end
