# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = 'https://68a7ebc66a2a477298509ded6f382ca4@o390133.ingest.sentry.io/5449641'
  config.enabled_environments = %w[production]
end
