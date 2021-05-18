class CreateRecipients < ActiveRecord::Migration[6.1]
  def change
    create_table :recipients do |t|
      t.references :order
      t.references :user
      t.references :school
      t.string :gift
      t.string :address

      t.timestamps
    end
  end
end
