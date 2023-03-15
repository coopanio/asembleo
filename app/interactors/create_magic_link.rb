# frozen_string_literal: true

class CreateMagicLink < Actor
  input :user_id, type: Integer, allow_nil: true, default: nil
  input :email, type: String, allow_nil: true, default: nil
  input :send_email, type: [TrueClass, FalseClass], default: false

  output :token, type: Token
  output :url

  def call
    create_token
    create_link

    deliver if send_email
  end

  private

  def create_token
    result = CreateToken.result(
      role: :voter,
      scope: :global,
      scope_context: { user_id: user.id }
    )
    self.token = result.token
  end

  def create_link
    self.url = Rails.application.routes.url_helpers.magic_link_url(token.to_hash)
  end

  def user
    return @user if defined?(@user)
    return @user = User.find(user_id) if user_id.present?
    return @user = User.find_by(identifier: email) if email.present?

    raise ActiveRecord::RecordNotFound
  end

  def deliver
    SessionsMailer.magic_link_email(email, token).deliver_later
  end
end
