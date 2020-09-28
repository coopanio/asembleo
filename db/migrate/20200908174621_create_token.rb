# frozen_string_literal: true

class CreateToken < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens do |t|
      t.integer :role, default: 0
      t.integer :salt
      t.references :consultation, null: false, foreign_key: true
      t.references :event, null: true, foreign_key: true
      t.timestamps
    end
  end
end
