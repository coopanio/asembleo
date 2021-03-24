# frozen_string_literal: true

namespace :assemblea do
  task token_cache_prewarming: :environment do
    Token.all.each do |token|
      Rails.cache.fetch("tokens/#{token.to_hash}") do
        token
      end
    end
  end
end
