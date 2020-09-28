# frozen_string_literal: true

class AddUniqueIndexToReceipts < ActiveRecord::Migration[6.0]
  def change
    add_index :receipts, %i[token_id question_id], unique: true
  end
end
