# frozen_string_literal: true

class CreateToken < Actor
  input :identifier, type: String, allow_nil: true
  input :role, type: Symbol, in: Token.roles.keys.map(&:to_sym)
  input :event, type: Event, allow_nil: false

  output :token

  def call
    self.token = Token.find_or_initialize_by(alias: token_alias, consultation:, event:, role:)

    token.status = :enabled if token.disabled?
    token.save! if token.new_record? || token.changed?
  end

  private

  def consultation
    event.consultation
  end

  def token_alias
    return nil if identifier.blank?

    @token_alias ||= Token.sanitize(identifier)
  end
end
