# frozen_string_literal: true

class AddPrincipalToOptions < ActiveRecord::Migration[7.0]
  def change
    add_column :options, :principal, :boolean
    change_column_default :options, :principal, false
  end
end
