# frozen_string_literal: true

return unless Rails.env.production?

Sentry.init do |config|
  # TODO: at some point we need to parameterize this
  # See https://github.com/getsentry/sentry-docs/pull/1723#issuecomment-773479895
  config.dsn = 'https://68a7ebc66a2a477298509ded6f382ca4@o390133.ingest.sentry.io/5449641'
  config.enabled_environments = %w[production]
end
