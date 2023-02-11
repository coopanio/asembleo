# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

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
