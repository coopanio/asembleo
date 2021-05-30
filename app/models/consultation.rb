# frozen_string_literal: true

class Consultation < ApplicationRecord
  has_paper_trail

  class Config
    include StoreModel::Model

    enum :mode, %i[synchronous asynchronous], default: :synchronous
    enum :ballot, %i[open secret], default: :secret
  end

  has_many :events, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :tokens, dependent: :destroy

  attribute :config, Config.to_type

  enum status: { draft: 0, opened: 1, closed: 2, archived: 3 }

  delegate :synchronous?, :asynchronous?, to: :config
  delegate :ballot, to: :config

  validates :config, store_model: { merge_errors: true }

  after_update :update_default_event, if: :synchronous?
  after_save :invalidate_cache

  private

  def update_default_event
    if opened?
      events.first.update!(status: :opened)
    else
      events.first.update!(status: :closed)
    end
  end

  def invalidate_cache
    Rails.cache.delete("consultations:#{id}")
    Rails.cache.delete_matched("tokens/consultation:*")
  end
end
