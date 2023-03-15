# frozen_string_literal: true

class ChangeConsultationIdAsNullableInTokens < ActiveRecord::Migration[7.0]
  def change
    change_column_null :tokens, :consultation_id, true
  end
end
