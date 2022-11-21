# frozen_string_literal: true

class AddConfigToQuestionGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :question_groups, :config, :json
    change_column_default :question_groups, :config, {}
  end
end
