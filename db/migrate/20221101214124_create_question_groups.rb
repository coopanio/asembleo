# frozen_string_literal: true

class CreateQuestionGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :question_groups do |t|
      t.text :description

      t.timestamps
    end
  end
end
