class AddGiftArrayToRecipients < ActiveRecord::Migration[6.1]
  def change
    change_column :recipients, :gift, :text, array: true, default: [], using: "(string_to_array(gift, ','))"
  end
end
