require 'test_helper'
## Modified from https://www.railstutorial.org/book/account_activation_password_reset
class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:foo)
  end

  test "can access password reset page" do
    get new_password_reset_path
    assert_template 'password_resets/new'
  end

  test "invalid username on forgot password page raises an error" do
    # Invalid username.
    post password_resets_path, params: { password_reset: { uesrname: "" } }
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  test "a valid username generates a new reset digest" do
    # Valid username.
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest, 
      "New digest not generated"
    assert_equal 1, ActionMailer::Base.deliveries.size, "email not sent"
    assert flash.key?(:info), "Info flash not shown: #{flash.to_json}"
    assert_not flash[:info].empty?, "Success flash not shown"
    assert_redirected_to root_url, "Not redirected to root"
  end

  test "invalid username with valid reset token raises an error" do
    # Password reset form
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)

    # Wrong username.
    get edit_password_reset_path(user.reset_token, username: "")
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "inactive user can still reset password" do
    # Inactive user.
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)

    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, username: user.username)
    assert_template 'password_resets/edit'
  end

  test "right username, wront token raises an error" do
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)
    # Right username, wrong token
    get edit_password_reset_path('wrong token', username: user.username)
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test "right username, right token, but expired raises an error" do
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)
    # Right username, right token, but expired
    user.update_attribute(:reset_sent_at, 3.hours.ago)
    get edit_password_reset_path(user.reset_token, username: user.username)
    assert_not flash.empty?
    assert_redirected_to new_password_reset_path
    user.update_attribute(:reset_sent_at, Time.zone.now)
  end

  test "right username, right token works" do
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)
    # Right username, right token
    get edit_password_reset_path(user.reset_token, username: user.username)
    assert_template 'password_resets/edit'
    # assert_select "input[name=username][type=hidden][value=?]", user.username
    assert_match user.username, body
  end

  test "invalid password and confirmation raises an error" do
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)

    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), params: {
          username: user.username,
          user: { password:              "foobaz",
                  password_confirmation: "barquux" } }
    assert_select 'div#error_explanation'
  end

  test "empty password with right confirmation raises an error" do
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)
    # Empty password
    patch password_reset_path(user.reset_token), params: {
          username: user.username,
          user: { password:              "",
                  password_confirmation: "" } }
    assert_select 'div#error_explanation'
  end


  test "valid password and confirmation works" do
    post password_resets_path, params: {
      password_reset: { username: @user.username } }
    user = assigns(:user)
    # Valid password & confirmation
    patch password_reset_path(user.reset_token), params: {
          username: user.username,
          user: { password:              "password_new",
                  password_confirmation: "password_new" } }
    assert is_logged_in?, "Not logged in."
    assert_not flash.empty?
    assert_redirected_to root_url
  end
end