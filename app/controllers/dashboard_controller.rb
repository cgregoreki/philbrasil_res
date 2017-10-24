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

  end

  def category_new
    @category = Category.new
  end

  def category_create
    puts 'HAHAHHAHHAH'
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
