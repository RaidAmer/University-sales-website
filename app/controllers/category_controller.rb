class CategoryController < ApplicationController
  def index
    @categories = Category.all
    render :index
  end
  
  def new
    @category = Category.new
    render :new
  end

  def create
    @category = Category.new(params.require(:category).permit(:name, :description, :icon, :is_featured))
    if @category.save
      flash[:success] = 'New Category successfully added!'
      redirect_to categories_url
    else
      flash.now[:error] = 'Category Creation failed'
      render :new, status: :unprocessable_entity
    end
  end
end
