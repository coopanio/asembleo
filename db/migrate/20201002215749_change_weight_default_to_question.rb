class ChangeWeightDefaultToQuestion < ActiveRecord::Migration[6.0]
  def change
    change_column_default :questions, :weight, from: nil, to: 0
  end
end
