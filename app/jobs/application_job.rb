# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  retry_on SQLite3::BusyException, wait: :exponentially_longer
end
