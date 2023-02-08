# frozen_string_literal: true

class TokenTag < ApplicationRecord
  belongs_to :token

  validates :value, presence: true, inclusion: { in: %w[sent failed] }

  def self.sent
    new(value: 'sent')
  end

  def self.failed
    new(value: 'failed')
  end
end
