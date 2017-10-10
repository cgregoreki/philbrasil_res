Rails.application.routes.draw do

	resources :articles do
	 	post 'access'
	
	 	post 'report'
	 	post 'report_submit'
	end

	root 'application#home'
	# authenticate :staff do
		get 'dashboard', to: "dashboard#index"
	# end
	resources :categories, only: [:index, :show]
	
	get 'search', to: "articles#search"
	get 'sobre', to: "application#about"
	get 'colabore', to: "application#collaborate"
	get 'atualizacoes', to: "application#updates"
	get 'advanced-search', to: "application#advanced_search"
	get 'magazines', to: "application#magazines"
	get 'blog', to: "application#blog"
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	get 'contact', to: 'contacts#new', as: 'contact' # contact_path returns contacts.new
	post 'contact', to: 'contacts#create'
end
