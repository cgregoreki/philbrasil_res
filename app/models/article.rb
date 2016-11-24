class Article < ApplicationRecord
	nilify_blanks
	has_and_belongs_to_many :categories, :class_name=>'Category', :join_table => "articles_categories", :foreign_key => :article_id, :association_foreign_key => :category_id

	after_initialize :init

	def init
		self.active = true if self.active.nil?
	end
end
