class CategoryController < ApplicationController
  def index
    @categorys = Category.all
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
      redirect_to categorys_url
    else
      flash.now[:error] = 'Category Creation failed'
      render :new, status: :unprocessable_entity
    end
  end
end
