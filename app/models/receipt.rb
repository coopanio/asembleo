# frozen_string_literal: true

class Receipt < ApplicationRecord
  has_paper_trail

  belongs_to :token
  belongs_to :question
end
