class CreateArticles < ActiveRecord::Migration[5.0]
  def change
    create_table :articles do |t|
      t.string :author
      t.string :title
      t.integer :year
      t.string :magazine
      t.float :vol_number
      t.string :translator
      t.boolean :active
      t.integer :times_visited
      t.text :link
      t.string :article_type
      t.string :pub_company
      t.string :pub_company_city
      t.string :inside

      t.timestamps
    end
  end
end
