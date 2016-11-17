class AddEditionToReferences < ActiveRecord::Migration[5.0]
  def change
	add_column :articles, :edition, :integer
  end
end
