class DashboardController < ApplicationController
    layout 'dashboard'

    def index
    	if !current_user
    		redirect_to new_user_session_path, notice: 'Você não está logado.'
    	end
    end

  def complete_profile

  end
end
