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
    @category = Category.new(category_params)
    if @category.save
      flash[:notice_category] = 'Categoria Registrada com Sucesso.'
      redirect_to '/dashboard/categories/new'

    end

  end

  def edit_article_post
    article = Article.find(edit_article_params['id'])
    cats = []
    edit_article_params['categories'].each do |cat|
      if not cat.blank?
        cats.append(Category.find(cat))
      end
    end
    article.update(title: edit_article_params['title'],
                   author: edit_article_params['author'],
                   magazine: edit_article_params['magazine'],
                   year: edit_article_params['year'],
                   link: edit_article_params['link'],
                   issue: edit_article_params['issue'],
                   vol_number: edit_article_params['vol_number'],
                   first_page: edit_article_params['first_page'],
                   last_page: edit_article_params['last_page'],
                   translator: edit_article_params['translator'],
                   categories: cats)
    article.save
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
        if article.save
          message = 'Artigo removido com sucesso.'
        else
          message = 'Não foi possível remover o artigo.'
        end

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

  def category_params
    params.require(:category).permit(:name, :description)
  end

  def edit_article_params
    params.require(:article).permit(:author, :title, :year, :magazine, :vol_number, :translator, :active, :times_visited, :link, :article_type, :pub_company, :pub_company_city, :inside, :edition, :first_page, :last_page, :issue, :keywords, :id, :categories => [])
  end


end
