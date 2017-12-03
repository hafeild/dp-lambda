class PermissionRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :user_is_admin
  
  
  ## Need to think about this...
  ##
  ## Admins will use this to grant requested permissions
  ## Admins will use this to change permissions (not associated with a request)
  ##    -- maybe that's the same thing? (we will make a request if 
  ##       one doesn't exist)
  
  def show
    @permission_request = PermissionRequest.find(params[:id])
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
  
  end
  

  
end