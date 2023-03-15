# frozen_string_literal: true

class SessionsMailer < ApplicationMailer
  def magic_link_email(to, token)
    @token = token
    raise Errors::InvalidEmail unless EmailValidator.valid?(to, mode: :strict)

    tag = TokenTag.sent
    mail(to:, template_name:, subject:) do |format|
      format.text
    end
  rescue StandardError => e
    tag = TokenTag.failed

    raise e
  ensure
    token.tags << tag
    token.save!
  end

  private

  def template_name
    return 'user_magic_link_email' if @token.scope == 'global'

    'magic_link_email'
  end

  def subject
    return I18n.t('sessions_mailer.user_magic_link_email.subject') if @token.scope == 'global'

    I18n.t('sessions_mailer.magic_link_email.subject')
  end
end
