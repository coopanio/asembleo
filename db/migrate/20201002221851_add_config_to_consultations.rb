# frozen_string_literal: true

class AddConfigToConsultations < ActiveRecord::Migration[6.0]
  def change
    add_column :consultations, :config, :json, default: {}
  end
end
