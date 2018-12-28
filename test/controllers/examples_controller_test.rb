require "test_helper"

class ExamplesControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating an example without being logging in" do
    assert_no_difference "Example.count", "Example created" do
      post :create, params: { example: { 
        title: "x", description: "x" } }
      assert_redirected_to login_path, @response.body
    end
  end

  test "should create example and link to analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:one)
    assert_difference "Example.count", 1, "Example not created" do
      post :create, params: { analysis_id: analysis.id, example: { 
        title: "x", summary: "x" } }
      assert_redirected_to analysis_path(analysis), @response.body
    end
  end

  test "should create example and link to dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    assert_difference "Example.count", 1, "Example not created" do
      post :create, params: { dataset_id: dataset.id, example: { 
        title: "x", summary: "x" } }
      assert_redirected_to dataset_path(dataset), @response.body
    end
  end

  test "should create example and link to software page" do
    log_in_as users(:foo)
    software = software(:one)
    assert_difference "Example.count", 1, "Example not created" do
      post :create, params: { software_id: software.id, example: { 
        title: "x", summary: "x" } }
      assert_redirected_to software_path(software), @response.body
    end
  end

  test "should break when creating an example with no title or summary" do
    log_in_as users(:foo)
    software = software(:one)
    assert_no_difference "Example.count", "Example created" do
      post :create, params: { example: { description: "hi" } }
      assert_redirected_to root_path, @response.body

      post :create, params: { example: { title: "xyz", description: "" } }
      assert_redirected_to root_path, @response.body

      post :create, params: { 
        example: { title: "", summary: "", description: "xyz" } }
      assert_redirected_to root_path, @response.body
    end
  end

  test "should break when creating an example with a non-unique title" do
    log_in_as users(:foo)
    software = software(:one)
    example = examples(:one)
    assert_no_difference "Example.count", "Example created" do
      post :create, params: { software_id: software.id,
        example: { title: example.title, summary: "xyz" } }
      assert_redirected_to software_path(software), @response.body
    end
  end

  test "should break when creating an example with a long title" do
    log_in_as users(:foo)
    software = software(:one)
    assert_no_difference "Example.count", "Example created" do
      post :create, params: { software_id: software.id,
        example: { title: "x"*201, summary: "xyz" } }
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
    assert_difference "software.examples.size", 1, "Example not linked" do
      post :connect, params: { software_id: software.id, id: example.id }
      assert_redirected_to software_path(software), @response.body
      software.reload
    end
  end

  test "should link example to dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    example = examples(:one)
    assert_difference "dataset.examples.size", 1, "Example not linked" do
      post :connect, params: { dataset_id: dataset.id, id: example.id }
      assert_redirected_to dataset_path(dataset), @response.body
      dataset.reload
    end
  end

  test "should link example to analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:one)
    example = examples(:one)
    assert_difference "analysis.examples.size", 1, "Example not linked" do
      post :connect, params: { analysis_id: analysis.id, id: example.id }
      assert_redirected_to analysis_path(analysis), @response.body
      analysis.reload
    end
  end

  ##############################################################################


  ##############################################################################
  ## Testing removing a connection between verticals and examples.

  test "should unlink example to software page" do
    log_in_as users(:foo)
    software = software(:two)
    example = examples(:one)
    assert_difference "software.examples.size", -1, "Example not unlinked" do
      delete :disconnect, params: { software_id: software.id, id: example.id }
      assert_redirected_to software_path(software), @response.body
      assert_not Example.find_by(id: example.id).nil?
      software.reload
    end
  end

  test "should unlink example to dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:two)
    example = examples(:two)
    assert_difference "dataset.examples.size", -1, "Example not unlinked" do
      delete :disconnect, params: { dataset_id: dataset.id, id: example.id }
      assert_redirected_to dataset_path(dataset), @response.body
      assert_not Example.find_by(id: example.id).nil?
      dataset.reload
    end
  end

  test "should unlink example to analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:two)
    example = examples(:two)
    assert_difference "analysis.examples.size", -1, "Example not unlinked" do
      delete :disconnect, params: { analysis_id: analysis.id, id: example.id }
      assert_redirected_to analysis_path(analysis), @response.body
      assert_not Example.find_by(id: example.id).nil?
      analysis.reload
    end
  end

  ##############################################################################

  ##############################################################################
  ## Testing updating an example.

  test "should update the example and redirect to a software page" do
    log_in_as users(:foo)
    software = software(:two)
    example = examples(:one)
    patch :update, params: { software_id: software.id, id: example.id,
      example: { title: "A better example!" } }
    assert_redirected_to software_path(software), @response.body
    example.reload
    assert example.title == "A better example!", example.title
  end

  test "should update the example and redirect to a dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:two)
    example = examples(:two)
    patch :update, params: { dataset_id: dataset.id, id: example.id,
      example: { title: "A better example!" } }
    assert_redirected_to dataset_path(dataset), @response.body
    example.reload
    assert example.title == "A better example!", example.title
  end

  test "should update the example and redirect to a analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:two)
    example = examples(:two)
    patch :update, params: { analysis_id: analysis.id, id: example.id,
      example: { title: "A better example!" } }
    assert_redirected_to analysis_path(analysis), @response.body
    example.reload
    assert example.title == "A better example!", example.title
  end

  test "should update the example and redirect to the example page" do
    log_in_as users(:foo)
    analysis = analyses(:two)
    example = examples(:two)
    patch :update, params: { id: example.id,
      example: { title: "A better example!" } }
    assert_redirected_to example_path(example), @response.body
    example.reload
    assert example.title == "A better example!", example.title
  end

  ##############################################################################

  ##############################################################################
  ## Test deleting an example.

  test "should delete the example and redirect to a the examples index" do
    log_in_as users(:foo)
    dataset = datasets(:two)
    example = examples(:two)
    assert_difference "dataset.examples.size", -1, "Example not deleted" do
      delete :destroy, params: { id: example.id }
      assert_redirected_to examples_path, @response.body
      assert Example.find_by(id: example.id).nil?
      dataset.reload
    end
  end


  ##############################################################################



end