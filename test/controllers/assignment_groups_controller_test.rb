require 'test_helper'

class AssignmentGroupsControllerTest < ActionController::TestCase

  test "should do nothing" do
    assert true
  end

  ##############################################################################
  ## Testing create

  test "should break when creating a page without being logged in" do
    #log_in_as users(:foo)
    assert_no_difference 'AssignmentGroup.count', "AssignmentGroup page created" do
      reponse = post :create, params: { assignment_group: { 
        authors: users(:foo).id, name: "x", summary: "x", description: "x" } }
      assert_redirected_to login_path, response.body
    end
  end

  test "should create an assignment group page as a logged in user" do
    log_in_as users(:foo)
    assert_difference 'AssignmentGroup.count', 1, "AssignmentGroup page not created" do
      reponse = post :create, params: { assignment_group: { 
        authors: users(:foo).id, name: "x", summary: "x", description: "x" } }
      assert_redirected_to assignment_group_path(AssignmentGroup.last.id), 
        response.body
    end

    assignment_group = AssignmentGroup.last
    assert_not assignment_group.nil?, "Assignment group not saved."
    assert assignment_group.authors.first.id == users(:foo).id,
      "Author not saved."
    assert assignment_group.name == "x", "Name not saved."
    assert assignment_group.summary == "x", "Summary not saved."
    assert assignment_group.description == "x", "Description not saved."
  end

  test "should create an assignment group page with multiple authors" do
    log_in_as users(:foo)
    assert_difference 'AssignmentGroup.count', 1, "AssignmentGroup page created" do
      reponse = post :create, params: { assignment_group: { 
        authors: [users(:foo).id, users(:bar).id].join(","), name: "x", 
        summary: "x", description: "x" } }
      assert_redirected_to assignment_group_path(AssignmentGroup.last.id), 
        response.body
    end

    assignment_group = AssignmentGroup.last
    assert_not assignment_group.nil?, "Assignment group not saved."
    assert assignment_group.authors.exists?(id: users(:foo).id),
      "First author not saved."
    assert assignment_group.authors.exists?(id: users(:bar).id),
      "Second author not saved."
    assert assignment_group.name == "x", "Name not saved."
    assert assignment_group.summary == "x", "Summary not saved."
    assert assignment_group.description == "x", "Description not saved."
  end


  test "should break if doesn't include any of: authors, name, or summary" do
    log_in_as users(:foo)

    ## Exclude name.
    assert_no_difference 'AssignmentGroup.count', 
        "Excluding name should not have worked" do
      response = post :create, params: { assignment_group: { 
        authors: users(:foo).id, summary: "x", description: "x" } }
      
      # assert_redirected_to new_assignment_group_path, response.body

    end

    ## Exclude summary.
    assert_no_difference 'AssignmentGroup.count', 
        "Excluding summary should not have worked" do
      response = post :create, params: { assignment_group: { 
        authors: users(:foo).id, name: "x", description: "x" } }
      # assert_redirected_to new_assignment_group_path, response.body
    end

    ## Exclude authors.
    assert_no_difference 'AssignmentGroup.count', 
        "Excluding name should not have worked" do
      response = post :create, params: { assignment_group: { 
        name: "x", summary: "x", description: "x" } }
      # assert_redirected_to new_assignment_group_path, response.body
    end

  end

  ## JSON response errors.

  test "should return must be logged in json error" do
    ## Not logged in.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create, format: :json, params: { assignment_group: { 
      authors: users(:foo).id.to_s, name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] = "You must be logged in to modify content."
  end

  test "should return success json on basic create" do
    ## Logged in, successful create.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { assignment_group: { 
      authors: users(:foo).id.to_s, name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert result['success'], @response.body
    assert result['redirect'] == assignment_group_path(AssignmentGroup.last.id), 
      @response.body
  end

  test "should return missing params json error message" do
    ## Missing required field.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { assignment_group: { 
        name: "x", summary: ""} }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "You must provide a name, summary, and at least one author.", 
      result['error']
  end

  test "should return required params not supplied json error" do
    ## No assignment_group parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "Required parameters not supplied.", 
      result['error']
  end

  test "should return saving assignment json error" do
    ## Duplicate name.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {assignment_group: { 
      authors: users(:foo).id.to_s, name: assignment_groups(:one).name, 
      summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error saving the assignment group entry: Validation failed: Name has already been taken",
      result['error']
  end

  ## End create tests
  ##############################################################################


  ##############################################################################
  ## Update tests.

  test "shouldn't update assignment group entry when not logged in" do 
    assignment_group = assignment_groups(:one)
    name = "MY ANALYSIS"
    description = "YABBA DABBA DOO"
    summary = "AN ASSIGNMENT GROUP SUMMARY"

    patch :update, params: { id:assignment_group.id,
      assignment_group: {name: name, summary: summary,
        description: description}}

    assignment_group.reload
    assert_not assignment_group.name == name
    assert_not assignment_group.summary == summary
    assert_not assignment_group.description == description
  end

  test "should update assignment entry when logged in" do 
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    name = "MY ANALYSIS"
    description = "YABBA DABBA DOO"
    summary = "AN ASSIGNMENT GROUP SUMMARY"

    patch :update, params: { id:assignment_group.id,
      assignment_group: {name: name, summary: summary,
        description: description, authors: users(:bar).id}}

    assignment_group.reload
    assert assignment_group.name == name, assignment_group.name
    assert assignment_group.summary == summary, assignment_group.summary
    assert assignment_group.description == description, assignment_group.description
    assert assignment_group.authors.size == 1, assignment_group.authors.size
    assert assignment_group.authors.first.id == users(:bar).id

  end

  test "shouldn't update assignment entry with empty authors field" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    name = "MY ANALYSIS"
    description = "YABBA DABBA DOO"
    summary = "AN ASSIGNMENT GROUP SUMMARY"

    patch :update, params: { id:assignment_group.id,
      assignment_group: {name: name, summary: summary,
        description: description, authors: ""}}

    assignment_group.reload
    assert_not assignment_group.name == name, "Name changed."
    assert_not assignment_group.summary == summary, "Summary changed."
    assert_not assignment_group.description == description, "Description changed."
    assert_not assignment_group.authors.size == 0, assignment_group.authors.size
    assert assignment_group.authors.first.id == users(:foo).id, assignment_group.authors.first.username
  end

  test "shouldn't update assignment entry with a non-unique name" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    name = assignment_groups(:two).name
    description = "YABBA DABBA DOO"
    summary = "AN ASSIGNMENT GROUP SUMMARY"

    patch :update, params: { id:assignment_group.id,
      assignment_group: {name: name, summary: summary,
        description: description}}

    assignment_group.reload
    assert_not assignment_group.name == name
    assert_not assignment_group.summary == summary
    assert_not assignment_group.description == description
  end

  ## JSON response on update tests.

  test "should return unknown assignment json error on update" do
    ## Bad id.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    patch :update, format: :json, params: {id: 0, assignment_group: { 
      name: users(:foo).id.to_s, summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success'], "Shouldn't have succeeded."
    assert result['error'] == "No assignment group with the specified id exists.",
      result['error']
  end

  test "should return success json message with redirect to assignment "+
      " page on update" do
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    name = "MY ANALYSIS"
    description = "YABBA DABBA DOO"
    summary = "AN ASSIGNMENT GROUP SUMMARY"

    patch :update, format: :json, params: { id:assignment_group.id,
    assignment_group: {name: name, summary: summary,
        description: description}}

    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_group_path(assignment_group.id),
        result['redirect']
  end

  test "should return json error updating assignment with non-unique name" do
    ## Duplicate name.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    name = assignment_groups(:two).name
    description = "YABBA DABBA DOO"
    summary = "AN ASSIGNMENT GROUP SUMMARY"

    patch :update, format: :json, params: { id:assignment_group.id,
      assignment_group: {name: name, summary: summary,
        description: description}}

    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error updating the assignment group entry."
  end

  ## End update tests.
  ##############################################################################

  ##############################################################################
  ## Destroy tests.

  test "should destroy a assignment group page and any resources unique to it" do 
    log_in_as users(:foo)
    assignment_group = assignment_groups(:three)
    multiTag1 = tags(:multiTag1)
    multiTag2 = tags(:multiTag2)
    soloTag_AssignmentGroupThree = tags(:soloTag_AssignmentGroupThree)
    soloWebResource_AssignmentGroupThree = web_resources(:soloWebResource_AssignmentGroupThree)
    soloWebResource_AssignmentSix = web_resources(:soloWebResource_AssignmentSix)
    assignment = assignments(:six)

    ## Unique to the assignment.
    soloTag_AssignmentSix = tags(:soloTag_AssignmentSix)
    mutliWebResource2 = web_resources(:mutliWebResource2)


    assert_difference 'AssignmentGroup.count', -1, "AssignmentGroup page not removed" do
    assert_difference 'Assignment.count', -1, "Assignment page not removed" do
    assert_difference 'WebResource.count', -2, "Web resource removed" do
    assert_difference 'Tag.count', -2, "Tag not removed" do

      delete :destroy, params: {id: assignment_group.id}, format: :json

      assert AssignmentGroup.find_by(id: assignment_group.id).nil?, 
        @response.body #{}"Assignment not removed"

      assert Assignment.find_by(id: assignment.id).nil?,
        "Assignment not removed"

      assert_not Tag.find_by(id: multiTag1.id).nil?, "Tag one removed"
      assert_not Tag.find_by(id: multiTag2.id).nil?, "Tag two removed"
      assert Tag.find_by(id: soloTag_AssignmentGroupThree.id).nil?, "Tag not removed"
      assert Tag.find_by(id: soloTag_AssignmentSix.id).nil?, "Tag not removed"

      assert_not WebResource.find_by(id: mutliWebResource2.id).nil?, 
        "Web resource removed"
      assert WebResource.find_by(id: soloWebResource_AssignmentGroupThree.id).nil?, 
        "Web resource not removed"
      assert WebResource.find_by(id: soloWebResource_AssignmentSix.id).nil?, 
        "Web resource not removed"

    end
    end
    end
    end

  end

  ## End destroy tests.
  ##############################################################################

end
