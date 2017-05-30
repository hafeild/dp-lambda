require 'test_helper'

class ExamplesControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating an example without being logging in" do
    assert_no_difference 'Example.count', "Example created" do
      post :create, params: { example: { 
        title: "x", description: "x" } }
      assert_redirected_to login_path, @response.body
    end
  end

  test "should create example and link to software page" do
    log_in_as users(:foo)
    software = software(:one)
    assert_difference 'Example.count', 1, "Example not created" do
      post :create, params: { software_id: software.id, example: { 
        title: "x", description: "x" } }
      assert_redirected_to software_path(software), @response.body
    end
  end
  ##############################################################################


  ##############################################################################
  ## Testing making a connection between verticals to existing examples.

  test "should link example to software page" do
    log_in_as users(:foo)
    software = software(:one)
    example = examples(:one)
    assert_difference 'software.examples.size', 1, "Example not linked" do
      post :connect, params: { software_id: software.id, id: example.id }
      assert_redirected_to software_path(software), @response.body
      software.reload
    end
  end

  ##############################################################################


  ##############################################################################
  ## Testing removing a connection between verticals and examples.

  test "should unlink example to software page" do
    log_in_as users(:foo)
    software = software(:two)
    example = examples(:one)
    assert_difference 'software.examples.size', -1, "Example not unlinked" do
      delete :disconnect, params: { software_id: software.id, id: example.id }
      assert_redirected_to software_path(software), @response.body
      assert Example.find_by(id: example.id).nil?
      software.reload
    end
  end

  ##############################################################################

  ##############################################################################
  ## Testing updating an example.

  test "should update the example of redirect to a software page" do
    log_in_as users(:foo)
    software = software(:two)
    example = examples(:one)
    patch :update, params: { software_id: software.id, id: example.id,
      example: { title: "A better example!" } }
    assert_redirected_to software_path(software), @response.body
    example.reload
    assert example.title == "A better example!"
  end

  ##############################################################################



end