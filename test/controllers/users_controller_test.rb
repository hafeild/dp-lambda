require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create
  
  test "should create a new user" do
    assert_difference "User.count", 1, "User not created" do
      post :create, params: { user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        password_confirmation: "12345678",
        permission_level: "viewer"
      } }
      assert_redirected_to root_path, @response.body
      user = User.find_by(username: "x")
      assert_not user.nil?, "New user doesn't exist."
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
    end
  end
  
  test "should fail because insufficient arguments" do
    assert_no_difference "User.count", "User created" do
      post :create, params: { user: { 
        username: "x",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        permission_level: "viewer"
      } }
    end
  end
  
  
  test "should create a user with viewer permissions" do
    assert_difference "User.count", 1, "User not created" do
      post :create, params: { user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        password_confirmation: "12345678",
        permission_level: "what"
      } }
      assert_redirected_to root_path, @response.body
      user = User.find_by(username: "x")
      assert_not user.nil?, "New user doesn't exist."
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
    end
  end
  
  
  test "should create a user with viewer permissions and a permission request" do
    assert_difference "User.count", 1, "User not created" do
    assert_difference "PermissionRequest.count", 1, "Permission request not created" do
      post :create, params: { user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        password_confirmation: "12345678",
        permission_level: "admin"
      } }
      assert_redirected_to root_path, @response.body
      user = User.find_by(username: "x")
      assert_not user.nil?, "New user doesn't exist."
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
      permission_request = PermissionRequest.find_by(user: user)
      assert_not permission_request.nil?
      assert permission_request.level_requested = "admin"
    end
    end
  end
  
  ##############################################################################
  ## Testing update
  
  test "can't update user settings unless logged in as user" do
    log_in_as users(:foo)
    bar = users(:bar)
    post :update, params: { id: users(:bar).id, user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        permission_level: "admin"
      } }
    bar.reload
    assert bar.username != "x"
    assert bar.email != "x@mail.org"
  end
  
  test "should update user settings and create permission request" do
    user = users(:bar)
    log_in_as user
    assert_difference "PermissionRequest.count", 1, "Permission request not created" do
      post :update, params: { id: user.id, user: { 
          username: "x",
          email: "x@mail.org",
          role: "student",
          first_name: "X",
          last_name: "Y",
          field_of_study: "XYZ",
          current_password: "password",
          permission_level: "admin",
          password: "12345678",
          password_confirmation: "12345678"
        } }
      user.reload
      assert user.username == "x", "Username not updated: #{user.username}"
      assert user.email == "x@mail.org", "Email not updated: #{user.email}"
      
      assert user.permission_level == "editor", 
        "Permission level saved incorrectly."
      permission_request = PermissionRequest.find_by(user: user)
      assert_not permission_request.nil?
      assert permission_request.level_requested = "admin"
    end
  end
  
  test "should update user settings but not create permission request" do
    user = users(:foo)
    log_in_as user
    assert_difference "PermissionRequest.count", 0, "Permission request created" do
      post :update, params: { id: user.id, user: { 
          username: "x",
          email: "x@mail.org",
          role: "student",
          first_name: "X",
          last_name: "Y",
          field_of_study: "XYZ",
          current_password: "password",
          permission_level: "viewer",
          password: "12345678",
          password_confirmation: "12345678"
        } }
      user.reload
      assert user.username == "x", "Username not updated: #{user.username}"
      assert user.email == "x@mail.org", "Email not updated: #{user.email}"
      
      assert user.permission_level == "viewer", 
        "Permission level saved incorrectly."
    end
  end
  
  test "shouldn't update user settings without correct password" do
    user = users(:foo)
    log_in_as user
    post :update, params: { id: user.id, user: { 
        username: "x",
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        current_password: "123",
        permission_level: "admin"
      } }
    user.reload
    assert user.username != "x", "Username updated"
    assert user.email != "x@mail.org", "Email updated"
  end
  
  
end