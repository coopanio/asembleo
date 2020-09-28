# frozen_string_literal: true

class Consultation < ApplicationRecord
  has_paper_trail

  has_many :events, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :tokens, dependent: :destroy

  enum status: { draft: 0, open: 1, closed: 2, archived: 3 }
end
