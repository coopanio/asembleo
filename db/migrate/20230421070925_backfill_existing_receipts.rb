# frozen_string_literal: true

class BackfillExistingReceipts < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    Receipt.unscoped.in_batches do |batch|
      batch.update_all(voter_type: 'Token', voter_id: Arel.sql('token_id'))
    end
  end
end
