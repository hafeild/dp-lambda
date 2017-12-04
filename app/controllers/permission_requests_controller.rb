class PermissionRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :user_is_admin
  before_action :get_permission_request, only: [:show, :update]
  
  
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
  def new
    
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

  
end