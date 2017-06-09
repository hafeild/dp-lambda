require 'test_helper'

class SoftwareControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating a page without being logging in" do
    #log_in_as users(:foo)
    assert_no_difference 'Software.count', "Software page created" do
      reponse = post :create, params: { software: { 
        name: "x", summary: "x", description: "x" } }
      assert_redirected_to login_path, response.body
    end
  end

  test "should create a software page as a logged in user" do
    log_in_as users(:foo)
    assert_difference 'Software.count', 1, "Software page not created" do
      response = post :create, params: { software: { 
        name: "x", summary: "x", description: "x" } }
      assert_redirected_to software_path(Software.last.id), response.body
    end
  end

  test "should break if don't include any of: name, summary, or description" do
    log_in_as users(:foo)

    ## Exclude name.
    assert_no_difference 'Software.count', 
        "Excluding name should not have worked" do
      response = post :create, params: { software: { 
        summary: "x", description: "x" } }
      assert_redirected_to new_software_path, response.body
    end

    ## Exclude summary.
    assert_no_difference 'Software.count', 
        "Excluding summary should not have worked" do
      response = post :create, params: { software: { 
        name: "x", description: "x" } }
      assert_redirected_to new_software_path, response.body
    end

    ## Exclude description.
    assert_no_difference 'Software.count', 
        "Excluding description should not have worked" do
      response = post :create, params: { software: { 
        name: "x", summary: "x" } }
      assert_redirected_to new_software_path, response.body
    end
  end

  ## JSON response errors.

  test "should return must be logged in json error" do
    ## Not logged in.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post :create, format: :json, params: { software: { 
        name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] = "You must be logged in to modify content."
  end

  test "should return success json on basic create" do
    ## Logged in, successful create.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { software: { 
      name: "x", summary: "x", description: "x" } }
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == software_path(Software.last.id)
  end

  test "should return missing params json error message" do
    ## Missing required field.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: { software: { 
        name: "x", summary: ""   } }
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error']=="You must provide a name, summary, and description."
  end

  test "should return required params not supplied json error" do
    ## No software parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "Required parameters not supplied."
  end

  test "should return saving software json error" do
    ## No software parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    post :create, format: :json, params: {software: { 
      name: software(:one).name, summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error saving the software entry."
  end

  ## End create tests
  ##############################################################################


  ##############################################################################
  ## Update tests.

  test "shouldn't update software entry when not logged in" do 
    software = software(:one)
    software_name = "MY SOFTWARE"
    software_description = "YABBA DABBA DOO"
    software_summary = "A SOFTWARE SUMMARY"

    patch :update, params: { id:software.id,
      software: {name: software_name, summary: software_summary,
        description: software_description}}

    software.reload
    assert_not software.name == software_name
    assert_not software.summary == software_summary
    assert_not software.description == software_description
  end

  test "should update software entry when logged in" do 
    log_in_as users(:foo)
    software = software(:one)
    software_name = "MY SOFTWARE"
    software_description = "YABBA DABBA DOO"
    software_summary = "A SOFTWARE SUMMARY"

    patch :update, params: { id:software.id,
      software: {name: software_name, summary: software_summary,
        description: software_description}}

    software.reload
    assert software.name == software_name
    assert software.summary == software_summary
    assert software.description == software_description
  end

  test "shouldn't update software entry with a non-unique name" do
    log_in_as users(:foo)
    software = software(:one)
    software_name = software(:two).name
    software_description = "YABBA DABBA DOO"
    software_summary = "A SOFTWARE SUMMARY"

    patch :update, params: { id:software.id,
      software: {name: software_name, summary: software_summary,
        description: software_description}}

    software.reload
    assert_not software.name == software_name, "#{software.name} | #{software_name}"
    assert_not software.summary == software_summary, software.summary
    assert_not software.description == software_description, software.description
  end


  ## JSON response on update tests.

  test "should return unknown software json error on update" do
    ## No software parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    patch :update, format: :json, params: {id: 0, software: { 
      name: "x", summary: "x", description: "x" }}
    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "No software with the specified id exists."
  end

  test "should return success json message with redirect to software "+
      " page on update" do
    ## No software parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    software = software(:one)
    software_name = "MY SOFTWARE"
    software_description = "YABBA DABBA DOO"
    software_summary = "A SOFTWARE SUMMARY"

    patch :update, format: :json, params: { id:software.id,
      software: {name: software_name, summary: software_summary,
        description: software_description}}

    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == software_path(software.id)
  end

  test "should return error updating software json message on update" do
    ## No software parameter.
    @request.env['CONTENT_TYPE'] = 'application/json'
    log_in_as users(:foo)
    software = software(:one)
    software_name = software(:two).name
    software_description = "YABBA DABBA DOO"
    software_summary = "A SOFTWARE SUMMARY"

    patch :update, format: :json, params: { id:software.id,
      software: {name: software_name, summary: software_summary,
        description: software_description}}

    result = JSON.parse(@response.body)
    assert_not result['success']
    assert result['error'] == "There was an error updating the software entry."
  end

  ## End update tests.
  ##############################################################################

  ##############################################################################
  ## Destroy tests.

  test "should destroy a software page and any resources unique to it" do 
    log_in_as users(:foo)
    software = software(:two)
    tag = software.tags.first
    example = software.examples.first
    web_resource = software.web_resources.first

    assert_not example.nil?, software.examples.size

    assert_difference 'Software.count', -1, "Software page not removed" do
    assert_difference 'WebResource.count', -1, "Web resource not removed" do
    assert_difference 'Example.count', -1, "Example not removed" do
    assert_difference 'Tag.count', -1, "Tag not removed" do

      delete :destroy, params: {id: software.id}

      assert Software.find_by(id: software.id).nil?, "Software not removed"
      assert Tag.find_by(id: tag.id).nil?, "Tag not removed"
      assert Example.find_by(id: example.id).nil?, "Example not removed"
      assert WebResource.find_by(id: web_resource.id).nil?, 
        "Web resource not removed"

    end
    end
    end
    end

  end

  ## End destroy tests.
  ##############################################################################

  ##############################################################################
  ## Connection tests.

  test "should connect an assignment to software" do
    log_in_as users(:foo)
    software = software(:one)
    assignment = assignments(:one)

    assert_difference "assignment.software.count", 1, "Software not linked" do
    assert_difference "software.assignments.count", 1, "Assignment not linked" do
      post :connect, params: {assignment_id: assignment.id, id: software.id}
      assert_redirected_to assignment_path(assignment), @response.body
      assignment.reload
      software.reload
      assert assignment.software.exists?(id: software.id), 
        "Software not in list of assignment software"
      assert software.assignments.exists?(id: assignment.id), 
        "Assignment not in list of software assignments"
    end
    end

  end

  # test "should connect a software page to a software" do
  #   log_in_as users(:foo)
  #   software = software(:one)
  #   software = software(:one)

  #   assert_difference "software.software.count", 1, "Software not linked" do
  #   assert_difference "software.software.count", 1, "Software not linked" do
  #     post :connect, params: {software_id: software.id, id: software.id}
  #     assert_redirected_to software_path(software), @response.body
  #     software.reload
  #     software.reload
  #     assert software.software.exists?(id: software.id), 
  #       "Software not in list of software software"
  #     assert software.software.exists?(id: software.id), 
  #       "Software not in list of software software"
  #   end
  #   end

  # end


  ## End connection tests.
  ##############################################################################

  ##############################################################################
  ## Removing a connection tests.

  test "should remove the connection between an assignment and software" do
    log_in_as users(:foo)
    software = software(:one)
    assignment = assignments(:two)

    assert_difference "assignment.software.count", -1, "Software not linked" do
    assert_difference "software.assignments.count", -1, "Assignment not linked" do
      delete :disconnect, params: {assignment_id: assignment.id, id: software.id}
      assert_redirected_to assignment_path(assignment), @response.body
      assignment.reload
      software.reload
      assert_not assignment.software.exists?(id: software.id), 
        "Software not removed from list of assignment software"
      assert_not software.assignments.exists?(id: assignment.id), 
        "Assignment not removed from list of software assignments"
    end
    end

  end

  ## End connection removal tests.
  ##############################################################################



end
