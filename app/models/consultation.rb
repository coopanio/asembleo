# frozen_string_literal: true

class Consultation < ApplicationRecord
  has_paper_trail

  class Config
    include StoreModel::Model

    enum :mode, %i[synchronous asynchronous], default: :synchronous
  end

  has_many :events, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :tokens, dependent: :destroy

  attribute :config, Config.to_type

  enum status: { draft: 0, opened: 1, closed: 2, archived: 3 }

  validates :config, store_model: { merge_errors: true }
end
