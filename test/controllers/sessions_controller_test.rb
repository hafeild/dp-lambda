require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  test "should get new" do
    get :new
    assert_response :success
  end

  # test "shouldn't be able to log into a stub account" do
  #   post :create, params: {session: {username: "", password: "password"}}
  #   assert_redirected_to root_path, @response.body
  #   assert session[:user_id].empty?, session.to_json 
  # end



end
