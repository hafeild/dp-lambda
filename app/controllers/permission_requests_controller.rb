class PermissionRequestsController < ApplicationController
  before_action :logged_in_user
  before_action :user_is_admin, except: [:new]
  
  
  ## Need to think about this...
  ##
  ## Users will use this to request permission after signup
  ## Admins will use this to grant requested permissions
  ## Admins will use this to change permissions (not associated with a request)
  ##    -- maybe that's the same thing? (we will make a request if 
  ##       one doesn't exist)
  
  
  ## Shows all pending requests -- must be admin to see.
  def index
    
  end
  
  ## For users to request a different permission level.
  def new
    
  end
  
  ## For an admin to grant a permission.
  def update
  
  end
  
  
end