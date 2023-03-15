# frozen_string_literal: true

require 'argon2'

class User < ApplicationRecord
  has_paper_trail

  has_many :receipts, foreign_key: 'token_id', dependent: :destroy

  enum :role, { voter: 0, manager: 1, admin: 2 }, default: :voter
  enum :status, { enabled: 1, disabled: 0 }, default: :disabled

  translate_enum :role

  def password=(raw_password)
    if raw_password.nil?
      @password = nil
      self.password_digest = nil
    else
      @password = raw_password
      self.password_digest = Argon2::Password.create(raw_password)
    end
  end

  def authenticate(raw_password)
    Argon2::Password.verify_password(raw_password, password_digest)
  end

  def email
    return identifier if EmailValidator.valid?(identifier, mode: :strict)

    nil
  end

  def to_hash
    HashIdService.encode(id)
  end
end
