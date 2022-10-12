# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :identifier
      t.string :password_digest
      t.integer :role

      t.timestamps
    end
  end
end
