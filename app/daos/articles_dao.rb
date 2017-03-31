require 'article.rb'
class ArticlesDao

	# Returns a list of articles filtered by many columns with the same input params
	# Params:
	# +search_words_list+:: the list of words to search in each relevant field of articles registry
	def find_articles_by_relevant_text_fields(search_words_list)
		# attention: this method fetches the database n times, where n
		# is the number of words incoming.
		# TODO: rebuild this method so it can builds a query dynamically and execute just one 
		# fetch to the database
		@return_list = []
		search_words_list.each do |word|
			articles = Article.where("author like ? 
				or title like ? 
				or magazine like ?
				or translator like ?
				or keywords like ?
				or pub_company like ?
				or pub_company_city like ?
				or inside like ?
				or link like ?", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%", "%#{word}%").
			where("active = 1")
			
			@return_list.concat(articles)
		end		
		@return_list.uniq
	end

	def get_total_clicks_for_all_articles()
		return Article.sum("times_visited")
	end

end	