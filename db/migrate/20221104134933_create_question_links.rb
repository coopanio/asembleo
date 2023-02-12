# frozen_string_literal: true

class CreateQuestionLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :question_links do |t|
      t.references :question, null: false, foreign_key: true
      t.references :question_group, null: false, foreign_key: true

      t.timestamps
    end
  end
end
