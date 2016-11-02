class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def home

  end

  def about

  end

  def collaborate
  end

  def updates
  	@last_submissions = Article.all.order(created_at: :desc).limit(50)
  end
  
end
