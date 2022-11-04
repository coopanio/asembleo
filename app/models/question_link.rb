# frozen_string_literal: true

class QuestionLink < ApplicationRecord
  belongs_to :question
  belongs_to :question_group
end
