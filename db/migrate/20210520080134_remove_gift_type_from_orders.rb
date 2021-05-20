class RemoveGiftTypeFromOrders < ActiveRecord::Migration[6.1]
  def change
    remove_column :orders, :gift_type
  end
end
