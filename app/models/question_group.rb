# frozen_string_literal: true

class QuestionGroup < ApplicationRecord
  class Limit
    include StoreModel::Model

    attribute :value, :string
    attribute :max, :integer
  end

  class Config
    include StoreModel::Model

    attribute :limits, Limit.to_array_type, default: []

    def limit_for(value)
      limit = limits.detect { |limit| limit.value == value }
      return 1 if limit.blank?

      limit.max
    end
  end

  has_many :question_links, dependent: :destroy
  has_many :questions, through: :question_links

  attribute :config, Config.to_type
end
