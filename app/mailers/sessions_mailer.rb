# frozen_string_literal: true

class SessionsMailer < ApplicationMailer
  def magic_link_email(to, voter_type, voter_id, voter_hash, scope: :consultation)
    @scope = scope.to_sym
    @voter_hash = voter_hash
    raise Errors::InvalidEmail unless EmailValidator.valid?(to, mode: :strict)

    mail(to:, template_name:, subject:) do |format|
      format.text
    end
  end

  private

  def template_name
    return 'user_magic_link_email' if @scope == :global

    'magic_link_email'
  end

  def subject
    return I18n.t('sessions_mailer.user_magic_link_email.subject') if @scope == :global

    I18n.t('sessions_mailer.magic_link_email.subject')
  end
end
