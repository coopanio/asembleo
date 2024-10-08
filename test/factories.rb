# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :user do
    sequence(:identifier) { |n| "user#{n}" }
    password { 'wubbalubba' }
    status { :enabled }
  end

  factory :token do
    consultation
    salt { 9_999 }
    status { :enabled }

    trait :admin do
      role { :admin }
    end

    trait :manager do
      role { :manager }
    end
  end

  factory :consultation do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    status { :opened }
  end

  factory :question do
    consultation
    status { :draft }
  end

  factory :option do
    question
    value { 'yes' }
    description { Faker::Lorem.sentence }
  end

  factory :event do
    consultation
    status { :opened }
  end

  factory :events_question do
    event
    question
    consultation
    status { :closed }
  end

  factory :vote do
    question
    value { 'yes' }
  end

  factory :receipt do
    voter { create(:token) }
    question
  end
end
# rubocop:enable Metrics/BlockLength
