# frozen_string_literal: true

class ProductController < ApplicationController
  def index
    @category = Category.find(params[:category_id])
    @products = @category.products
    render :index
  end

  def show
    @category = Category.find(params[:category_id])
    @product = @category.products.find(params[:id])
    render :show
  end

  def new
    @category = Category.find(params[:category_id])
    @product = Product.new
    render :new
  end

  def create
    @category = Category.find(params[:category_id])
    @product = @category.products.build(params.require(:product).permit(:name, :description, :price, :status, :image))
    if @product.save
      flash[:success] = 'New Product successfully added!'
      redirect_to category_products_url(@category)
    else
      flash.now[:error] = 'Product Creation failed'
      render :new, status: :unprocessable_entity
    end
  end

  before_action :check_approval, only: %i[index show new create]

  def check_approval
    unless user_signed_in?
      redirect_to categories_path, alert: 'You must log in or create an account to view products.'
      return
    end

    return if current_user.approved?

    redirect_to root_path, alert: 'You must be approved to view this product.'
  end
end
