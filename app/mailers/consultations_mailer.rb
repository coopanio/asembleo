# frozen_string_literal: true

class ConsultationsMailer < ApplicationMailer
  def default_tokens_email(to, tokens)
    @tokens = tokens

    mail(to:, template_name: 'default_tokens_email', subject:) do |format|
      format.text
    end
  end

  private

  def subject
    "Tokens created for #{consultation.title}"
  end

  def consultation
    @consultation ||= @tokens.first.consultation
  end
end
