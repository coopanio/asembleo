class AddOnBehalfOfToTokens < ActiveRecord::Migration[6.1]
  def change
    add_column :tokens, :on_behalf_of, :string
  end
end
