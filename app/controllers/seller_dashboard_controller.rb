class SellerDashboardController < ApplicationController
  def index
    @user = current_user
    @products = @user.products
    render :index
  end

  def show
    @user = current_user
    @product = @user.products.find(params[:id])
    render :show
  end

end
