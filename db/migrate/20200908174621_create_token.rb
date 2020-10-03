# frozen_string_literal: true

class CreateToken < ActiveRecord::Migration[6.0]
  def change
    create_table :tokens do |t|
      t.integer :role, default: 0
      t.integer :salt
      t.timestamps
    end
  end
end
