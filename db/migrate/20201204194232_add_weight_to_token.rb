# frozen_string_literal: true

class AddWeightToToken < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :weight, :decimal, default: 1.0
  end
end
