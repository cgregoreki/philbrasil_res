class CategoriesFacade
     attr_accessor :categories_service


    def initialize(categories_service_in)
        @categories_service = categories_service_in
    end

    def get_all_categories()
        all_categories = @categories_service.get_all_categories()
        if all_categories.nil? 
            return []
        else
            return all_categories
        end
    end
end
