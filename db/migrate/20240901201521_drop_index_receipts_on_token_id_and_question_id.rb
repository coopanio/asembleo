class DropIndexReceiptsOnTokenIdAndQuestionId < ActiveRecord::Migration[7.0]
  def change
    remove_index :receipts, name: "index_receipts_on_token_id_and_question_id"
  end
end
