# frozen_string_literal: true

Rails.application.configure do
  config.hash_service = ActiveSupport::OrderedOptions.new
  config.hash_service.hash_length = 8
  config.hash_service.alphabet = '0123456789abcdefghjklmnpqrtvwxyz'
end
