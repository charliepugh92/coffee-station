FactoryBot.define do
  factory :station do
    association :user
    sequence(:name) { |n| "Station #{n}" }
  end

  factory :customization_category do
    association :station
    sequence(:name) { |n| "Category #{n}" }
    selection_mode { :single }
  end

  factory :customization_option do
    association :customization_category
    sequence(:name) { |n| "Option #{n}" }
  end

  factory :menu_preset do
    association :station
    sequence(:name) { |n| "Preset #{n}" }
  end

  factory :base do
    association :station
    sequence(:name) { |n| "Base #{n}" }
  end
end
