# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'policy_assertions'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

    include FactoryBot::Syntax::Methods

    def self.subject(&block)
      define_method(:subject) do
        @subject ||= instance_eval(&block)
      end
    end
  end
end
