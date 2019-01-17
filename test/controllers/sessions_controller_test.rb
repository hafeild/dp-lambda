require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
  end

  test "shouldn't be able to log into a stub account" do
    stub_user = users(:stub1)
    post :create, params: {session: {username: stub_user.username, password: "password"}}
    assert_redirected_to root_path, @response.body
    assert flash[:warning] == "This account is only a stub; to claim it, "+
      "click \"Forgot password\" to a have a password reset link emailed "+
      "to you.", "Wrong flash: #{flash[:warning]}"
  end

  test "should be able to log in with correct username and password" do
    user = users(:foo)
    post :create, params: {session: {username: user.username, 
      password: "password"}}
    assert_redirected_to root_path, @response.body
    assert flash[:info] == "Welcome back! You are now logged in", 
      "Wrong flash message: #{flash[:info]}" 
  end

  test "should be able to log in with correct email and password" do
    user = users(:foo)
    post :create, params: {session: {username: user.email, 
      password: "password"}}
    assert_redirected_to root_path, @response.body
    assert flash[:info] == "Welcome back! You are now logged in", 
      "Wrong flash message: #{flash[:info]}" 
  end


  test "shouldn't be able to log in with incorrect password" do
    user = users(:foo)
    ## Wrong password
    post :create, params: {session: {username: user.email, 
      password: "wrongpassword"}}
    assert_redirected_to login_path, @response.body
    assert flash[:danger] == "Invalid username/email and password combination", 
      "Wrong flash message: #{flash[:danger]}" 
  end

  test "shouldn't be able to log into a an account until activated" do
    user = users(:foo)
    user.activated = false
    user.save

    post :create, params: {session: {username: user.username, 
      password: "password"}}
    assert_redirected_to root_path, @response.body
    assert flash[:warning] == "Account not activated. Check your email for "+
      "the activation link or click \"Forgot password\" to a have a new one "+
      "emailed to you.", "Wrong flash: #{flash[:warning]}"
  end


  test "shouldn't be able to log into a deleted account" do
    user = users(:foo)
    user.deleted = true
    user.save

    post :create, params: {session: {username: user.username, 
      password: "password"}}
    assert_redirected_to root_path, @response.body
    assert flash[:warning] == "Account has been deleted.", 
      "Wrong flash: #{flash[:warning]}"
  end

end
