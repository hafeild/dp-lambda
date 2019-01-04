class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, 
    :new_stub, :create_stub, :edit_stub, :update_stub, :destroy_stub]
  before_action :correct_user,   only: [:edit, :update, :destroy]
  before_action :reauthenticate,  only: [:update]
  before_action :user_is_admin, only: [:index]
  before_action :user_can_edit, only: [:new_stub, :create_stub, 
    :edit_stub, :update_stub, :destroy_stub]
  before_action :get_user, only: [:destroy, :edit_stub, :update_stub, :destroy_stub]
  before_action :confirm_is_stub, only: [:edit_stub, :update_stub, :destroy_stub]
  before_action :user_can_modify_stub, only: [:edit_stub, :update_stub, 
    :destroy_stub]
  before_action :user_can_destroy, only: [:destroy]

  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  ## Creates a new user and sends an activation email. The user cannot log in
  ## until they verify their email.
  def create
    ## Begin transaction.
    begin
      User.transaction do
        # @user = User.find_by(email: user_params[:email])
        # if @user.nil? or @user.is_registered
        #   @user = User.new(user_params)
        # else
        #   @user.update(user_params)
        # end

        @user = User.new(user_params)
        @user.activated = false
        @user.is_registered = true
        
        ## All new users start off as viewers. Requests for other permission levels
        ## are process in the transaction below.
        requested_permission_level = get_sanitized_permission_level(
                                       @user.permission_level)
        @user.permission_level = "viewer"
        
        @user.save!
        @user.reload
        
        

        ## Check the requested permission level -- editor and admin require
        ## adding a permission request and sending an email.
        if requested_permission_level != "viewer"
          permission_request = PermissionRequest.create!({
            user: @user,
            level_requested: requested_permission_level
          })
          send_admin_notification_email(permission_request)
        end
        @user.send_activation_email
        
      end

      flash[:success] = "Please check your email to activate your account."
      redirect_to root_url
    rescue => e
      # puts "#{e.message} #{e.backtrace.join("\n")}"
      # Rails.logger.info(e)
      # Rails.logger.info("\t"+ e.backtrace.join("\n\t"))
      flash[:danger] = "There was an error! #{e}"
      render 'new'
    end
  end

  # delete all information EXCEPT for the username
  def destroy
   
    ## Begin transaction.
    begin
      User.transaction do
        deleted_user_count = User.where({deleted: true}).size

        @user.username = "removed#{deleted_user_count}"
        @user.email = "removed#{deleted_user_count}@localhost"
        @user.first_name = "User"
        @user.last_name = "Removed"
        @user.role = nil
        @user.field_of_study = nil
        @user.password_digest = nil
        @user.activation_digest = nil
        @user.activated = nil
        @user.activated_at = nil
        @user.remember_digest = nil
        @user.reset_digest = nil
        @user.reset_sent_at = nil
        # @user.created_at = nil
        # @user.updated_at = nil
        @user.permission_level = nil
        @user.permission_level_granted_on = nil
        @user.permission_level_granted_by_id = nil
        @user.deleted = true
        @user.save(validate: false)
        log_out
        
      end
      respond_with_success root_url

    rescue => e
      # puts "#{e.message} #{e.backtrace.join("\n")}"
      error = "There was an error! #{e}"
      flash[:danger] = error
      respond_with_error error, get_redirect_path
    end
  end

  def update
    email_updated = false
    permissions_updated = false
    cur_params = user_params
    
    @user = User.find(params[:id])

    if cur_params.key?(:email) and cur_params[:email] != @user.email
      email_updated = true
    end
    
    ## Check if a change was made to the user's permission level.
    if(cur_params.key?(:permission_level) and 
        cur_params[:permission_level] != @user.permission_level)
      permissions_updated = true
      requested_permission_level = get_sanitized_permission_level(
        cur_params[:permission_level])
      
      Rails.logger.info("Requested permission level: #{requested_permission_level}")
      
      if requested_permission_level != "viewer"
        Rails.logger.info('Removing permission_level from user_params')
        cur_params = cur_params.except(:permission_level)
      end
    end

    # Rails.logger.info(cur_params.to_unsafe_h.map{|k,v| "#{k}: #{v}"}.join("\n"))

    ## If the update was successful...
    if @user.update_attributes(cur_params)

      ## Check the requested permission level -- editor and admin require
      ## adding a permission request and sending an email.
      if permissions_updated and requested_permission_level != "viewer"
        permission_request = PermissionRequest.create!({
          user: @user,
          level_requested: requested_permission_level
        })
        send_admin_notification_email(permission_request)
        flash[:info] = ("Your requested permission change to "+
          "#{requested_permission_level} is pending approval from an admin.")
      end
      
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


  ####################################
  ## For user stubs.
  ##
  def new_stub
  end

  def create_stub
    ## Begin transaction.
    begin
      User.transaction do
        @user = User.new(user_params)
        @user.activated = false
        @user.is_registered = false
        @user.save!
        @user.reload
      end

      respond_with_success get_redirect_path, 
        {user_stub: {json: @user.summary_data_json, 
          html: render_to_string(partial: 'users/badge')}}
          # html: render_to_string(partial: 'users/badge', formats: [:html])}}

    rescue => e
      # puts "#{e.message} #{e.backtrace.join("\n")}"
      error = "There was an error! #{e}"
      flash[:danger] = error
      respond_with_error error, get_redirect_path
    end
  end

  def edit_stub
  end

  def update_stub
    ## Begin transaction.
    begin
      User.transaction do
        @user.update!(user_params)
        @user.reload
      end

      respond_with_success get_redirect_path, 
        {user_stub: {json: @user.summary_data_json, 
          html: render_to_string(partial: 'users/badge')}}

    rescue => e
      # puts "#{e.message} #{e.backtrace.join("\n")}"
      error = "There was an error! #{e}"
      flash[:danger] = error
      respond_with_error error, get_redirect_path
    end
  end

  def destroy_stub
    begin
      User.transaction do
        deleted_user_count = User.where({deleted: true}).size

        @user.username = "removed#{deleted_user_count}"
        @user.email = "removed#{deleted_user_count}@localhost"
        @user.first_name = "User"
        @user.last_name = "Removed"
        @user.role = nil
        @user.field_of_study = nil
        @user.password_digest = nil
        @user.activation_digest = nil
        @user.activated = nil
        @user.activated_at = nil
        @user.remember_digest = nil
        @user.reset_digest = nil
        @user.reset_sent_at = nil
        @user.permission_level = nil
        @user.permission_level_granted_on = nil
        @user.permission_level_granted_by_id = nil
        @user.deleted = true
        @user.save(validate: false)
      end

      respond_with_success get_redirect_path

    rescue => e
      # puts "#{e.message} #{e.backtrace.join("\n")}"
      error = "There was an error! #{e}"
      flash[:danger] = error
      respond_with_error error, get_redirect_path
    end

  end
  ####################################


  private

    ## Extracts all of the permitted parameters for a user.
    def user_params
      params.require(:user).permit(:username, :email, :role, 
        :first_name, :last_name, :field_of_study, :password, 
        :password_confirmation, :permission_level)
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
    # def logged_in_user
    #   unless logged_in?
    #     store_location
    #     flash[:danger] = "Please log in."
    #     redirect_to login_url
    #   end
    # end

    def get_user
      @user = User.find_by(id: params[:id])
      if @user.nil?
        respond_with_error "A user id must be provided."
      end
    end

    def confirm_is_stub
      if @user.is_registered
        respond_with_error "The requested user is registered an cannot be modified."
      end
    end

    def user_can_modify_stub
      unless current_user.is_admin? or (!@user.created_by.nil? and @user.created_by.id == current_user.id)
        respond_with_error "You do not have permissions to modify the requested user stub."
      end
    end

    def user_can_destroy
      unless current_user.is_admin? or @user.id == current_user.id
        respond_with_error "You do not have permissions to modify the requested user stub."
      end
    end

end