require 'articles_dao.rb'

class ArticlesService

    attr_accessor :articles_dao

    def initialize
        @articles_dao = ArticlesDao.new
    end

    # Returns a list of articles to be handled by the view
    # Params:
    # +search_words+:: the input string with words to search
    def get_articles_by_word_relevance(search_words)

        # if the string is empty or null, return nothing.
        if search_words == nil or search_words.empty?
            return []
        end

        words_list = search_words.split
        @articles_list = []
        begin
            # execute the search from the DAO
            @articles_list = @articles_dao.find_articles_by_relevant_text_fields(words_list)	
            return @articles_list.uniq, words_list
        rescue Exception => ex
            puts ex
            return Array([]), words_list
        end
    end

    # Returns the total sum of all articles access.
    def get_total_clicks_for_all_articles()
        return @articles_dao.get_total_clicks_for_all_articles()
    end
end