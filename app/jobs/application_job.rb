# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on SQLite3::BusyException, wait: :polynomially_longer if defined?(SQLite3)
end
