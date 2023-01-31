# frozen_string_literal: true

require 'securerandom'

class Token < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  belongs_to :event, optional: true

  has_many :receipts

  enum role:   { voter: 0, manager: 1, admin: 2 }
  enum status: { enabled: 1, disabled: 0 }

  translate_enum :role

  validates :alias, uniqueness: { scope: :consultation_id, if: proc { |t| t.alias.present? } }

  after_initialize :init

  def self.from_value(value)
    token = Token.from_hash(value)
    token = Token.from_alias(value) if token.nil?

    token
  end

  def self.from_hash(hash)
    hash = sanitize(hash)

    ids = HashIdService.decode(hash)
    Token.find(ids.first) unless ids.empty?
  end

  def self.from_alias(value)
    value = sanitize(value)

    Token.find_by!(alias: value)
  end

  def self.sanitize(value)
    value = value.downcase
    value.delete('^0-9a-z')
  end

  def to_s
    to_hash
  end

  def to_hash
    HashIdService.encode(id, consultation_id, salt)
  end

  private

  def init
    self.salt = SecureRandom.random_number(9_999) if salt.blank?
  end
end
