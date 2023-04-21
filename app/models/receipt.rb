# frozen_string_literal: true

class Receipt < ApplicationRecord
  has_paper_trail

  belongs_to :voter, polymorphic: true
  belongs_to :question
end
