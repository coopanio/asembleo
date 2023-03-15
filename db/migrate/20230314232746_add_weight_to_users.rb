# frozen_string_literal: true

class AddWeightToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :weight, :decimal, default: 1.0
  end
end
