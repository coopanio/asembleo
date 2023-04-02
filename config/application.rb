# frozen_string_literal: true

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_text/engine'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Asembleo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_job.queue_adapter = :sucker_punch

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # Voting
    config.x.asembleo.private_instance = ENV['ASEMBLEO_PRIVATE_INSTANCE'].present?
    config.x.asembleo.open_registration = ENV['ASEMBLEO_OPEN_REGISTRATION'].present?
    config.x.asembleo.token_alias = ENV['ASEMBLEO_TOKEN_ALIAS'].presence
    config.x.asembleo.async_vote = ActiveModel::Type::Boolean.new.cast(ENV['ASEMBLEO_ASYNC_VOTE'].presence) || false
    config.x.asembleo.hide_receipt = ActiveModel::Type::Boolean.new.cast(ENV['ASEMBLEO_HIDE_RECEIPT'].presence) || false

    # Branding
    config.x.asembleo.title = ENV['ASEMBLEO_TITLE'].presence || 'Asembleo'
    config.x.asembleo.footer = ENV['ASEMBLEO_FOOTER'].presence
    config.x.asembleo.logo_url = ENV['ASEMBLEO_LOGO_URL'].presence
    config.x.asembleo.default_from = ENV['ASEMBLEO_DEFAULT_FROM'].presence || 'asembleo@example.com'

    # Theme
    config.x.asembleo.primary_color = ENV['ASEMBLEO_PRIMARY_COLOR'].presence || '#0d6efd'
    config.x.asembleo.secondary_color = ENV['ASEMBLEO_SECONDARY_COLOR'].presence || '#6c757d'
    config.x.asembleo.header_background_color = ENV['ASEMBLEO_HEADER_BACKGROUND_COLOR'].presence || '#212529'
    config.x.asembleo.header_color = ENV['ASEMBLEO_HEADER_COLOR'].presence || '#ffffff'
    config.x.asembleo.footer_background_color = ENV['ASEMBLEO_FOOTER_BACKGROUND_COLOR'].presence || '#f8f9fa'
    config.x.asembleo.footer_color = ENV['ASEMBLEO_FOOTER_COLOR'].presence || '#6c757d'
    config.x.asembleo.background_css = ENV['ASEMBLEO_BACKGROUND_CSS'].presence

    config.action_mailer.default_url_options = { host: 'example.com' }
    routes.default_url_options = config.action_mailer.default_url_options

    config.i18n.default_locale = ENV['LOCALE'].presence || :en
    config.i18n.available_locales = [:en, :es, :ca, :lb, 'nb-NO', :pl]
  end
end
