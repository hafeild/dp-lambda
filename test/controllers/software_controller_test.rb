require 'test_helper'

class SoftwareControllerTest < ActionController::TestCase
  test "should break when creating a page without being logging in" do
    #log_in_as users(:foo)
    assert_no_difference 'Software.count', "Software page created" do
      post :create, params: { software: { 
        name: "x", summary: "x", description: "x" } }
      assert_redirected_to root_url
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
      assert_redirected_to new_software_path
    end

    ## Exclude summary.
    assert_no_difference 'Software.count', 
        "Excluding summary should not have worked" do
      response = post :create, params: { software: { 
        name: "x", description: "x" } }
      assert_redirected_to new_software_path
    end

    ## Exclude description.
    assert_no_difference 'Software.count', 
        "Excluding description should not have worked" do
      response = post :create, params: { software: { 
        name: "x", summary: "x" } }
      assert_redirected_to new_software_path
    end
  end


  test "should create a software page with a new example" do
    log_in_as users(:foo)
    assert_difference 'Software.count', 1, "Software page not created" do
      assert_difference 'Example.count', 1, "Example not created" do
        response = post :create, params: { software: { 
          name: "x", summary: "x", description: "x",
          examples: [{title: "x", description: "x"}] } }  
        assert_redirected_to software_path(Software.last.id), response.body
      end
    end
  end


  test "should create a software page with an existing example" do
    log_in_as users(:foo)
    example = examples(:one)
    assert_difference 'Software.count', 1, "Software page not created" do
      assert_difference 'Example.count', 0, "Web resource not created" do
        response = post :create, params: { software: { 
          name: "x", summary: "x", description: "x",
          examples: [{id: example.id, title: "ABC"}] } }  
        assert_redirected_to software_path(Software.last.id), response.body
        assert Software.last.examples.first.id == example.id
        assert Example.find_by(id: example.id).title == "ABC"
      end
    end
  end



  test "should create a software page with a new web resource" do
    log_in_as users(:foo)
    assert_difference 'Software.count', 1, "Software page not created" do
      assert_difference 'WebResource.count', 1, "Example not created" do
        response = post :create, params: { software: { 
          name: "x", summary: "x", description: "x",
          web_resources: [{url: "x", description: "x"}] } }  
        assert_redirected_to software_path(Software.last.id), response.body
      end
    end
  end


  test "should create a software page with an existing web resource" do
    log_in_as users(:foo)
    resource = web_resources(:one)
    assert_difference 'Software.count', 1, "Software page not created" do
      assert_difference 'WebResource.count', 0, "Web resource created" do
        response = post :create, params: { software: { 
          name: "x", summary: "x", description: "x",
          web_resources: [{id: resource.id, url: "www.yahoo.com"}] } }  
        assert_redirected_to software_path(Software.last.id), response.body
        assert Software.last.web_resources.first.id == resource.id
        assert WebResource.find_by(id: resource.id).url == "www.yahoo.com"
      end
    end
  end


    test "should create a software page with a new tag" do
    log_in_as users(:foo)
    assert_difference 'Software.count', 1, "Software page not created" do
      assert_difference 'Tag.count', 1, "Tag not created" do
        response = post :create, params: { software: { 
          name: "x", summary: "x", description: "x",
          tags: ["a new tag"] } }  
        assert_redirected_to software_path(Software.last.id), response.body
      end
    end
  end


  test "should create a software page with an existing tag" do
    log_in_as users(:foo)
    tag = tags(:one)
    assert_difference 'Software.count', 1, "Software page not created" do
      assert_difference 'Tag.count', 0, "Tag created" do
        response = post :create, params: { software: { 
          name: "x", summary: "x", description: "x",
          tags: [tag.text] } }  
        assert_redirected_to software_path(Software.last.id), response.body
        assert Software.last.tags.first.id == tag.id
      end
    end
  end


  test "should create a software page with several examples, resources, and tags" do
    log_in_as users(:foo)
    tag = tags(:one)
    resource = web_resources(:one)
    example = examples(:one)

    assert_difference 'Software.count', 1, "Software page not created" do
    assert_difference 'WebResource.count', 2 do
    assert_difference 'Example.count', 1 do
    assert_difference 'Tag.count', 2 do
      @request.env['CONTENT_TYPE'] = 'application/json'
      response = post :create, params: { software: { 
        name: "x", summary: "x", description: "x",
        tags: [tag.text, "hi", "hello"],
        examples: [
          {id: example.id, title: "bye"}, 
          {title: "hi", description: "xyz"}
        ],
        web_resources: [
          {id: resource.id}, 
          {url: "ack", description: "xyz"},
          {url: "abc", description: "wow"}
        ] } }  
      assert_redirected_to software_path(Software.last.id), response.body
      assert Software.last.tags.size == 3, "Tags: #{Software.last.tags.size}"
      assert Software.last.examples.size == 2, 
        "Examples: #{Software.last.examples.size}"
      assert Software.last.web_resources.size == 3, 
        "Web Res.: #{Software.last.examples.size}"
    end
    end
    end
    end
  end


end
