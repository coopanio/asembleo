class AddConsultationToEventsQuestions < ActiveRecord::Migration[6.0]
  def change
    add_reference :events_questions, :consultation, null: false, foreign_key: true
  end
end
