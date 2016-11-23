class DropPageNumberColumnFromArticles < ActiveRecord::Migration[5.0]
  def change
	remove_column :articles, :page_number
	add_column :articles, :first_page, :integer
	add_column :articles, :last_page, :integer
  end
end
