require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:foo)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { username: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path 
    post login_path, params: {
      session: { username: @user.username, password: 'password' } }
    assert is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_template 'homepage/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    ## Wait until we add user settings.
    # assert_select "a[href=?]", user_path(@user)
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_template 'homepage/show'
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "logout when not logged in shows an error" do
    ## We can go to any page; what we're checking is that we're directed back
    ## to the page we started at.
    get login_path
    response = delete logout_path, headers: {"HTTP_REFERER" => login_path}
    assert_redirected_to login_path
    follow_redirect!
    assert (flash.key?(:warning) and 
      flash[:warning] == "No user is currently logged in." )
  end

  test "login with remembering" do
    cookies.delete('remember_token')
    log_in_as_integration(@user, {remember_me: '1', password: 'password'})
    assert flash[:info] == "Welcome back! You are now logged in", flash.to_json
    assert_not_nil cookies['remember_token'], cookies.to_json
    assert is_logged_in?
  end

  test "login without remembering" do
    cookies.delete('remember_token')
    log_in_as_integration(@user, {remember_me: '0', password: 'password'})
    assert flash[:info] == "Welcome back! You are now logged in", flash.to_json
    assert_nil cookies['remember_token'], cookies.to_json
    assert is_logged_in?
  end
end
