# frozen_string_literal: true

require 'simplecov'

SimpleCov.start 'rails' do
  require 'simplecov-lcov'

  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = 'coverage/lcov.info'
  end

  formatter SimpleCov::Formatter::LcovFormatter
end

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

    parallelize_teardown do
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

class ControllerTestCase < ActionDispatch::IntegrationTest
  private

  attr_reader :token

  def create_admin_token
    create(:token, :admin)
  end

  def create_admin_user
    create(:user, identifier: 'admin@example.com', role: :admin, password: 'notverysafe')
  end

  def login_user
    post sessions_url, params: { session: { identifier: token.identifier, password: 'notverysafe' } }
    assert_predicate session[:identity_id], :present?
  end

  def login_token
    post sessions_url, params: { session: { identifier: token.to_hash } }
    assert_predicate session[:identity_id], :present?
  end
end
