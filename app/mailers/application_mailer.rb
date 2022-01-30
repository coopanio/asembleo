# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.x.asembleo.default_from
  layout 'mailer'
end
