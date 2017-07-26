require 'articles_dao.rb'

# class that uses the DAO methods and properties to clean data, 
# treat Daos exceptions, make proper calculations related to the business
# logic
class ArticlesService

    attr_accessor :articles_dao

    def initialize(articles_dao_in)
        @articles_dao = articles_dao_in
    end


    # Returns the article specified by an id
    # Params:
    # +article_id+:: the article id
    def get_article_by_id(article_id)
        article = @articles_dao.find_article_by_id(article_id)
        return article
    end

    def save_or_update_article(article)
        if article.nil? 
            return nil
        end
        return @articles_dao.save_article(article) ? @articles_dao.find_article_by_id(article.id) : nil
    end


    def access_article(article_id)
        article = @articles_dao.find_article_by_id(article_id)
        
        if article.times_visited.nil? 
            article.times_visited = 0
        end
        article.times_visited += 1
        return @articles_dao.save_article(article)
    end


    def save_new_report_bad_article(report_bad_article)

        return report_bad_article.save ? true : false

    end

    # Returns a list of articles to be handled by the view
    # Params:
    # +search_words+:: the input string with words to search
    def get_articles_by_word_relevance(search_words)

        # if the string is empty or null, return nothing.
        if search_words == nil or search_words.empty?
            return [], []
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