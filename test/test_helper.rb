# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  if ENV['CI'].present?
    require 'simplecov-lcov'

    SimpleCov::Formatter::LcovFormatter.config do |c|
      c.report_with_single_file = true
      c.single_report_path = 'coverage/lcov.info'
    end

    formatter SimpleCov::Formatter::LcovFormatter
  end

  add_filter %w[version.rb initializer.rb]
end

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'policy_assertions'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    include FactoryBot::Syntax::Methods

    def self.subject(&)
      define_method(:subject) do
        @subject ||= instance_eval(&)
      end
    end
  end
end
