require 'test_helper'
class SoftwareRenderTest < ActionDispatch::IntegrationTest


  ## Tests for show.
  test "should display software page that exists without being logged in" do 
    software = software(:one)

    get software_path(software.id)
    assert_template "software/show"
    assert_select ".name", software.name
    assert_select ".summary", software.summary
    assert_select ".description", software.description

    assert_select "a[href=?]", edit_software_path(software.id), count: 0
    assert_select "a[href=?][method=delete]", software_path(software.id), 
      count: 0
  end

  test "should display edit option on a software page when logged in" do
    log_in_as users(:foo)
    software = software(:one)

    get software_path(software.id)
    assert_template "software/show"
    assert_select ".name", software.name
    assert_select ".summary", software.summary
    assert_select ".description", software.description

    assert_select "a[href=?]", edit_software_path(software.id), count: 1
    assert_select "a[href=?][method=delete]", software_path(software.id), 
      count: 1
  end

  test "should display a 404 page if id isn't valid" do 
    response = get software_path(-1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  ## Tests for index.
  test "should display all software entries" do 
    softwares = [software(:one), software(:two)]

    get software_index_path
    assert_template "software/index"

    assert_select ".software.index-entry", count: softwares.size

    softwares.each do |software|
      assert_select "div", "data-software-id" => software.id do
        assert_select ".name", software.name
        assert_select ".summary", software.summary
      end
    end
  end


  ## Navigate from the home page to the software index, then visit a specific
  ## software page.
  test "should be able to navigate to software page from home page" do 
    software = software(:two)

    get root_url
    assert_select "a", href: software_index_path

    ## "Click" on the link.
    get software_index_path
    assert_template "software/index"
    assert_select "a", href: software_path(software.id)

    ## "Click" on the software page link.
    get software_path(software.id)
    assert_template "software/show"
  end


  ## Navigate from the home page to the software index, then visit a specific
  ## software page, edit it, and submit the changes.
  test "should be able to navigate to software page and edit from home page" do 
    log_in_as users(:foo)

    software = software(:two)

    get root_url
    assert_select "a", href: software_index_path

    ## "Click" on the link.
    get software_index_path
    assert_template "software/index"
    assert_select "a", href: software_path(software.id)

    ## "Click" on the software page link.
    get software_path(software.id)
    assert_template "software/show"
    assert_select "a[href=?]", edit_software_path(software.id), count: 1

    ## "Click" the edit button.
    get edit_software_path(software.id)
    assert_template "software/edit"

    ## Simulate submitting the changes.
    patch software_path(software.id), params: {software: {
      name: "A VERY NEW NAME!"
    }}
    assert_redirected_to software_path(software.id)
    follow_redirect!
    assert_template "software/show"
    assert_select ".name", "A VERY NEW NAME!"
  end




  ## From the homepage, create a new software page and navigate to it from the
  ## software index.
  test "should be able to create a new software page, navigate to it, "+
      "and delete it" do
    log_in_as users(:foo)

    software_name = "MY SOFTWARE"
    software_description = "YABBA DABBA DOO"
    software_summary = "A SOFTWARE SUMMARY"

    get root_url
    assert_select "a", href: new_software_path

    ## "Click" on the link.
    get new_software_path
    assert_template "software/new"

    ## Simulate submitting the page info.
    post software_index_path, params: {software: {
      name: software_name, summary: software_summary, 
      description: software_description
    }}
    software = Software.last
    assert software.name == software_name
    assert software.summary == software_summary
    assert software.description == software_description
    assert_redirected_to software_path(software.id)
    follow_redirect!
    assert_template "software/show"
    assert_select ".name", software.name
    assert_select "a", href: software_index_path

    ## "Click" on the Software link.
    get software_index_path
    assert_template "software/index"
    assert_select "a", href: software_path(software.id)

    ## "Click" on the software page link.
    get software_path(software.id)
    assert_template "software/show"

    ## Delete the page.
    assert_select "a[href=?][method=delete]", software_path(software.id), 
      count: 0
    delete software_path(software.id)
    follow_redirect!
    assert_template 'static/home'

    ## "Click" on the Software link.
    get software_index_path
    assert_template "software/index"

    ## Confirm that the deleted software page is not there.
    assert_select "a", href: software_path(software.id), count: 0

  end


end