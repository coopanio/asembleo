# frozen_string_literal: true

class Question < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_many :options, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum status: { draft: 0, opened: 1, closed: 2 }

  def valid_option?(value)
    options.exists?(value: value)
  end

  def voted?(token)
    receipts.exists?(token: token)
  end

  def position
    weight + 1
  end
end
