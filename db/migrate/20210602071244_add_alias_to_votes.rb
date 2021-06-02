class AddAliasToVotes < ActiveRecord::Migration[6.1]
  def change
    add_column :votes, :alias, :string
  end
end
