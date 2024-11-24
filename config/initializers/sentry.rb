# frozen_string_literal: true

SentryApi.configure do |config|
  config.endpoint = ENV['SENTRY_API_ENDPOINT']
  config.auth_token = ENV['SENTRY_API_AUTH_TOKEN']
  config.default_org_slug = ENV['SENTRY_ORGANIZATION_SLUG']
end

return unless Rails.env.production?

Sentry.init do |config|
  # TODO: at some point we need to parameterize this
  # See https://github.com/getsentry/sentry-docs/pull/1723#issuecomment-773479895
  config.dsn = 'https://68a7ebc66a2a477298509ded6f382ca4@o390133.ingest.sentry.io/5449641'
  config.breadcrumbs_logger = %i[active_support_logger http_logger]
  config.enabled_environments = %w[production]
  config.traces_sample_rate = 1.0

  config.before_send do |event, _hint|
    event.tags[:domain] = ENV['ASEMBLEO_HOST']
    event
  end
end
