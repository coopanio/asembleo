# frozen_string_literal: true

class CreateToken < Actor
  input :identifier, type: String, allow_nil: true, default: nil
  input :role, type: Symbol, in: Token.roles.keys.map(&:to_sym)
  input :event, type: Event, allow_nil: false
  input :aliased, type: [TrueClass, FalseClass], default: false
  input :send_magic_link, type: [TrueClass, FalseClass], default: false

  output :token
  output :skip

  def call
    if already_issued?
      self.skip = true

      return
    end

    self.token = find_or_initialize_token

    new_token = token.new_record?
    token.save! if new_token || token.changed?

    return unless new_token

    issue_receipt
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

  def already_issued?
    return false if identifier.blank?
    return true unless TokenReceipt.generate(consultation:, identifier:).new_record?

    false
  end

  def find_or_initialize_token
    tkn = if aliased
            begin
              Token.from_value(token_alias)
            rescue ActiveRecord::RecordNotFound
              Token.new(alias: token_alias, consultation:, event:, role:)
            end
          else
            Token.find_or_initialize_by(consultation:, event:, role:)
          end

    tkn.status = :enabled if tkn.disabled?

    tkn
  end

  def issue_receipt
    return if identifier.blank?

    TokenReceipt.generate(consultation:, identifier:).save!
  end

  def deliver
    SessionsMailer.magic_link_email(identifier, token.reload).deliver_later
  end
end
