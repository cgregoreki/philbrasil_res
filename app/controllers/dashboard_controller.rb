class DashboardController < ApplicationController
  layout 'dashboard'


  def index
    if !current_user
      redirect_to new_user_session_path, notice: 'Você não está logado.'
    end

    @n_uncategorized_articles = get_articles_facade.get_N_uncategorized_articles(PHILBRASIL_CONFIG['dashboard']['n_uncategorized_articles'])
    @last_N_registered_articles = get_articles_facade.get_last_N_registered_articles(PHILBRASIL_CONFIG['dashboard']['n_last_registered_articles'])
    @n_reported_unresolved_articles = get_articles_facade.get_N_unresolved_articles(PHILBRASIL_CONFIG['dashboard']['n_last_unresolved_articles'])
    @all_categories = get_categories_facade.get_all_categories()


    @total_number_of_articles = get_articles_facade.get_total_number_of_articles
    @total_number_of_classified_articles = get_articles_facade.get_total_number_of_classified_articles
    @total_number_of_reported_articles = get_articles_facade.get_total_number_of_reported_articles
    @total_number_of_reported_and_unresolved_articles = get_articles_facade.get_total_number_of_reported_and_unresolved_articles

    @article = Article.new
  end

  def category_new
    @category = Category.new
  end

  def category_create
    puts 'HAHAHHAHHAH'
  end

  def delete_article
    @delete_response = Hash.new

    article_id = params['pb-js-id']
    if article_id.nil?
      puts 'ops!'
      @delete_response['status'] = 'error'
      @delete_response['message'] = 'id was null!'
    else
      begin
        article = Article.find(article_id)
        article.active = false
        article.save

        message = 'Artigo removido com sucesso.'

        case params['pb-js-type']
          when 'lnra'
            flash[:notice_last_n_registered_articles] = message
          when 'clua'
            flash[:notice_classify_articles] = message
          when 'reba'
            flash[:notice_report_bad_articles] = message
        end

        @delete_response['status'] = 'success'
        @delete_response['message'] = 'success'
      rescue
        @delete_response['status'] = 'error'
        @delete_response['message'] = 'could not delete! could not find!'
      end
    end

    respond_to do |format|
      format.json {render json: @delete_response}
    end
  end

  private

  def get_articles_facade
    if @articles_facade.nil?
      return ArticlesFacade.new(ArticlesService.new(ArticlesDao.new))
    end
    return @articles_facade
  end

  def get_categories_facade
    if @categories_facade.nil?
      return CategoriesFacade.new(CategoriesService.new(CategoriesDao.new))
    end
    return @categories_facade
  end


end
