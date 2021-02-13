require 'test_helper'
require 'erb'

class AdminToolsTest < ActionDispatch::IntegrationTest

  ## Administering users.
  test "should not display users if not logged in" do 
    get users_path
    assert_redirected_to login_path
    follow_redirect!
    assert (flash.key?(:danger) and 
      flash[:danger] == "This action requires that you be logged in."), 
      "No danger flash: #{flash[:danger]}"
  end
  
  test "should not display users if user not an admin" do 
    log_in_as_integration users(:bar)
    get users_path
    assert_redirected_to root_path
    follow_redirect!
    assert (flash.key?(:danger) and 
      flash[:danger]=="You must have admin permissions to perform this action."), 
      "No danger flash: #{flash[:danger]}"
  end
  
  
  test "should display users if an admin" do 
    log_in_as_integration users(:foo)
    get users_path
    assert_template "users/index"
    assert flash.keys.size == 1
    assert_equal flash[:info], "Welcome back! You are now logged in"
    
    assert_select "tr.user", User.all.size
    User.all.each do |user|
      assert_select "#user-#{user.id}>td.permission_level", user.permission_level
    end
  end
  

  ## Permission requests.
  test "should not display permission requests if not logged in" do 
    get permission_requests_path
    assert_redirected_to login_path
    follow_redirect!
    assert (flash.key?(:danger) and 
      flash[:danger] == "This action requires that you be logged in."), 
      "No danger flash: #{flash[:danger]}"
      
    get permission_request_path permission_requests(:pr1)
    assert_redirected_to login_path
    follow_redirect!
    assert (flash.key?(:danger) and 
      flash[:danger] == "This action requires that you be logged in."), 
      "No danger flash: #{flash[:danger]}"
  end
  
  test "should not display permission requests if user not an admin" do 
    log_in_as_integration users(:bar)
    get permission_requests_path
    assert_redirected_to root_path
    follow_redirect!
    assert (flash.key?(:danger) and 
      flash[:danger]=="You must have admin permissions to perform this action."), 
      "No danger flash: #{flash[:danger]}"
      
    get permission_request_path permission_requests(:pr1)
    assert_redirected_to root_path
    follow_redirect!
    assert (flash.key?(:danger) and 
      flash[:danger]=="You must have admin permissions to perform this action."), 
      "No danger flash: #{flash[:danger]}"
  end
  
  test "should display permission requests if an admin" do 
    log_in_as_integration users(:foo)
    permission_request = permission_requests(:pr1)
    
    ## All unreviewed permission requests listed.
    get permission_requests_path
    assert_template "permission_requests/index"
    assert flash.keys.size == 1
    assert_equal flash[:info], "Welcome back! You are now logged in"

    assert_select "tr.permission_request", 2
    [permission_request, permission_requests(:pr2)].each do |pr|
      assert_select "#permission_request-#{pr.id}>td.level-requested", 
        pr.level_requested
    end
        
    ## Can view one specifically.
    get permission_request_path(permission_request)
    assert_template "permission_requests/show"
    assert flash.keys.size == 0
    assert_select "tr.permission_request", 1
    [permission_request].each do |pr|
      assert_select "#permission_request-#{pr.id}>td.level-requested", 
        pr.level_requested
    end
    
    ## Reviewing one removes it from the list.
    permission_request.update({granted: false, reviewed: true})
    get permission_requests_path
    assert_template "permission_requests/index"
    assert flash.keys.size == 0
    assert_select "tr.permission_request", 1
    [permission_requests(:pr2)].each do |pr|
      assert_select "#permission_request-#{pr.id}>td.level-requested", 
        pr.level_requested
    end
  end
end