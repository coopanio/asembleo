# frozen_string_literal: true

class SessionsMailer < ApplicationMailer
  def magic_link_email(to, token)
    @token = token
    raise Errors::InvalidEmail unless EmailValidator.valid?(to, mode: :strict)

    tag = TokenTag.sent
    mail(to:, template_name: 'magic_link_email', subject: I18n.t('mailers.sessions_mailer.new_consultation')) do |format|
      format.text
    end
  rescue StandardError => e
    tag = TokenTag.failed

    raise e
  ensure
    token.tags << tag
    token.save!
  end
end
