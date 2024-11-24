class AddNotificationToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :notification, :json, default: {}
  end
end
