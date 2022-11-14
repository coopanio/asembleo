# frozen_string_literal: true

class QuestionGroup < ApplicationRecord
  has_many :question_links, dependent: :destroy
  has_many :questions, through: :question_links
end
