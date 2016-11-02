Rails.application.routes.draw do

	root 'application#home'
	resources :articles do
		post 'access'
	end
	get 'search', to: "articles#search"
	get 'sobre', to: "application#about"
	get 'colabore', to: "application#collaborate"
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html


  
end
