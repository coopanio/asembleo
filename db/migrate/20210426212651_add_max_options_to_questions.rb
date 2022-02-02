# frozen_string_literal: true

class AddMaxOptionsToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column :questions, :max_options, :integer, default: 1
  end
end
