# frozen_string_literal: true

class CreateToken < Actor
  input :identifier, type: String, allow_nil: true, default: nil
  input :role, type: Symbol, in: Token.roles.keys.map(&:to_sym)
  input :event, type: Event, allow_nil: false
  input :aliased, type: [TrueClass, FalseClass], default: false
  input :send_magic_link, type: [TrueClass, FalseClass], default: false

  output :token

  def call
    self.token = Token.find_or_initialize_by(alias: token_alias, consultation:, event:, role:)

    token.status = :enabled if token.disabled?
    token.save! if token.new_record? || token.changed?

    deliver if send_magic_link
  end

  private

  def consultation
    event.consultation
  end

  def token_alias
    return nil if identifier.blank?
    return nil unless aliased

    @token_alias ||= Token.sanitize(identifier)
  end

  def deliver
    SessionsMailer.magic_link_email(identifier, token.reload).deliver_later
  end
end
