# frozen_string_literal: true

class CustomerReviewsController < ApplicationController
  def index
    @category = Category.find(params[:category_id])
    @product = Product.find(params[:product_id])
    @reviews = @product.customer_reviews.includes(:user)
    render :index
  end

  def new
    @product = Product.find(params[:product_id])
    @category = @product.category
    @review = CustomerReview.new
    render :new
  end

  def create
    @product = Product.find(params[:product_id])
    @category = @product.category
    @review = @product.customer_reviews.build(params.require(:customer_review).permit(:title, :description, :rating))
    @review.user = current_user

    if @review.save
      flash[:success] = 'Review created successfully!'
      redirect_to category_product_reviews_path(@category, @product)
    else
      flash.now[:error] = 'Review creation failed.'
      render :new, status: :unprocessable_entity
    end
  end
end
