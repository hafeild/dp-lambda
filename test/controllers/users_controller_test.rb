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
        email: "x@mail.org",
        role: "student",
        first_name: "X",
        last_name: "Y",
        field_of_study: "XYZ",
        password: "12345678",
        permission_level: "viewer"
      } }
      assert_redirected_to root_path, @response.body
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
  
  ##############################################################################
  ## Testing update
  
  test "should update user settings" do
    log_in_as users(:foo)
  end
  
end