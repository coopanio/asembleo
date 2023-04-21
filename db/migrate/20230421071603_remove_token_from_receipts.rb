# frozen_string_literal: true

class RemoveTokenFromReceipts < ActiveRecord::Migration[7.0]
  def change
    remove_reference :receipts, :token, null: false, foreign_key: true
  end
end
