class ProductController < ApplicationController

  def index
    @products = Product.all
    render :index
  end

  def show
    @product = Product.find(params[:id])
    render :show
  end
  
  def new
    @product = Product.new
    render :new
  end

  def create
    @product = Product.new(params.require(:product).permit(:name, :description, :price, :status, :image))
    if @product.save
      flash[:success] = 'New Product successfully added!'
      redirect_to products_url
    else
      flash.now[:error] = 'Product Creation failed'
      render :new, status: :unprocessable_entity
    end
  end
end
