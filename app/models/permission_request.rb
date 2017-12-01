class PermissionRequest < ApplicationRecord
  ## PermissionRequests have...
  ## - user
  ## - level_requested (admin or editor)
  ## - reviewed (boolean)
  ## - granted (boolean)
  ## - reviewed_by (user)
  ## - reviewed_on (datetime)
  ## - created_at (datetime)
  ## - updated_at (datetime)
  
  
  belongs_to :user
  # belongs_to :reviewed_by, class_name: "User"
  
  def grant_permission!(reviewer)
    set_grant_status(true, reviewer)
  end
  
  def decline_permission!(reviewer)
    set_grant_status(false, reviewer)
  end
  
  def set_grant_status!(status, reviewer)
    reviewed_by = reviewer
    granted = status
    reviewed = true
    reviewed_on = Time.now
    save!
  end

end