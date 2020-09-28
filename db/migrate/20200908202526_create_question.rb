# frozen_string_literal: true

class CreateQuestion < ActiveRecord::Migration[6.0]
  def change
    create_table :questions do |t|
      t.text :description
      t.json :options
      t.integer :status, default: 0
      t.integer :weight
      t.references :consultation, null: false, foreign_key: true
      t.timestamps
    end
  end
end
