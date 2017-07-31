class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :validate_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  before_action :activate,   only: [:edit]

  def new
  end

  def edit
  end

  def create
    if params[:password_reset][:username].nil? or 
        params[:password_reset][:username].empty?
      flash[:warning] = "Please provide a username."
      render 'new'
      return
    end

    @user = User.find_by(username: params[:password_reset][:username])

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
    end

    flash[:info] = "If the email entered is valid, an email has been sent "+
      "with password reset instructions"
    redirect_to root_url
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.reset_digest = nil
      @user.save
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to root_url
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Before filters

    def get_user
      begin
        if params.key? :username
          @user = User.find_by(username: params[:username])
        elsif params.key?(:user) and params[:user].key?(:username)
          @user = User.find_by(username: params[:user][:username])
        end
      rescue
        flash[:danger] = "Your request could not be completed."
        redirect_to root_url
      end
    end


    # Confirms a valid user.
    def validate_user
      if @user.nil? or @user.reset_digest.nil? or 
          not @user.authenticated?(:reset, params[:id])
        flash[:danger] = "Your request could not be completed."
        redirect_to root_url
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end

    def activate
      unless @user.nil? or @user.activated?
        @user.activate
      end
    end
end
