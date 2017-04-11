class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]

  def new
    @user = User.new
  end

  ## Creates a new user and sends an activation email. The user cannot log in
  ## until they verify their email.
  def create
    @user = User.new(user_params)
    @user.activated = false
    if @user.save
        @user.send_activation_email

        flash[:success] = "Please check your email to activate your account."
        redirect_to root_url
    else
        render 'new'
    end
  end

  def destroy
    redirect_to :root
  end

  def update
    email_updated = false
    @user = User.find(params[:id])
    ## Authenticate password.
    if user_params.key?(:current_password) and
        @user.authenticate(user_params[:current_password])
      if user_params.key?(:email) and user_params[:email] != @user.email
        email_updated = true
      end
      if @user.update_attributes(user_params)

        if email_updated
          flash[:success] = "Please check your email to re-activate your "+
            "account with your new email address."
          @user.send_email_verification_email
        else
          flash[:success] = "Profile updated"
        end
      else
        if user_params.key?(:username) and User.find_by(
          username: user_params[:username]).nil? and 
            user_params[:username] != @user.username
          flash[:danger] = "The username you've provided is already in use."
        else
          flash[:danger] = "There was an error updating your information."
        end
      end
    else
      flash[:danger] = "Could not authenticate. Please try again."
    end

    redirect_to edit_user_path(current_user)
  end

  def edit
    @user = User.find(params[:id])
  end

  private

    ## Extracts all of the permitted parameters for a user.
    def user_params
      params.require(:user).permit(:username, :email, :role, 
        :first_name, :last_name, :field_of_study, :password,
        :password_confirmation)
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end