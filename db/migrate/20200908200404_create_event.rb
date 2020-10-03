# frozen_string_literal: true

class CreateEvent < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.integer :status, default: 0
      t.references :consultation, null: false, foreign_key: true
      t.timestamps
    end

    add_reference :tokens, :event, null: true, foreign_key: true
  end
end
