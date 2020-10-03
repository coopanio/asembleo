# frozen_string_literal: true

class Option < ApplicationRecord
  has_paper_trail

  belongs_to :question
end
