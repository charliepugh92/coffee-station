FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "host#{n}@example.com" }
    sequence(:display_name) { |n| "Host #{n}" }
    password { "beanjuice123" }
  end
end
