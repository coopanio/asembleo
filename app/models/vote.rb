# frozen_string_literal: true

class Vote < ApplicationRecord
  has_paper_trail

  belongs_to :event
  belongs_to :question
end
