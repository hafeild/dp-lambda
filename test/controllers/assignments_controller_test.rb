require 'test_helper'

class AssignmentsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating a page without being logging in" do
    #log_in_as users(:foo)
    assert_no_difference 'Assignment.count', "Assignment page created" do
      reponse = post :create, params: { assignment: { 
        author: "x", name: "x", summary: "x", description: "x" } }
      assert_redirected_to login_path, response.body
    end
  end

  test "should create a assignment page as a logged in user" do
    log_in_as users(:foo)
    assert_difference 'Assignment.count', 1, "Assignment page not created" do
      response = post :create, params: { assignment: { 
        author: "x", name: "x", summary: "x", description: "x" } }
      assert_redirected_to assignment_path(Assignment.last.id), response.body
    end
  end

  test "should break if don't include any of: author, name, summary, or description" do
    log_in_as users(:foo)

    ## Exclude name.
    assert_no_difference 'Assignment.count', 
        "Excluding name should not have worked" do
      response = post :create, params: { assignment: { 
        author: "x", summary: "x", description: "x" } }
      assert_redirected_to new_assignment_path, response.body
    end

    ## Exclude summary.
    assert_no_difference 'Assignment.count', 
        "Excluding summary should not have worked" do
      response = post :create, params: { assignment: { 
        author: "x", name: "x", description: "x" } }
      assert_redirected_to new_assignment_path, response.body
    end

    ## Exclude description.
    assert_no_difference 'Assignment.count', 
        "Excluding description should not have worked" do
      response = post :create, params: { assignment: { 
        author: "x", name: "x", summary: "x" } }
      assert_redirected_to new_assignment_path, response.body
    end

    ## Exclude author.
    assert_no_difference 'Assignment.count', 
        "Excluding name should not have worked" do
      response = post :create, params: { assignment: { 
        name: "x", summary: "x", description: "x" } }
      assert_redirected_to new_assignment_path, response.body
    end

  end

  ## JSON response errors.

  test "should return must be logged in json error" do
    ## Not logged in.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create, format: :json, params: { assignment: { 
        author: "x", name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] = "You must be logged in to modify content."
  end

  test "should return success json on basic create" do
    ## Logged in, successful create.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { assignment: { 
      author: "x", name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['redirect'] == assignment_path(Assignment.last.id), @response.body
  end

  test "should return missing params json error message" do
    ## Missing required field.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { assignment: { 
        name: "x", summary: ""   } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error']=="You must provide an author, name, summary, and description."
  end

  test "should return required params not supplied json error" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "Required parameters not supplied."
  end

  test "should return saving assignment json error" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {assignment: { 
      author: "x", name: assignments(:one).name, summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error saving the assignment entry."
  end

  ## End create tests
  ##############################################################################


  ##############################################################################
  ## Update tests.

  test "shouldn't update assignment entry when not logged in" do 
    assignment = assignments(:one)
    assignment_name = "MY ANALYSIS"
    assignment_description = "YABBA DABBA DOO"
    assignment_summary = "A ANALYSIS SUMMARY"

    patch :update, params: { id:assignment.id,
      assignment: {name: assignment_name, summary: assignment_summary,
        description: assignment_description}}

    assignment.reload
    assert_not assignment.name == assignment_name
    assert_not assignment.summary == assignment_summary
    assert_not assignment.description == assignment_description
  end

  test "should update assignment entry when logged in" do 
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_name = "MY ANALYSIS"
    assignment_description = "YABBA DABBA DOO"
    assignment_summary = "A ANALYSIS SUMMARY"

    patch :update, params: { id:assignment.id,
      assignment: {name: assignment_name, summary: assignment_summary,
        description: assignment_description}}

    assignment.reload
    assert assignment.name == assignment_name
    assert assignment.summary == assignment_summary
    assert assignment.description == assignment_description
  end

  test "shouldn't update assignment entry with a non-unique name" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_name = assignments(:two).name
    assignment_description = "YABBA DABBA DOO"
    assignment_summary = "A ANALYSIS SUMMARY"

    patch :update, params: { id:assignment.id,
      assignment: {name: assignment_name, summary: assignment_summary,
        description: assignment_description}}

    assignment.reload
    assert_not assignment.name == assignment_name, "#{assignment.name} | #{assignment_name}"
    assert_not assignment.summary == assignment_summary, assignment.summary
    assert_not assignment.description == assignment_description, assignment.description
  end


  ## JSON response on update tests.

  test "should return unknown assignment json error on update" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    patch :update, format: :json, params: {id: 0, assignment: { 
      name: "x", summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "No assignment with the specified id exists."
  end

  test "should return success json message with redirect to assignment "+
      " page on update" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_name = "MY ANALYSIS"
    assignment_description = "YABBA DABBA DOO"
    assignment_summary = "A ANALYSIS SUMMARY"

    patch :update, format: :json, params: { id:assignment.id,
      assignment: {name: assignment_name, summary: assignment_summary,
        description: assignment_description}}

    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_path(assignment.id)
  end

  test "should return error updating assignment json message on update" do
    ## No assignment parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_name = assignments(:two).name
    assignment_description = "YABBA DABBA DOO"
    assignment_summary = "A ANALYSIS SUMMARY"

    patch :update, format: :json, params: { id:assignment.id,
      assignment: {name: assignment_name, summary: assignment_summary,
        description: assignment_description}}

    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error updating the assignment entry."
  end

  ## End update tests.
  ##############################################################################

  ##############################################################################
  ## Destroy tests.

  test "should destroy a assignment page and any resources unique to it" do 
    log_in_as users(:foo)
    assignment = assignments(:two)
    tag1 = tags(:two)
    tag2 = tags(:five)
    example = assignment.examples.first
    web_resource = assignment.web_resources.first

    assert_not example.nil?, assignment.examples.size

    assert_difference 'Assignment.count', -1, "Assignment page not removed" do
    assert_difference 'WebResource.count', 0, "Web resource removed" do
    assert_difference 'Example.count', 0, "Example removed" do
    assert_difference 'Tag.count', -1, "Tag not removed" do

      delete :destroy, params: {id: assignment.id}

      assert Assignment.find_by(id: assignment.id).nil?, "Assignment not removed"
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

end
