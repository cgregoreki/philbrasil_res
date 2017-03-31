class ArticlesFacade

    
    attr_accessor :articles_service


    def initialize
        @articles_service = ArticlesService.new
    end


    # Returns a prepared list of articles to be handled by the view
    # Params:
    # +user_search_inputs+:: the input string with words to search
    def get_sorted_relevant_articles(search_inputs)
        articles_list, words_list = @articles_service.get_articles_by_word_relevance(search_inputs)

        # calculate the revelance
        relevance_hash = calculate_relevance(articles_list, words_list)

        # transform relevance_hash into a list sorted list of articles
        # sorted by it's relevance
        sorted_hash_list = relevance_hash.sort_by { |article, relevance| relevance }.reverse!
        @sorted_list = []
        sorted_hash_list.each do |elem|
            @sorted_list.append(elem.first)
        end
        @sorted_list
    end


private 


    # Returns a hash that contains the level of relevance of articles.
    # Params:
    # +articles_list+:: the list of articles
    # +words_list+:: the list of words to calculate relevance
    def calculate_relevance(articles_list, words_list)
        # the schema for relevance: if any of the words in the list of words
        # is found in any of the fields of the article object, counts +1 for 
        # it's relevance. For title and author, count +2. The times_visited
        # field of the articles does count too with the following formula:
        # 
        # times_visited_relevance = ((x/n)*100) / 5 -> roundup int
        #
        # where x stands for times_visited and n stands for the sum of all 
        # articles clicks (sum of all times_visited for all articles).
        # The final result for the relevance shall be:
        #
        # article_relevance = times_visited_relevance + word_count + (x/73n)
        #
        @relevance_hash = {}
        puts words_list
        n = @articles_service.get_total_clicks_for_all_articles()
        articles_list.each do |article|
            word_count = 0
            words_list.each do |word|
                word_count = word_count + count_em(article.title, word)*2 + count_em(article.author, word)*2 + 
                    count_em(article.magazine, word) + count_em(article.translator, word) + 
                    count_em(article.link, word) + count_em(article.pub_company, word) +
                    count_em(article.pub_company_city, word) + count_em(article.inside, word) +
                    count_em(article.keywords, word)
            end

            # do not divide by zero
            n = 1 if n.nil? or n == 0

            # do not operate with a nil value
            x = article.times_visited.nil? ? 0 : article.times_visited
            times_visited_relevance = (((x/n)*100)/5).round

            # sum 0.0 to get a float
            article_relevance = 0.0 + times_visited_relevance + word_count + (x/(73*n))
            @relevance_hash[article] = article_relevance
        end
        @relevance_hash
    end


    # Returns the number of ocurrences of a substring in a string
    # Params:
    # +string+:: the string to search in
    # +substring+:: the string to search for
    def count_em(string, substring)
        if string.nil? or substring.nil? then
            return 0
        end

        word_count = string.each_char.each_cons(substring.size).map(&:join).count(substring)
        return word_count
    end

end