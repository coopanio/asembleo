# frozen_string_literal: true

class Question < ApplicationRecord
  has_paper_trail

  belongs_to :consultation
  has_many :options, dependent: :destroy
  has_many :receipts, dependent: :destroy
  has_many :votes, dependent: :destroy

  enum status: { draft: 0, opened: 1, closed: 2 }

  after_save :invalidate_cache

  def valid_option?(value)
    options.exists?(value:)
  end

  def voted?(token)
    receipts.exists?(token:)
  end

  def position
    weight + 1
  end

  def tally
    results = {}

    votes.each do |vote|
      result = results[vote.value] || 0
      results[vote.value] = result + (1 * vote.weight)
    end

    results['_meta'] = {
      'total_votes' => results.values.sum
    }
    results
  end

  private

  def invalidate_cache
    Rails.cache.delete("questions:#{id}")
  end
end
