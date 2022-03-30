# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.0'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'cssbundling-rails', '~> 1.0'
gem 'hashids'
gem 'hiredis'
gem 'interactor', '~> 3.0'
gem 'jbuilder', '~> 2.7'
gem 'jsbundling-rails', '~> 1.0'
gem 'paper_trail'
gem 'puma', '~> 5.6'
gem 'pundit'
gem 'rails', '~> 7.0'
gem 'redis'
gem 'sentry-rails'
gem 'sentry-ruby'
gem 'sprockets-rails'
gem 'store_model'

group :production do
  gem 'connection_pool'
  gem 'pg'
  gem 'sucker_punch'
end

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'pry-rails'
  gem 'sqlite3', '~> 1.4'
end

group :development do
  gem 'listen', '~> 3.2'
  gem 'rubocop', require: false
  gem 'rubocop-minitest', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'web-console', '~> 4.2'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'factory_bot'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'minitest-stub_any_instance'
  gem 'policy-assertions'
  gem 'selenium-webdriver'
  gem 'timecop'
  gem 'webdrivers'
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
