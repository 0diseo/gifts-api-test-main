class ChangeColumnSchoolAdressToAddress < ActiveRecord::Migration[6.1]
  def change
    rename_column :schools, :adress, :address
  end
end
