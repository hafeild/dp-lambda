module PermissionsHelper

  ## Tests whether the user current logged in (if logged in at all) can edit
  ## pages.
  def can_edit?
    return logged_in?
  end

end