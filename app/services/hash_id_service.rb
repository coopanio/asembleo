# frozen_string_literal: true

class HashIdService
  def self.encode(*ids)
    new.encode(*ids)
  end

  def self.decode(hash)
    new.decode(hash)
  end

  def initialize
    @hasher = Hashids.new(
      Rails.application.credentials.secret_key_base,
      Rails.configuration.hash_service.hash_length,
      Rails.configuration.hash_service.alphabet
    )
  end

  def encode(*ids)
    @hasher.encode(*ids.map { |id| id.nil? ? 0 : id })
  end

  def decode(hash)
    @hasher.decode(hash)
  rescue Hashids::InputError
    []
  end
end
