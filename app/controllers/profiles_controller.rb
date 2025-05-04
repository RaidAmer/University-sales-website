class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user

    # Load all checkout orders with their line items and products, most recent first
    @checkout_orders = @user.checkout_orders
                            .includes(order_items: :product)
                            .order(created_at: :desc)

    # Load the last 10 reviews for the user's orders, if you have a Review model
    @recent_reviews = ::Review.joins(:checkout_order)
                            .where(checkout_orders: { user_id: @user.id })
                            .order(created_at: :desc)
                            .limit(10)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      Rails.logger.debug "Avatar attached: #{@user.avatar.attached?}"
      Rails.logger.debug "Banner attached: #{@user.banner.attached?}"
      redirect_to profile_path, notice: "Profile updated successfully!"
    else
      render :edit, alert: "Please fix the errors."
    end
  end

  private

  def profile_params
    params.require(:user).permit(:bio, :avatar, :banner, :first_name, :last_name, :location, :role, :email, :theme)
  end
end
