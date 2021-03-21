# frozen_string_literal: true

class AddWeightToVote < ActiveRecord::Migration[6.0]
  def change
    add_column :votes, :weight, :decimal
  end
end
