# frozen_string_literal: true

class RenamePrincipalToMainInOptions < ActiveRecord::Migration[7.0]
  def change
    rename_column :options, :principal, :main
  end
end
