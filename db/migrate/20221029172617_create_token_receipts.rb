# frozen_string_literal: true

class CreateTokenReceipts < ActiveRecord::Migration[7.0]
  def change
    create_table :token_receipts, id: false do |t|
      t.references :consultation, null: false, foreign_key: true
      t.string :fingerprint, null: false

      t.timestamps
    end

    add_index :token_receipts, %i[fingerprint consultation_id], unique: true
  end
end
