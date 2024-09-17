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
    fail!(error: Errors::ClosedConsultation.new) if consultation&.closed?
    return if identifiers.blank?

    invalid_identifiers = identifiers.reject { |identifier| validate_identifier(identifier) }
    fail!(error: Errors::InvalidIdentifiers.new(invalid_identifiers:)) if invalid_identifiers.present?
  end

  def create_tokens
    identifiers.each do |identifier|
      CreateToken.call(identifier:, role:, aliased:, send_magic_link:, event:)
    end
  end

  def validate_identifier(identifier)
    if consultation&.config.alias == 'spanish_nid'
      begin
        DniNie.validate(identifier)
      rescue
        false
      end
    elsif send_magic_link
      EmailValidator.valid?(identifier, mode: :strict)
    else
      true
    end
  end

  def consultation
    event&.consultation
  end
end
