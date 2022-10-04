# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

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
    config.x.asembleo.public_instance = ENV['ASEMBLEO_PUBLIC_INSTANCE'].present?
    config.x.asembleo.token_alias = ENV['ASEMBLEO_TOKEN_ALIAS'].presence
    config.x.asembleo.async_vote = ActiveModel::Type::Boolean.new.cast(ENV['ASEMBLEO_ASYNC_VOTE'].presence) || false
    
    # Branding
    config.x.asembleo.title = ENV['ASEMBLEO_TITLE'].presence || 'Asembleo'
    config.x.asembleo.footer = ENV['ASEMBLEO_FOOTER'].presence || 'Asembleo is a free software project developed by Coopanio'
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
  end
end
