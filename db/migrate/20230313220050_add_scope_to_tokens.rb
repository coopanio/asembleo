# frozen_string_literal: true

class AddScopeToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :scope, :integer
    add_column :tokens, :scope_context, :json, default: {}
  end
end
