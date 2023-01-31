# frozen_string_literal: true

class SessionsMailer < ApplicationMailer
  def magic_link_email(to, token)
    @token = token
    mail(to:, template_name: 'magic_link_email', subject: I18n.t("mailers.sessions_mailer.new_consultation")) do |format|
      format.text
    end
  end
end
