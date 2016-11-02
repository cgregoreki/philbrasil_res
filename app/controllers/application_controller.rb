class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home
    @active_menu = "home"
  end

  def about
    @active_menu = "about"
  end

  def collaborate
    @active_menu = "collaborate"
  end

  def updates
    @active_menu = "updates"
  	@last_submissions = Article.all.order(created_at: :desc).limit(50)
  end
  
end
