# frozen_string_literal: true

class Consultation < ApplicationRecord
  has_paper_trail

  class Config
    include StoreModel::Model
    include TranslateStoreModel

    enum :mode, %i[synchronous asynchronous], default: :synchronous
    enum :ballot, %i[open secret], default: :secret
    enum :distribution, %i[manual email], default: :manual

    translate_enum :mode
    translate_enum :ballot
    translate_enum :distribution
  end

  has_many :events, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :tokens, dependent: :destroy
  has_many :token_receipts, dependent: :destroy

  attribute :config, Config.to_type

  enum status: { draft: 0, opened: 1, closed: 2, archived: 3 }

  translate_enum :status

  delegate :synchronous?, :asynchronous?, to: :config
  delegate :ballot, to: :config

  validates :config, store_model: { merge_errors: true }

  after_update :update_default_event, if: :synchronous?

  def exhausted_for?(token)
    token.receipts.where(question_id: question_ids).count == questions.count
  end

  private

  def update_default_event
    if opened?
      events.first.update!(status: :opened)
    else
      events.first.update!(status: :closed)
    end
  end
end
