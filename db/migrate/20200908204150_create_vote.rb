# frozen_string_literal: true

class CreateVote < ActiveRecord::Migration[6.0]
  def change
    create_table :votes do |t|
      t.string :value
      t.text :fingerprint
      t.references :question, null: false, foreign_key: true
      t.timestamps
    end
  end
end
