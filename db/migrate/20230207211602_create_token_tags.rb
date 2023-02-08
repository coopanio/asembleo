# frozen_string_literal: true

class CreateTokenTags < ActiveRecord::Migration[7.0]
  def change
    create_table :token_tags do |t|
      t.string :value
      t.references :token, null: false, foreign_key: true

      t.timestamps
    end
  end
end
