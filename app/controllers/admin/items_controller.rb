class Admin::ItemsController < ApplicationController
  def index
    @merchant = User.find(params[:merchant_id])
    @items = @merchant.items
    @top_five_items = Item.five_popular('desc')
    @bottom_five_items = Item.five_popular('asc')
  end
  
  def new
    @item = Item.new
    @merchant = User.find(params[:merchant_id])
  end
  
  def create
    @item = Item.new(item_params)
    @item.user_id = params[:merchant_id]
    if @item.save
      flash[:success] = "Your new item has been created"
      redirect_to admin_merchant_items_path
    else
      @errors = @item.errors 
      render :new
    end
  end
  
  def edit
    @item = Item.find(params[:id])
  end
  
  def update
    item = Item.find(params[:id])
    redirect_to admin_merchant_items_path(item.user)
  end
  
  private
  
  def item_params
    params.require(:item).permit(:name, :image_link, :inventory, :description, :current_price)
  end
end