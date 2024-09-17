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
  output :skip_reason

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
    
    if consultation&.config&.alias == 'spanish_nid'
      begin
        valid = DniNie.validate(identifier)
      rescue
        valid = false
      end

      fail!(error: Errors::InvalidIdentifiers.new(invalid_identifiers: [identifier])) unless valid
    end

    if already_issued?
      self.skip_reason = :token_already_issued
    elsif consultation&.closed?
      self.skip_reason = :token_consultation_closed
    elsif consultation&.asynchronous? && event&.closed?
      self.skip_reason = :token_event_closed
    end

    self.skip = true if self.skip_reason
  end

  def already_issued?
    return false if identifier.blank?
    return true unless TokenReceipt.generate(consultation:, identifier: cleaned_identifier).new_record?

    false
  end

  def find_or_initialize_token
    tkn = find_token
    return tkn if tkn.present?

    create_token
  end

  def find_token
    token = Token.from_hash(cleaned_identifier) if identifier.present?
    return token if token.present?

    Token.from_alias(cleaned_identifier, event:) if identifier.present? && aliased
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def create_token
    return create_global_token if scope == :global
    return create_aliased_token if aliased && identifier.present?

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

    return unless token.is_a?(Token)

    token.tags << TokenTag.sent
    token.save!
  end
end
