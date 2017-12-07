require 'test_helper'

class PermissionRequestsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create
  
  test "should create a new permission request" do
    user = users(:foo)
    bar = users(:bar)
    log_in_as user

    assert_difference "PermissionRequest.count", 1, "Request not created" do
      post :create, params: { permission_request: {
        user_id: bar.id,
        permission_level: "viewer"
      }, format: "json"}
      data = JSON.parse(@response.body)
      bar.reload

      assert data["success"], "Response unsuccessful: #{@response.body}"

      permission_request = PermissionRequest.last
      assert permission_request.user_id == bar.id, "User id doesn't match"
      assert bar.permission_level == "viewer", "permission level not updated: #{bar.permission_level}"
      assert permission_request.level_requested == "viewer", "Level requested incorrect."
      assert permission_request.granted, "Permission not granted."
      assert permission_request.reviewed_by_id = user.id, "Reviewed_by id incorrect."
      assert bar.permission_level_granted_by_id = user.id, "Granted_by id incorrect."
    end
  end
  
end