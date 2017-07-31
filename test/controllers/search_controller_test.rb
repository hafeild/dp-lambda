require "test_helper"

class SearchControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing basic search

  test "basic searchshould break when searching an invalid vertical" do
    get :show, params: { vertical: "", q: "test" }
    assert_redirected_to root_path, @response.body
  end
  
  test "basic search should break when performing a basic search with an "+
      "empty query" do
    get :show, params: { vertical: "assignments", q: "" }
    assert_redirected_to root_path, @response.body
  end
  
  test "basic search should work when issuing a nonempty query to a valid "+
      "vertical" do
    get :show, params: { vertical: "all", q: "test", cursor: "*" }
    assert_response :success
    
    get :show, params: { vertical: "assignments", q: "test" }
    assert_response :success
    
    get :show, params: { vertical: "analyses", q: "test" }
    assert_response :success
    
    get :show, params: { vertical: "software", q: "test" }
    assert_response :success
    
    get :show, params: { vertical: "datasets", q: "test" }
    assert_response :success
  end
  
  ##############################################################################
  
  
  ##############################################################################
  ## Testing advanced search
  
  test "advanced search should break when searching an invalid vertical" do
    get :show, params: { vertical: "", q: "test" }
    assert_redirected_to root_path, @response.body
  end
  
  test "advanced search should break when performing a basic search with an "+
      "empty query" do
    get :show, params: { vertical: "assignments", advanced: "true"}
    assert_redirected_to root_path, @response.body
  end
  
  test "advanced search should work with an empty query field but nonempty "+
      "advanced field" do
    get :show, params: { vertical: "assignments", advanced: "true", nq: "test" }
    assert_response :success
  end
  
  
  test "advanced search should work when issuing a nonempty query to a valid "+
      " vertical" do
    get :show, params: { vertical: "all", advanced: "true", q: "test",
      nq: "test", dq: "test", sq: "test", tq: "test", eq: "test", wrq: "test",
      aq: "test", arq: "test", lcq: "test", all: "true" }
    assert_response :success, @response.body
    
    get :show, params: { vertical: "assignments", advanced: "true",  q: "test" }
    assert_response :success
    
    get :show, params: { vertical: "analyses", advanced: "true",  q: "test" }
    assert_response :success
    
    get :show, params: { vertical: "software", advanced: "true",  q: "test" }
    assert_response :success
    
    get :show, params: { vertical: "datasets", advanced: "true",  q: "test" }
    assert_response :success
  end
  
  
  ##############################################################################

end