# frozen_string_literal: true

class TokenReceipt < ApplicationRecord
  belongs_to :consultation

  def self.generate(consultation:, identifier:)
    fingerprint = FingerprintService.generate(identifier, consultation.id)

    find_or_initialize_by(consultation:, fingerprint:)
  end
end
