# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.configuration.x.assemblea.default_from
  layout 'mailer'
end
