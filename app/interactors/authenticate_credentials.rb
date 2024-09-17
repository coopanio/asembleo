# frozen_string_literal: true

class AuthenticateCredentials < Actor
  input :identifier, allow_nil: false
  input :password

  output :identity

  def call
    return authenticate_user if password.present?

    authenticate_token
    promote_token if identity.scope == 'global'
  rescue ActiveRecord::RecordNotFound
    fail!(error: Errors::AccessDenied.new(identifier_type:))
  end

  private

  def authenticate_user
    self.identity = User.find_by!(identifier:)
    fail!(error: Errors::AccessDenied.new(identifier_type:)) unless identity.authenticate(password)
    fail!(error: Errors::AccessDenied.new(identifier_type:)) if identity.disabled?
  end

  # TODO: fix aliased tokens, because they cause a security vulnerability.
  def authenticate_token
    self.identity = Token.from_hash(identifier)
    # self.identity = Token.from_alias(identifier) if identity.nil?
    fail!(error: Errors::AccessDenied.new(identifier_type:)) if identity.nil?
    fail!(error: Errors::AccessDenied.new(identifier_type:)) if identity.disabled?
  end

  def promote_token
    self.identity = User.find(identity.scope_context['user_id'])
    fail!(error: Errors::AccessDenied.new(identifier_type:)) if identity.disabled?
  end

  def identifier_type
    return identity.class.name.underscore.to_sym if identity.present?
    return User.name.underscore.to_sym if password.present?

    Token.name.underscore.to_sym
  end
end
