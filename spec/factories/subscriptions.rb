# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    stripe

    trait :stripe do
      external_id { "sub_#{Faker::Alphanumeric.alphanumeric(number: 24)}" }
      source { 'stripe' }
      data { { 'id': external_id, 'object' => 'subscription' } }
    end
  end
end
