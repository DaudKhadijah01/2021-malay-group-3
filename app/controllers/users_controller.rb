class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new show create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find_by id: params[:id]
    unless @user
      flash[:danger] = t(:user_not_found)
      redirect_to root_path
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = t(:reminder)
      redirect_to @user
    else
      render :new
    end
  end

  def update
    @user = User.find_by(id: params[:id])
    if @user.update(user_params)
      flash[:success] = t(:profile_updated)
      redirect_to @user
    else
      render "edit"
    end
  end

  def destroy
    @user = User.find_by(id: params[:id])
    if user&.destroy
      flash[:success] = t(:user_deleted)
    else
      flash[:danger]  = t(:delete_failed)
    end
    redirect_to users_url
  end

  def edit
    @user = User.find_by id: params[:id]
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = t(:please_log_in)
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find_by(id: params[:id])
    return if current_user?(@user)
    flash[:danger] = t(:not_authorized)
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
