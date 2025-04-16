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


  before_action :check_approval

  private
  
  def check_approval
    unless current_user.approved?
      redirect_to root_path, alert: "You must be approved to access this page."
    end
  end
  
end
