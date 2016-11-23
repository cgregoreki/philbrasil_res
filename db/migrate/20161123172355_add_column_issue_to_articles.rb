class AddColumnIssueToArticles < ActiveRecord::Migration[5.0]
  def change
	add_column :articles, :issue, :string
  end
end
