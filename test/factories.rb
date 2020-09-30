# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
FactoryBot.define do
  factory :token do
    consultation
    salt { 9_999 }

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
    status { :draft }
  end

  factory :question do
    consultation
    options { { 'yes': 'Yes', 'no': 'No', 'abstain': 'Abstain' } }
    status { :draft }
  end

  factory :event do
    consultation
    status { :closed }
  end

  factory :events_question do
    event
    question
    status { :closed }
  end

  factory :vote do
    question
    value { 'yes' }
  end

  factory :receipt do
    token
    question
  end
end
# rubocop:enable Metrics/BlockLength
