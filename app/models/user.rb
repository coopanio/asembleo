# frozen_string_literal: true

require 'argon2'

class User < ApplicationRecord
  has_paper_trail

  enum role: { user: 0, manager: 1, admin: 2 }
  enum status: { enabled: 1, disabled: 0 }

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
end
