# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.0'

gem 'argon2', '~> 2.2'
gem 'bootsnap', '~> 1.15', require: false
gem 'chartkick', '~> 5.0'
gem 'cssbundling-rails', '~> 1.1'
gem 'email_validator', '~> 2.2'
gem 'hashids', '~> 1.0'
gem 'hiredis', '~> 0.6'
gem 'jsbundling-rails', '~> 1.1'
gem 'nokogiri', '~> 1.14'
gem 'paper_trail', '~> 14.0'
gem 'puma', '~> 6.0'
gem 'pundit', '~> 2.3'
gem 'rails', '~> 7.0'
gem 'rails-i18n', '~> 7.0'
gem 'redis', '~> 5.0'
gem 'sentry-rails', '~> 5.7'
gem 'sentry-ruby', '~> 5.7'
gem 'service_actor', '~> 3.6'
gem 'sprockets-rails', '~> 3.4'
gem 'store_model', '~> 1.3'
gem 'translate_enum', '~> 0.2.0', require: 'translate_enum/active_record'
gem 'translation', '~> 1.35'

group :production do
  gem 'pg', '~> 1.4'
  gem 'sucker_punch', '~> 3.1'
end

group :development, :test do
  gem 'pry-rails', '~> 0.3'
  gem 'sqlite3', '~> 1.5'
end

group :development do
  gem 'listen', '~> 3.7'
  gem 'rubocop', '~> 1.42', require: false
  gem 'rubocop-minitest', '~> 0.25', require: false
  gem 'rubocop-performance', '~> 1.15', require: false
  gem 'rubocop-rails', '~> 2.17', require: false
  gem 'web-console', '~> 4.2'
  gem 'extract_i18n', '~> 0.6'
end

group :test do
  gem 'capybara', '~> 3.38'
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-lcov', '~> 0.8.0'
  gem 'factory_bot', '~> 6.2'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.1'
  gem 'minitest-stub_any_instance', '~> 1.0'
  gem 'policy-assertions', '~> 0.2'
  gem 'selenium-webdriver', '~> 4.7'
  gem 'timecop', '~> 0.9'
  gem 'webdrivers', '~> 5.2'
end
