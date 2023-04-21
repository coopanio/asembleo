# frozen_string_literal: true

class AddVoterToReceipts < ActiveRecord::Migration[7.0]
  def change
    add_reference :receipts, :voter, polymorphic: true, null: true
  end
end
