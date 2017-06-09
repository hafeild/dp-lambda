require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating a page without being logging in" do
    #log_in_as users(:foo)
    assert_no_difference 'Dataset.count', "Dataset page created" do
      reponse = post :create, params: { dataset: { 
        name: "x", summary: "x", description: "x" } }
      assert_redirected_to login_path, response.body
    end
  end

  test "should create a dataset page as a logged in user" do
    log_in_as users(:foo)
    assert_difference 'Dataset.count', 1, "Dataset page not created" do
      response = post :create, params: { dataset: { 
        name: "x", summary: "x", description: "x" } }
      assert_redirected_to dataset_path(Dataset.last.id), response.body
    end
  end

  test "should break if don't include any of: name, summary, or description" do
    log_in_as users(:foo)

    ## Exclude name.
    assert_no_difference 'Dataset.count', 
        "Excluding name should not have worked" do
      response = post :create, params: { dataset: { 
        summary: "x", description: "x" } }
      assert_redirected_to new_dataset_path, response.body
    end

    ## Exclude summary.
    assert_no_difference 'Dataset.count', 
        "Excluding summary should not have worked" do
      response = post :create, params: { dataset: { 
        name: "x", description: "x" } }
      assert_redirected_to new_dataset_path, response.body
    end

    ## Exclude description.
    assert_no_difference 'Dataset.count', 
        "Excluding description should not have worked" do
      response = post :create, params: { dataset: { 
        name: "x", summary: "x" } }
      assert_redirected_to new_dataset_path, response.body
    end
  end

  ## JSON response errors.

  test "should return must be logged in json error" do
    ## Not logged in.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create, format: :json, params: { dataset: { 
        name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] = "You must be logged in to modify content."
  end

  test "should return success json on basic create" do
    ## Logged in, successful create.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { dataset: { 
      name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == dataset_path(Dataset.last.id)
  end

  test "should return missing params json error message" do
    ## Missing required field.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { dataset: { 
        name: "x", summary: ""   } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error']=="You must provide a name, summary, and description."
  end

  test "should return required params not supplied json error" do
    ## No dataset parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "Required parameters not supplied."
  end

  test "should return saving dataset json error" do
    ## No dataset parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {dataset: { 
      name: datasets(:one).name, summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error saving the dataset entry."
  end

  ## End create tests
  ##############################################################################


  ##############################################################################
  ## Update tests.

  test "shouldn't update dataset entry when not logged in" do 
    dataset = datasets(:one)
    dataset_name = "MY DATASET"
    dataset_description = "YABBA DABBA DOO"
    dataset_summary = "A DATASET SUMMARY"

    patch :update, params: { id:dataset.id,
      dataset: {name: dataset_name, summary: dataset_summary,
        description: dataset_description}}

    dataset.reload
    assert_not dataset.name == dataset_name
    assert_not dataset.summary == dataset_summary
    assert_not dataset.description == dataset_description
  end

  test "should update dataset entry when logged in" do 
    log_in_as users(:foo)
    dataset = datasets(:one)
    dataset_name = "MY DATASET"
    dataset_description = "YABBA DABBA DOO"
    dataset_summary = "A DATASET SUMMARY"

    patch :update, params: { id:dataset.id,
      dataset: {name: dataset_name, summary: dataset_summary,
        description: dataset_description}}

    dataset.reload
    assert dataset.name == dataset_name
    assert dataset.summary == dataset_summary
    assert dataset.description == dataset_description
  end

  test "shouldn't update dataset entry with a non-unique name" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    dataset_name = datasets(:two).name
    dataset_description = "YABBA DABBA DOO"
    dataset_summary = "A DATASET SUMMARY"

    patch :update, params: { id:dataset.id,
      dataset: {name: dataset_name, summary: dataset_summary,
        description: dataset_description}}

    dataset.reload
    assert_not dataset.name == dataset_name, "#{dataset.name} | #{dataset_name}"
    assert_not dataset.summary == dataset_summary, dataset.summary
    assert_not dataset.description == dataset_description, dataset.description
  end


  ## JSON response on update tests.

  test "should return unknown dataset json error on update" do
    ## No dataset parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    patch :update, format: :json, params: {id: 0, dataset: { 
      name: "x", summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "No dataset with the specified id exists."
  end

  test "should return success json message with redirect to dataset "+
      " page on update" do
    ## No dataset parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    dataset = datasets(:one)
    dataset_name = "MY DATASET"
    dataset_description = "YABBA DABBA DOO"
    dataset_summary = "A DATASET SUMMARY"

    patch :update, format: :json, params: { id:dataset.id,
      dataset: {name: dataset_name, summary: dataset_summary,
        description: dataset_description}}

    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == dataset_path(dataset.id)
  end

  test "should return error updating dataset json message on update" do
    ## No dataset parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    dataset = datasets(:one)
    dataset_name = datasets(:two).name
    dataset_description = "YABBA DABBA DOO"
    dataset_summary = "A DATASET SUMMARY"

    patch :update, format: :json, params: { id:dataset.id,
      dataset: {name: dataset_name, summary: dataset_summary,
        description: dataset_description}}

    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error updating the dataset entry."
  end

  ## End update tests.
  ##############################################################################

  ##############################################################################
  ## Destroy tests.

  test "should destroy a dataset page and any resources unique to it" do 
    log_in_as users(:foo)
    dataset = datasets(:two)
    tag1 = tags(:two)
    tag2 = tags(:four)
    example = dataset.examples.first
    web_resource = dataset.web_resources.first

    assert_not example.nil?, dataset.examples.size

    assert_difference 'Dataset.count', -1, "Dataset page not removed" do
    assert_difference 'WebResource.count', 0, "Web resource removed" do
    assert_difference 'Example.count', 0, "Example removed" do
    assert_difference 'Tag.count', -1, "Tag not removed" do

      delete :destroy, params: {id: dataset.id}

      assert Dataset.find_by(id: dataset.id).nil?, "Dataset not removed"
      assert_not Tag.find_by(id: tag1.id).nil?, "Tag removed"
      assert Tag.find_by(id: tag2.id).nil?, "Tag not removed"
      assert_not Example.find_by(id: example.id).nil?, "Example removed"
      assert_not WebResource.find_by(id: web_resource.id).nil?, 
        "Web resource removed"

    end
    end
    end
    end

  end

  ## End destroy tests.
  ##############################################################################


  ##############################################################################
  ## Connection tests.

  test "should connect an assignment to a dataset" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    assignment = assignments(:one)

    assert_difference "assignment.datasets.count", 1, "Dataset not linked" do
    assert_difference "dataset.assignments.count", 1, "Assignment not linked" do
      post :connect, params: {assignment_id: assignment.id, id: dataset.id}
      assert_redirected_to assignment_path(assignment), @response.body
      assignment.reload
      dataset.reload
      assert assignment.datasets.exists?(id: dataset.id), 
        "Dataset not in list of assignment datasets"
      assert dataset.assignments.exists?(id: assignment.id), 
        "Assignment not in list of dataset assignments"
    end
    end

  end

  # test "should connect a software page to a dataset" do
  #   log_in_as users(:foo)
  #   dataset = datasets(:one)
  #   software = software(:one)

  #   assert_difference "software.datasets.count", 1, "Dataset not linked" do
  #   assert_difference "dataset.software.count", 1, "Software not linked" do
  #     post :connect, params: {software_id: software.id, id: dataset.id}
  #     assert_redirected_to software_path(software), @response.body
  #     software.reload
  #     dataset.reload
  #     assert software.datasets.exists?(id: dataset.id), 
  #       "Dataset not in list of software datasets"
  #     assert dataset.software.exists?(id: software.id), 
  #       "Software not in list of dataset software"
  #   end
  #   end

  # end


  ## End connection tests.
  ##############################################################################

  ##############################################################################
  ## Removing a connection tests.

  test "should remove the connection between an assignment and dataset" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    assignment = assignments(:two)

    assert_difference "assignment.datasets.count", -1, "Dataset not linked" do
    assert_difference "dataset.assignments.count", -1, "Assignment not linked" do
      delete :disconnect, params: {assignment_id: assignment.id, id: dataset.id}
      assert_redirected_to assignment_path(assignment), @response.body
      assignment.reload
      dataset.reload
      assert_not assignment.datasets.exists?(id: dataset.id), 
        "Dataset not removed from list of assignment datasets"
      assert_not dataset.assignments.exists?(id: assignment.id), 
        "Assignment not removed from list of dataset assignments"
    end
    end

  end



  ## End connection removal tests.
  ##############################################################################


end
