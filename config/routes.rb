Rails.application.routes.draw do
  resources :articles do
  	post 'access'
  end
  get 'search', to: "articles#search"
  get 'sobre', to: "application#about"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'application#home'
end
