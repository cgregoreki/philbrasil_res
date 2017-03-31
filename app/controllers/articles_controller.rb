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
  end

  # GET /articles/new
  def new
    @active_page_title = "Inserir Referência"
    @article = Article.new
    @all_categories = Category.all
  end

  # GET /articles/1/edit
  def edit
    render status: :forbidden, text: "You do not have access to this page."
  end

  # POST /articles
  # POST /articles.json
  def create
    @active_page_title = "Inserir Referência"
    @article = Article.new(article_params)
    selected_categories_params = params['selected_categories']
    selected_categories_params.each do |sc|
      @article.categories.append(Category.find(sc.to_i))
    end

    respond_to do |format|
      if @article.save
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
    end

    facade = ArticlesFacade.new(ArticlesService.new(ArticlesDao.new))
    @articles = facade.get_sorted_relevant_articles(search_string)
  end

  def access
    facade = ArticlesFacade.new(ArticlesService.new(ArticlesDao.new))
    @article = facade.access_article(params[:article_id])
    # @article = Article.find(params[:article_id])
    # if @article.times_visited == nil then
    #   @article.times_visited = 0
    # end
    # @article.times_visited = @article.times_visited + 1;
    # @article.save

    if @article.link.include? "http://"
      redirect_to @article.link
    else
      redirect_to "http://" + @article.link
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
end
