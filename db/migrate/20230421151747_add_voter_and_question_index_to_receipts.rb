# frozen_string_literal: true

class AddVoterAndQuestionIndexToReceipts < ActiveRecord::Migration[7.0]
  def change
    add_index :receipts, %i[voter_type voter_id question_id], unique: true
  end
end
