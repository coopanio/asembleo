# frozen_string_literal: true

class RemoveWeightFromQuestions < ActiveRecord::Migration[6.1]
  def change
    remove_column :questions, :weight
  end
end
