# frozen_string_literal: true

class CreateOptions < ActiveRecord::Migration[6.0]
  def change
    create_table :options do |t|
      t.string :value
      t.string :description
      t.references :question, null: false, foreign_key: true
    end
  end
end
