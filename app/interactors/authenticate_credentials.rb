# frozen_string_literal: true

class AuthenticateCredentials < Actor
  input :identifier, allow_nil: false
  input :password

  output :identity

  def call
    return authenticate_user if password.present?

    authenticate_token
  rescue ActiveRecord::RecordNotFound
    fail!(error: Errors::AccessDenied.new(identifier_type:))
  end

  private

  def authenticate_user
    self.identity = User.find_by!(identifier:)
    fail!(error: Errors::AccessDenied.new(identifier_type:)) unless identity.authenticate(password)
  end

  def authenticate_token
    self.identity = Token.from_value(identifier)
    fail!(error: Errors::AccessDenied.new(identifier_type:)) if identity.disabled?
  end

  def identifier_type
    return User.name.underscore.to_sym if password.present?

    Token.name.underscore.to_sym
  end
end
