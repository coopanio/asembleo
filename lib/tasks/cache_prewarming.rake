# frozen_string_literal: true

namespace :assemblea do
  task cache_prewarming: :environment do
    Token.all.each do |token|
      Rails.cache.fetch("tokens/hash:#{token.to_hash}") do
        token
      end
      Rails.cache.fetch("tokens/id:#{token.id}") do
        token
      end
      Rails.cache.fetch("tokens/consultation:#{token.id}") do
        token.consultation
      end
    end
  end
end
