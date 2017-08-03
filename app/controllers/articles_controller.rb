class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  # GET /articles
  # GET /articles.json
  def index
    render status: :forbidden, text: "You do not have access to this page."
    # @articles = Article.all
  end

  # GET /articles/1
  # GET /articles/1.json
  def show
    @active_page_title = @article.title + " - " + @article.author

    render layout: "search", template: "articles/show"

  end

  # GET /articles/new
  def new
    @active_page_title = "Inserir Referência"
    @article = Article.new
    @categories_facade = get_categories_facade
    @all_categories = @categories_facade.get_all_categories()

    render template: "articles/new"
  end

  # GET /articles/1/edit
  def edit
    render status: :forbidden, text: "You do not have access to this page."
  end

  # POST /articles
  # POST /articles.json
  def create
    @active_page_title = "Inserir Referência"
    @articles_facade = get_articles_facade
    selected_categories_params = params['selected_categories']
    
    @article = @articles_facade.save_new_article_with_categories(article_params, selected_categories_params)

    # @article = Article.new(article_params)
    
    # selected_categories_params.each do |sc|
    #   @article.categories.append(Category.find(sc.to_i))
    # end

    respond_to do |format|
      if not @article.nil?
        format.html { redirect_to @article, notice: 'Referência incluída com sucesso.' }
        format.json { render :show, status: :created, location: @article }
      else
        format.html { render :new }
        format.json { render json: @article.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /articles/1
  # PATCH/PUT /articles/1.json
  def update

    render status: :forbidden, text: "You do not have access to this page."

    # respond_to do |format|
    #   if @article.update(article_params)
    #     format.html { redirect_to @article, notice: 'Article was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @article }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @article.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /articles/1
  # DELETE /articles/1.json
  def destroy
    render status: :forbidden, text: "You do not have access to this page."

    # @article.destroy
    # respond_to do |format|
    #   format.html { redirect_to articles_url, notice: 'Article was successfully destroyed.' }
    #   format.json { head :no_content }
    # end

  end


  # receives user inputs for a search and executes it.
  def search
    @active_page_title = "Pesquisar"
    search_string = params[:search]
    
    if search_string.length < 1 then
      redirect_to "/"
      return
    end

    @articles_facade = get_articles_facade
    @articles = @articles_facade.get_sorted_relevant_articles(search_string)

    render template: "articles/search"

  end

  def access
    @articles_facade = get_articles_facade
    @article = @articles_facade.access_article(params[:article_id])

    if @article.link.include? "http://"
      redirect_to @article.link
      return
    else
      redirect_to "http://" + @article.link
      return
    end
  end

  def report

    @articles_facade = get_articles_facade

    article = @articles_facade.access_article(params[:article_id])

    @report_bad_article = ReportBadArticle.new
    @report_bad_article.article = article
  
    render template: "articles/report"    
  end

  def report_submit 
    @articles_facade = get_articles_facade
    @article = @articles_facade.access_article(params[:article_id])
    reason = params[:reason]

    if not reason.blank? 
      if @articles_facade.save_article_report(@article.id, reason)
        
        flash[:info] = "Seu report foi salvo com sucesso."
        redirect_to article_path(@article.id.to_s)
      end

    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:author, :title, :year, :magazine, :vol_number, :translator, :active, :times_visited, :link, :article_type, :pub_company, :pub_company_city, :inside, :edition, :selected_categories, :first_page, :last_page, :issue, :keywords)
    end

    # ------------------------
    # Construct facades only if they are nil

    def get_categories_facade
      if @categories_facade.nil? 
        return CategoriesFacade.new(CategoriesService.new(CategoriesDao.new))
      end
      return @categories_facade
    end

    def get_articles_facade
      if @articles_facade.nil?
        return ArticlesFacade.new(ArticlesService.new(ArticlesDao.new))
      end
      return @articles_facade
    end

    # ------------------------

end