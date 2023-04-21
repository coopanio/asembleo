# frozen_string_literal: true

class CreateToken < Actor
  input :identifier, type: String, allow_nil: true, default: nil
  input :role, type: Symbol, in: Token.roles.keys.map(&:to_sym)
  input :event, type: Event, allow_nil: true, default: nil
  input :aliased, type: [TrueClass, FalseClass], default: false
  input :send_magic_link, type: [TrueClass, FalseClass], default: false
  input :scope, type: Symbol, in: %i[consultation global], default: :consultation
  input :scope_context, type: Hash, default: -> { {} }

  output :token
  output :skip

  def call
    validate
    return if skip

    self.token = find_or_initialize_token
    new_token = token.new_record?

    token.status = :enabled if token.disabled?
    token.save! if new_token || token.changed?

    return unless new_token

    issue_receipt
    deliver if send_magic_link
  end

  private

  def consultation
    return nil if event.nil?

    event.consultation
  end

  def validate
    fail!(error: Errors::InvalidTokenScope) if scope == :consultation && consultation.nil?
    self.skip = true if already_issued?
  end

  def already_issued?
    return false if identifier.blank?
    return true unless TokenReceipt.generate(consultation:, identifier:).new_record?

    false
  end

  def find_or_initialize_token
    tkn = find_token
    return tkn if tkn.present?

    create_token
  end

  def find_token
    Token.from_value(cleaned_identifier) if identifier.present?
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def create_token
    return create_global_token if scope == :global
    return create_aliased_token if aliased

    Token.new(consultation:, event:, role:, scope:, scope_context:)
  end

  def create_global_token
    Token.new(role:, scope:, scope_context:)
  end

  def create_aliased_token
    Token.new(alias: cleaned_identifier, consultation:, event:, role:, scope:, scope_context:)
  end

  def cleaned_identifier
    @cleaned_identifier ||= Token.sanitize(identifier)
  end

  def issue_receipt
    return if identifier.blank?

    TokenReceipt.generate(consultation:, identifier:).save!
  end

  def deliver
    token.reload
    SessionsMailer.magic_link_email(identifier, token.class.name, token.id, token.to_hash, scope:).deliver_later
  end
end
