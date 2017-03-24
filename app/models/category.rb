# == Schema Information
#
# Table name: categories
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  editor      :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Category < ApplicationRecord
	 
   	    has_and_belongs_to_many :parents, :class_name=>'Category', :join_table => "categories_relationships", :foreign_key => :related_category_id, :association_foreign_key => :category_id
  		has_and_belongs_to_many :children, :class_name=>'Category', :join_table => "categories_relationships", :foreign_key => :category_id, :association_foreign_key => :related_category_id
  		has_and_belongs_to_many :articles, :class_name=>'Article', :join_table => "articles_categories", :foreign_key => :category_id, :association_foreign_key => :article_id  		
end
