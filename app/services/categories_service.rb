class CategoriesService

    attr_accessor :categories_dao


    def initialize(categories_dao_in)
        @categories_dao = categories_dao_in
    end

    def get_all_categories()
        @categories_dao.find_all_categories()
    end
end