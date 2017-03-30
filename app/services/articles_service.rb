require 'articles_dao.rb'

class ArticlesService


    # Returns a list of articles to be handled by the view
    # Params:
    # +search_words+:: the input string with words to search
    def get_articles_by_word_relevance(search_words)

        # if the string is empty or null, return nothing.
        if search_words == nil or search_words.empty?
            return nil
        end

        words_list = search_words.split
        begin
            # execute the search from the DAO
            articles_dao = ArticlesDao.new
            @articles_list = articles_dao.find_articles_by_relevant_text_fields(words_list)	
            @articles_list.uniq
        rescue Exception => ex
            return Array([])
        end
    end
end