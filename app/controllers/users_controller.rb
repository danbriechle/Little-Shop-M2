class UsersController < ApplicationController
  def index
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to profile_path
      flash[:success] = "You are now registered and logged in."
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :street, :city, :state, :zip, :email, :password)
  end
end
