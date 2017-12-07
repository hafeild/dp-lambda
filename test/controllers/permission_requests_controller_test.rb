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
      assert bar.permission_level == "viewer", 
        "permission level not updated: #{bar.permission_level}"
      assert permission_request.level_requested == "viewer", 
        "Level requested incorrect."
      assert permission_request.granted, "Permission not granted."
      assert permission_request.reviewed, "Permission not marked as reviewed."
      assert permission_request.reviewed_by_id == user.id, 
        "Reviewed_by id incorrect."
      assert bar.permission_level_granted_by_id == user.id, 
        "Granted_by id incorrect."
    end
  end
  
  test "can't create a new permission request if not logged in as admin" do
    user = users(:bar)
    bar = users(:bar)

    ## Test that it fails when not logged in at all.
    assert_no_difference "PermissionRequest.count", "Request created" do
      post :create, params: { permission_request: {
        user_id: bar.id,
        permission_level: "viewer"
      }, format: "json"}
      data = JSON.parse(@response.body)
      bar.reload

      assert_not data["success"], "Response successful: #{@response.body}"

      assert bar.permission_level == "editor", 
        "permission level not updated: #{bar.permission_level}"
    end
    
    ## Test that it fails when logged in a non-admin.
    log_in_as user
    assert_no_difference "PermissionRequest.count", "Request created" do
      post :create, params: { permission_request: {
        user_id: bar.id,
        permission_level: "viewer"
      }, format: "json"}
      data = JSON.parse(@response.body)
      bar.reload

      assert_not data["success"], "Response successful: #{@response.body}"

      assert bar.permission_level == "editor", 
        "permission level not updated: #{bar.permission_level}"
    end
    
  end
  
  
  ##############################################################################
  ## Testing update
  
  test "grant permission request" do
    user = users(:foo)
    bar = users(:bar)
    permission_request = permission_requests(:pr1)
    log_in_as user

    put :update, params: { id: permission_request.id, permission_request: {
      action: "grant"
    }, format: "json"}
    data = JSON.parse(@response.body)
    bar.reload

    assert data["success"], "Response unsuccessful: #{@response.body}"

    permission_request = PermissionRequest.last
    assert bar.permission_level == permission_request.level_requested, 
      "permission level not updated: #{bar.permission_level}"
    assert permission_request.reviewed, "Permission not marked as reviewed."
    assert permission_request.granted, "Permission not granted."
    assert permission_request.reviewed_by_id == user.id, 
      "Reviewed_by id incorrect."
    assert bar.permission_level_granted_by_id == user.id, 
      "Granted_by id incorrect."
  end
  
  test "decline permission request" do
    user = users(:foo)
    bar = users(:bar)
    permission_request = permission_requests(:pr1)
    log_in_as user

    put :update, params: { id: permission_request.id, permission_request: {
      action: "decline"
    }, format: "json"}
    data = JSON.parse(@response.body)
    bar.reload

    assert data["success"], "Response unsuccessful: #{@response.body}"

    permission_request = PermissionRequest.last
    assert bar.permission_level == "editor", 
      "permission level not updated: #{bar.permission_level}"
    assert permission_request.reviewed, "Permission not marked as reviewed."
    assert_not permission_request.granted, "Permission not granted."
    assert permission_request.reviewed_by_id == user.id, 
      "Reviewed_by id incorrect."
    assert bar.permission_level_granted_by_id != user.id, 
      "Granted_by id incorrect."
  end
  
  
  test "non-root users cannot review permission request" do
    user = users(:bar)
    bar = users(:bar)
    permission_request = permission_requests(:pr1)

    ## Not logged in at all.
    put :update, params: { id: permission_request.id, permission_request: {
      action: "grant"
    }, format: "json"}
    data = JSON.parse(@response.body)
    bar.reload

    assert_not data["success"], "Response successful: #{@response.body}"

    permission_request = PermissionRequest.last
    assert bar.permission_level == "editor", 
      "permission level not updated: #{bar.permission_level}"
    assert_not permission_request.reviewed, "Permission marked as reviewed."
    assert_not permission_request.granted, "Permission marked as granted."
    assert permission_request.reviewed_by_id.nil? 
      "Reviewed_by id should be nil."
    assert bar.permission_level_granted_by_id.nil?, 
      "Granted_by should be nil."
      
    ## Logged in as non-root.
    log_in_as user
    put :update, params: { id: permission_request.id, permission_request: {
      action: "grant"
    }, format: "json"}
    data = JSON.parse(@response.body)
    bar.reload

    assert_not data["success"], "Response successful: #{@response.body}"

    permission_request = PermissionRequest.last
    assert bar.permission_level == "editor", 
      "permission level not updated: #{bar.permission_level}"
    assert_not permission_request.reviewed, "Permission marked as reviewed."
    assert_not permission_request.granted, "Permission marked as granted."
    assert permission_request.reviewed_by_id.nil? 
      "Reviewed_by id should be nil."
    assert bar.permission_level_granted_by_id.nil?, 
      "Granted_by should be nil."
  end
  
end