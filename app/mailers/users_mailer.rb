# frozen_string_literal: true

class UsersMailer < ApplicationMailer
  def confirmation_email(to, receipt, user_id)
    raise Errors::InvalidEmail unless EmailValidator.valid?(to, mode: :strict)

    @receipt = receipt
    @user_id = user_id

    mail(to:, template_name: 'confirmation_email',
         subject: I18n.t('users_mailer.confirmation_email.subject')) do |format|
      format.text
    end
  end

  def approval_email(to, receipt, user_id)
    raise Errors::InvalidEmail unless EmailValidator.valid?(to, mode: :strict)

    @receipt = receipt
    @user_id = user_id

    mail(to:, template_name: 'approval_email', subject: I18n.t('users_mailer.approval_email.subject')) do |format|
      format.text
    end
  end

  def welcome_email(to, receipt, user_id)
    raise Errors::InvalidEmail unless EmailValidator.valid?(to, mode: :strict)

    @receipt = receipt

    result = CreateMagicLink.result(user_id:)
    @magic_link_url = result.url

    mail(to:, template_name: 'welcome_email', subject: I18n.t('users_mailer.welcome_email.subject')) do |format|
      format.text
    end
  end
end
