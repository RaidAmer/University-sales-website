class AdminController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_admin
  
    def users
      @pending_users = User.where(approved: false)
    end
  
    def approve
      user = User.find(params[:id])
      user.update(approved: true)
      redirect_to admin_users_path, notice: "#{user.first_name} has been approved!"
    end
  
    private
  
    def ensure_admin
      unless current_user && current_user.email == "admin@example.com"
        redirect_to root_path, alert: "Access denied."
      end
    end
  end
  