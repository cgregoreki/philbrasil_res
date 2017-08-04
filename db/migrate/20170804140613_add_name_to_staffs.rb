class AddNameToStaffs < ActiveRecord::Migration[5.0]
  def change
	add_column :staffs, :name, :string
  end
end
