class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :reauthenticate,  only: [:update]

  def new
    @user = User.new
  end

  ## Creates a new user and sends an activation email. The user cannot log in
  ## until they verify their email.
  def create
    @user = User.new(user_params)
    @user.activated = false
    
    ## All new users start off as viewers. Requests for other permission levels
    ## are process in the transaction below.
    requested_permission_level = get_sanitized_permission_level(
                                   @user.permission_level)
    @user.permission_level = "viewer"
    

    ## Begin transaction.
    begin
      ActiveRecord::Base.transaction do
        @user.save!
        @user.send_activation_email

        ## Check the requested permission level -- editor and admin require adding
        ## a permission request and sending an email.
        if requested_permission_level != "viewer"
          permission_request = PermissionRequest.create!({
            user: @user,
            level_requested: requested_permission_level
          })
          send_admin_notification_email(permission_request)
        end

        flash[:success] = "Please check your email to activate your account."
        redirect_to root_url
      end
    rescue => e
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


    if user_params.key?(:email) and user_params[:email] != @user.email
      email_updated = true
    end

    ## If the update was successful...
    if @user.update_attributes(user_params)

      ## If the user's email has been updated, send a verification email.
      if email_updated
        flash[:success] = "Please check your email to re-activate your "+
          "account with your new email address."
        @user.send_email_verification_email
      else
        flash[:success] = "Profile updated"
      end

    ## If the update wasn't successful, find out why.
    else
      if user_params.key?(:username) and User.find_by(
        username: user_params[:username]).nil? and 
          user_params[:username] != @user.username
        flash[:danger] = "The username you've provided is already in use."
      else
        flash[:danger] = "There was an error updating your information."
      end
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
        :password_confirmation, :permission_level)
    end

    def get_sanitized_permission_level(level)
      if valid_permission_level? level
        return level
      end
      return "viewer"
    end

    def reauthenticate
      current_password = params.require(:user).permit(
        :current_password)[:current_password]
      if current_password.nil? or not @user.authenticate(current_password)
        flash[:danger] = "Could not authenticate. Please check your password."
        redirect_to edit_user_path(current_user)
      end
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