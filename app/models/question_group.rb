# frozen_string_literal: true

class QuestionGroup < ApplicationRecord
  has_many :questions, through: :question_links
end
