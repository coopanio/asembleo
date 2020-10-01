class AddAliasToToken < ActiveRecord::Migration[6.0]
  def change
    add_column :tokens, :alias, :string
  end
end
