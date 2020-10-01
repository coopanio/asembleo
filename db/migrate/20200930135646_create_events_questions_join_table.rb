# frozen_string_literal: true

class CreateEventsQuestionsJoinTable < ActiveRecord::Migration[6.0]
  def change
    create_table 'events_questions' do |t|
      t.references :event, foreign_key: true
      t.references :question, foreign_key: true
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
