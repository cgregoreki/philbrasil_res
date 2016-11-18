class CreateJoinTableCategoriesRelationships < ActiveRecord::Migration[5.0]
  def change
  	create_table :categories_relationships do |t|
  		t.integer :category_id
  		t.integer :related_category_id
end
  end
end
