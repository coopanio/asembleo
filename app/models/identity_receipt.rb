# frozen_string_literal: true

class IdentityReceipt < ApplicationRecord
  after_initialize :init

  def self.generate(identifier:)
    fingerprint = FingerprintService.generate(identifier)

    find_or_initialize_by(fingerprint:)
  end

  def to_hash(*args)
    HashIdService.encode(id, *args)
  end

  def to_salted_hash(*args)
    HashIdService.encode(id, salt, *args)
  end

  private

  def init
    self.salt = SecureRandom.random_number(9_999) if salt.blank?
  end
end
