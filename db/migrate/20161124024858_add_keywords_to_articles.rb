class AddKeywordsToArticles < ActiveRecord::Migration[5.0]
  def change
  	add_column :articles, :keywords, :text
  end
end
