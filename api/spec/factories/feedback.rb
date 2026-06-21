FactoryBot.define do
  factory :rating do
    association :order
    stars { 5 }
  end

  factory :comment do
    association :order
    body { "Great coffee!" }
  end
end
