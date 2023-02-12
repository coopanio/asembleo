# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'policy_assertions'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    parallelize_teardown do |worker|
      SimpleCov.result
    end

    fixtures :all

    include FactoryBot::Syntax::Methods

    def self.subject(&)
      define_method(:subject) do
        @subject ||= instance_eval(&)
      end
    end
  end
end
