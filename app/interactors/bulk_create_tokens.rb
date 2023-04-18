# frozen_string_literal: true

class BulkCreateTokens < Actor
  input :identifiers, type: Array
  input :role, type: Symbol, in: Token.roles.keys.map(&:to_sym)
  input :event, type: Event, allow_nil: true, default: nil
  input :aliased, type: [TrueClass, FalseClass], default: false
  input :send_magic_link, type: [TrueClass, FalseClass], default: false

  def call
    validate
    create_tokens
  end

  private

  def validate
    return if identifiers.blank?
    return unless send_magic_link

    invalid_identifiers = identifiers.reject { |identifier| EmailValidator.valid?(identifier, mode: :strict) }
    fail!(error: Errors::InvalidEmailAddress.new(emails: invalid_identifiers)) if invalid_identifiers.present?
  end

  def create_tokens
    identifiers.each do |identifier|
      CreateToken.call(identifier:, role:, aliased:, send_magic_link:, event:)
    end
  end
end
