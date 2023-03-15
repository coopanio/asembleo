# frozen_string_literal: true

class CreateIdentityReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :identity_receipts do |t|
      t.string :fingerprint
      t.boolean :confirmed
      t.datetime :confirmed_at
      t.boolean :approved
      t.datetime :approved_at
      t.integer :salt

      t.timestamps
    end
  end
end
