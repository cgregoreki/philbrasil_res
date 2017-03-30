class ArticlesFacade

    # Returns a prepared list of articles to be handled by the view
    # Params:
    # +user_search_inputs+:: the input string with words to search
    def get_cleaned_relevant_articles(search_inputs)
        service = ArticlesService.new
        articles_list = service.get_articles_by_word_relevance(search_inputs)
    end
end