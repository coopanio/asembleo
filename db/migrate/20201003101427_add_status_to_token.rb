class AddStatusToToken < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :status, :integer, default: 1
  end
end
