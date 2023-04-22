# frozen_string_literal: true

class RemoveTokenAndQuestionIndexFromReceipts < ActiveRecord::Migration[7.0]
  def change
    remove_index :receipts, name: 'index_receipts_on_token_id_and_question_id' if index_exists?(:receipts, %i[token_id question_id], name: 'index_receipts_on_token_id_and_question_id')
  end
end
