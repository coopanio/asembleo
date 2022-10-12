# frozen_string_literal: true

class AuthenticateCredentials < Actor
  input :identifier, allow_nil: false
  input :password

  output :identity

  def call
    return authenticate_user if password.present?

    authenticate_token
  rescue ActiveRecord::RecordNotFound
    fail!(error: Errors::AccessDenied)
  end

  private

  def authenticate_user
    self.identity = User.find_by!(email: identifier)
    fail!(error: Errors::AccessDenied) unless identity.authenticate(password)
  end

  def authenticate_token
    self.identity = Token.from_value(identifier)
    fail!(error: Errors::AccessDenied) if identity.disabled?
  end
end
