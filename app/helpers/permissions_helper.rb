module PermissionsHelper

  ## Tests whether the user current logged in (if logged in at all) can edit
  ## pages.
  def can_edit?
    logged_in? and current_user.can_edit?
  end

end