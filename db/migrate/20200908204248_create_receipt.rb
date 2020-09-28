# frozen_string_literal: true

class CreateReceipt < ActiveRecord::Migration[6.0]
  def change
    create_table :receipts do |t|
      t.text :fingerprint
      t.references :token, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.timestamps
    end
  end
end
