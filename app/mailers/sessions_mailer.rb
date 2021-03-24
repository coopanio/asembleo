# frozen_string_literal: true

class SessionsMailer < ApplicationMailer
  def magic_link_email(to, token)
    @token = token
    mail(to: to, subject: "Votació de l'Assemblea Oberta Parlamentària")
  end
end
