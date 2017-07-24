class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    @active_menu = "home"
    @active_page_title = "Home"

    render layout: "home", template: "application/home"
  end

  def about
    @active_menu = "about"
    @active_page_title = "Sobre"

    render layout: "about", template: "application/about"

  end

  def collaborate
    @active_menu = "collaborate"
    @active_page_title = "Colabore"

    render layout: "collaborate", template: "application/collaborate"

  end

  def updates
    @active_menu = "updates"
    @active_page_title = "Atualizações"
  	@last_submissions = Article.all.order(created_at: :desc).limit(50)
  end
  
end
