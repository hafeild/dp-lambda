class PermissionRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :user_is_admin
  before_action :get_permission_request, only: [:show, :update]
  before_action :get_params, only: [:create]
  before_action :get_user, only: [:create]
  
  
  ## Need to think about this...
  ##
  ## Admins will use this to grant requested permissions
  ## Admins will use this to change permissions (not associated with a request)
  ##    -- maybe that's the same thing? (we will make a request if 
  ##       one doesn't exist)
  
  def show
  end
  
  
  ## Shows all pending requests.
  def index
    @permission_requests = PermissionRequest.where(reviewed: false)
  end
  
  ## For an admin to change a permission that wasn't requested.
  def create
    requested_permission_level = get_sanitized_permission_level(
      @params[:permission_level])

    begin
      ActiveRecord::Base.transaction do
        permission_request = PermissionRequest.create!({
          user: @user,
          level_requested: requested_permission_level,
          reviewed: true,
          granted: true,
          reviewed_by: current_user,
          reviewed_on: Time.now
        })

        @user.update!({
          permission_level: requested_permission_level,
          permission_level_granted_by: current_user,
          permission_level_granted_on: permission_request.reviewed_on
        })

        @user.send_permissions_changed_email
      end
        
      respond_to do |format|
        format.json { render json: {
          success: true, 
          permission_request: {
            permission_level: @user.permission_level,
            reviewed_by_username: current_user.username,
            reviewed_on: permission_request.reviewed_on
          }
        } }
        format.html { redirect_to users_path }
      end
    rescue => e
      respond_with_error "There was an error saving this request.", 
        users_path
    end
  end
  
  ## For an admin to grant a permission.
  def update
    begin
      ## Can't review an already reviewed request.
      if @permission_request.reviewed
        respond_with_error 'This request has already been reviewed.', 
          permission_request_path(@permission_request)
      else
        granted = (params.require(:permission_request).require(:action) == 'grant')
        
        ## Update the request with the review.
        @permission_request.update!({
          reviewed: true,
          granted: granted,
          reviewed_by: current_user,
          reviewed_on: Time.now
        })
        
        ## Update the user's permission level.
        if granted
          @permission_request.user.update!({
            permission_level: @permission_request.level_requested,
            permission_level_granted_on: @permission_request.reviewed_on,
            permission_level_granted_by: current_user
          })
          @user = @permission_request.user
          @user.send_permissions_changed_email
        end
        
        respond_to do |format|
          format.json { render json: {
            success: true, 
            permission_request: {
              granted: @permission_request.granted,
              reviewed_by_username: current_user.username,
              reviewed_on: @permission_request.reviewed_on
            }
          } }
          format.html { redirect_to path }
        end
      end
    rescue => e 
      respond_with_error 'There was a problem saving changes to this request.', 
          permission_request_path(@permission_request)
    end
  end
  
  private
    def get_permission_request
      @permission_request = PermissionRequest.find(params[:id])
    end

    def get_params
      begin
        @params = params.require(:permission_request).permit(
          :user_id, :permission_level)
      rescue => e
        respond_with_error "Parameters missing.", users_path
      end
    end

    def get_user
      begin
        @user = User.find(@params[:user_id])
      rescue => e
        respond_with_error "User with id #{@params[:user_id]} not found.",
          users_path
      end
    end

  
end