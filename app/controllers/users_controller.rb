class UsersController < ApplicationController
<<<<<<< HEAD
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: "Profile updated!"
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end
=======
  def new
    @user = User.new
    render :new
  
  end

  class UsersController < ApplicationController
    def new
      @user = User.new
    end
  
    def create
      @user = User.new(user_params)
  
      if @user.save
        flash[:success] = 'Account created successfully!'
        redirect_to home_path
      else
        flash.now[:error] = 'Account creation failed. Please fix the errors below.'
        render :new, status: :unprocessable_entity
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:first_name, :last_name, :password, :university_id)
    end
  end
  
>>>>>>> main
end
