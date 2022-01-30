# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Asembleo
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.active_job.queue_adapter = :sucker_punch

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.x.asembleo.public_instance = true
    config.x.asembleo.title = 'Asembleo'
    config.x.asembleo.default_from = 'asembleo@coopanio.com'

    config.action_mailer.default_url_options = { host: 'example.com' }
  end
end
