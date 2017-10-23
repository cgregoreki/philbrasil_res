Rails.application.routes.draw do

  # devise_for :users
  devise_for :users, controllers: {
      sessions: 'user/sessions'
  }

  resources :articles do
    post 'access'
    post 'report'
    post 'report_submit'
  end

  root to: 'application#home'

  authenticate :user do
    get 'dashboard', to: 'dashboard#index', as: :user_root
  end

  resources :categories, only: [:index, :show]

  get 'search', to: 'articles#search'
  get 'sobre', to: 'application#about'
  get 'colabore', to: 'application#collaborate'
  get 'atualizacoes', to: 'application#updates'
  get 'advanced-search', to: 'application#advanced_search'
  get 'magazines', to: 'application#magazines'
  get 'blog', to: 'application#blog'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get 'contact', to: 'contacts#new', as: 'contact' # contact_path returns contacts.new
  post 'contact', to: 'contacts#create'
end
