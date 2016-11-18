class Category < ApplicationRecord
	 
   	    has_and_belongs_to_many :parents, :class_name=>'Category', :join_table => "categories_relationships", :foreign_key => :related_category_id, :association_foreign_key => :category_id
  		has_and_belongs_to_many :children, :class_name=>'Category', :join_table => "categories_relationships", :foreign_key => :category_id, :association_foreign_key => :related_category_id
  		has_and_belongs_to_many :articles, :class_name=>'Article', :join_table => "article_categories", :foreign_key => :category_id, :association_foreign_key => :article_id  		
end
