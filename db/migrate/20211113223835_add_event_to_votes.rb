class AddEventToVotes < ActiveRecord::Migration[6.1]
  def change
    add_reference :votes, :event, foreign_key: true
  end
end
