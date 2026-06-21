FactoryBot.define do
  factory :session do
    association :station
    status { :open }
    opened_at { Time.current }
  end
end
