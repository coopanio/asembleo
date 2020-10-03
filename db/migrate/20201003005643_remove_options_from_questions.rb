# frozen_string_literal: true

class RemoveOptionsFromQuestions < ActiveRecord::Migration[6.0]
  def change
    remove_column :questions, :options, :json
  end
end
