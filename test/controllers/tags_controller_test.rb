require "test_helper"

class TagsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating an tag without being logging in" do
    assert_no_difference "Tag.count", "Tag created" do
      post :create, params: { tag: { text: "x" } }
      assert_redirected_to login_path, @response.body
    end
  end

  test "should create tag and link to analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:one)
    assert_difference "Tag.count", 1, "Tag not created" do
      post :create, params: { analysis_id: analysis.id, tag: { 
        text: "X" } }
      assert_redirected_to analysis_path(analysis), @response.body
      assert Tag.find_by(text: "X").nil?, "Case not normalized"
      assert_not Tag.find_by(text: "x").nil?, "Case not normalized"
    end
  end

  test "should create tag and link to dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    assert_difference "Tag.count", 1, "Tag not created" do
      post :create, params: { dataset_id: dataset.id, tag: { 
        text: "X" } }
      assert_redirected_to dataset_path(dataset), @response.body
      assert Tag.find_by(text: "X").nil?, "Case not normalized"
      assert_not Tag.find_by(text: "x").nil?, "Case not normalized"
    end
  end

  test "should create tag and link to software page" do
    log_in_as users(:foo)
    software = software(:one)
    assert_difference "Tag.count", 1, "Tag not created" do
      post :create, params: { software_id: software.id, tag: { 
        text: "X" } }
      assert_redirected_to software_path(software), @response.body
      assert Tag.find_by(text: "X").nil?, "Case not normalized"
      assert_not Tag.find_by(text: "x").nil?, "Case not normalized"
    end
  end

  test "should create multiple tags and link them to software page" do
    log_in_as users(:foo)
    software = software(:one)
    tag = tags(:one)
    assert_difference "Tag.count", 2, "Tag not created" do
      post :create, params: { software_id: software.id, tag: { 
        text: "x, #{tag.text}, XX" } }
      assert_redirected_to software_path(software), @response.body
    end
  end


  test "should break when creating a tag with no text" do
    log_in_as users(:foo)
    software = software(:one)
    assert_no_difference "Tag.count", "Tag created" do
      post :create, params: { software_id: software.id, 
        tag: { text: "" } }
      assert_redirected_to software_path(software), @response.body

      post :create, params: { software_id: software.id }
      assert_redirected_to root_path, @response.body
    end
  end

  test "should break when creating a tag with non-unique text" do
    log_in_as users(:foo)
    software = software(:one)
    tag = tags(:one)
    assert_no_difference "Tag.count", "Tag created" do
      post :create, params: { software_id: software.id,
        tag: { text: tag.text } }
      assert_redirected_to software_path(software), @response.body
    end
  end

  test "should break when creating a tag with long text" do
    log_in_as users(:foo)
    software = software(:one)
    assert_no_difference "Tag.count", "Tag created" do
      post :create, params: { software_id: software.id,
        tag: { text: "x"*201 } }
      assert_redirected_to software_path(software), @response.body
    end
  end

  ##############################################################################


  ##############################################################################
  ## Testing making a connection between verticals to existing tags.

  test "should link tag to software page" do
    log_in_as users(:foo)
    software = software(:one)
    tag = tags(:one)
    assert_difference "software.tags.size", 1, "Tag not linked" do
      post :connect, params: { software_id: software.id, id: tag.id }
      assert_redirected_to software_path(software), @response.body
      software.reload
    end
  end

  test "should link tag to dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:one)
    tag = tags(:one)
    assert_difference "dataset.tags.size", 1, "Tag not linked" do
      post :connect, params: { dataset_id: dataset.id, id: tag.id }
      assert_redirected_to dataset_path(dataset), @response.body
      dataset.reload
    end
  end

  test "should link tag to analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:one)
    tag = tags(:one)
    assert_difference "analysis.tags.size", 1, "Tag not linked" do
      post :connect, params: { analysis_id: analysis.id, id: tag.id }
      assert_redirected_to analysis_path(analysis), @response.body
      analysis.reload
    end
  end

  ##############################################################################


  ##############################################################################
  ## Testing removing a connection between verticals and tags.

  test "should unlink tag to software page" do
    log_in_as users(:foo)
    software = software(:multiSoftware2)
    tag = software.tags.first
    assert_difference "software.tags.size", -1, "Tag not unlinked" do
      delete :disconnect, params: { software_id: software.id, id: tag.id }
      assert_redirected_to software_path(software), @response.body
      assert Tag.find_by(id: tag.id).nil?
      software.reload
    end
  end

  test "should unlink tag to dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:two)
    tag = tags(:two)
    assert_difference "dataset.tags.size", -1, "Tag not unlinked" do
      delete :disconnect, params: { dataset_id: dataset.id, id: tag.id }
      assert_redirected_to dataset_path(dataset), @response.body
      assert_not Tag.find_by(id: tag.id).nil?
      dataset.reload
    end
  end

  test "should unlink tag to analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:two)
    tag = tags(:two)
    assert_difference "analysis.tags.size", -1, "Tag not unlinked" do
      delete :disconnect, params: { analysis_id: analysis.id, id: tag.id }
      assert_redirected_to analysis_path(analysis), @response.body
      assert_not Tag.find_by(id: tag.id).nil?
      analysis.reload
    end
  end

  ##############################################################################

  ##############################################################################
  ## Testing updating an tag.

  test "should update the tag of redirect to a software page" do
    log_in_as users(:foo)
    software = software(:two)
    tag = tags(:one)
    patch :update, params: { software_id: software.id, id: tag.id,
      tag: { text: "A better tag!" } }
    assert_redirected_to software_path(software), @response.body
    tag.reload
    assert tag.text == "a better tag!"
  end

  test "should update the tag of redirect to a dataset page" do
    log_in_as users(:foo)
    dataset = datasets(:two)
    tag = tags(:one)
    patch :update, params: { dataset_id: dataset.id, id: tag.id,
      tag: { text: "A better tag!" } }
    assert_redirected_to dataset_path(dataset), @response.body
    tag.reload
    assert tag.text == "a better tag!"
  end

  test "should update the tag of redirect to a analysis page" do
    log_in_as users(:foo)
    analysis = analyses(:two)
    tag = tags(:one)
    patch :update, params: { analysis_id: analysis.id, id: tag.id,
      tag: { text: "A better tag!" } }
    assert_redirected_to analysis_path(analysis), @response.body
    assert flash.empty?, flash.to_json
    # tag.reload
    tag = Tag.find(tag.id)
    assert tag.text == "a better tag!", tag.text
  end

  ##############################################################################



end