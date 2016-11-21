class CategoriesController < ApplicationController
	  before_action :set_category, only: [:show]

	  def index
	  	@active_page_title = 'Categorias'
	  	@active_menu = 'categories'
		@all_categories = Category.all
		@all_categories_groups_of_2 = @all_categories.in_groups_of(2)

	end

	def show
		@active_page_title = @category.name
		@active_menu = 'categories'
	end

	  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end



end
