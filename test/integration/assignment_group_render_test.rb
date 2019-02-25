require 'test_helper'
require 'erb'
class AssignmentGroupRenderTest < ActionDispatch::IntegrationTest


  ## Tests for show.
  test "should display assignment group page that exists without being logged in" do 

    assignment_group = assignment_groups(:one)

    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
    assert_select ".name-text", assignment_group.name
    assert_select ".author", assignment_group.authors.first.full_name
    assert_select ".summary", assignment_group.summary
    assert_select ".description", assignment_group.description

    assignment_group.assignments.each do |assignment|
      assert_select "a[href=?]",show_assignment_path(assignment), count: 1
    end

    assert_select "a[href=?]", edit_assignment_group_path(assignment_group.id), count: 0
    assert_select "a[href=?][data-method=delete]", assignment_group_path(assignment_group.id), 
      count: 0
  end

  test "should display edit option on an assignment group page when logged in" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)

    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
    assert_select ".name-text", assignment_group.name
    assert_select ".author", assignment_group.authors.first.full_name
    assert_select ".summary", assignment_group.summary
    assert_select ".description", assignment_group.description

    assignment_group.assignments.each do |assignment|
      assert_select "a[href=?]", show_assignment_path(assignment), count: 1
    end

    assert_select "a[href=?]", edit_assignment_group_path(assignment_group.id), count: 1
    assert_select "a[href=?][data-method=delete]", assignment_group_path(assignment_group.id), 
      count: 1
  end

  test "should display a 404 page if id isn't valid" do 
    response = get assignment_group_path(-1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  ## Tests for index.
  test "should display all assignment group entries" do 
    assignment_groups = AssignmentGroup.all

    get assignment_groups_path
    assert_template "assignment_groups/index"

    assert_select ".assignment_group.index-entry", count: assignment_groups.size

    assignment_groups.each do |assignment_group|
      assert_select "div", "data-assignment-group-id" => assignment_group.id do
        assert_select ".name", assignment_group.name
        assert_select ".summary", assignment_group.summary
      end
    end
  end


  ## Navigate from the home page to the assignment group index, then visit a 
  ## specific assignment group page.
  test "should be able to navigate to assignment page from home page" do 
    assignment_group = assignment_groups(:two)

    get root_url
    assert_select "a", href: assignment_groups_path

    ## "Click" on the link.
    get assignment_groups_path
    assert_template "assignment_groups/index"
    assert_select "a", href: assignment_group_path(assignment_group.id)

    ## "Click" on the assignment page link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
  end


  ## Navigate from the home page to the assignment group index, then visit a 
  ## specific assignment_group group page, edit it, and submit the changes.
  test "should be able to navigate to assignment group page and edit from home page" do 
    log_in_as users(:foo)

    assignment_group = assignment_groups(:two)

    get root_url
    assert_select "a", href: assignment_groups_path

    ## "Click" on the link.
    get assignment_groups_path
    assert_template "assignment_groups/index"
    assert_select "a", href: assignment_group_path(assignment_group.id)

    ## "Click" on the assignment_group page link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
    assert_select "a[href=?]", edit_assignment_group_path(assignment_group.id), count: 1

    ## "Click" the edit button.
    get edit_assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/edit"

    ## Simulate submitting the changes.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch assignment_group_path(assignment_group.id)+'.json', params: {assignment_group: {
      name: "A VERY NEW NAME!"
    }}
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_group_path(assignment_group.id)
    
    get result['redirect']
    assert_template "assignment_groups/show"

    assert_select ".name-text", "A VERY NEW NAME!"
  end




  ## From the homepage, create a new assignment grou ppage and navigate to it 
  ## from the assignment group index.
  test "should be able to create a new assignment group page, navigate to it, "+
      "and delete it" do
    log_in_as users(:foo)

    assignment_group_name = "MY ASSIGNMENT"
    assignment_group_description = "YABBA DABBA DOO"
    assignment_group_summary = "A ASSIGNMENT SUMMARY"
    assignment_group_author = users(:foo).id.to_s

    get root_url
    assert_select "a", href: new_assignment_group_path

    ## "Click" on the link.
    get new_assignment_group_path
    assert_template "assignment_groups/new"

    ## Simulate submitting the page info.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post assignment_groups_path+'.json', params: {assignment_group: {
      authors: assignment_group_author, name: assignment_group_name,  
      summary: assignment_group_summary, description: assignment_group_description
    }}
    assignment_group = AssignmentGroup.last
    assert assignment_group.name == assignment_group_name
    assert assignment_group.summary == assignment_group_summary
    assert assignment_group.description == assignment_group_description
    result = JSON.parse(@response.body)
    assert result['success']
    get result['redirect']
    assert_template "assignment_groups/show"
    assert_select ".name-text", assignment_group.name
    assert_select "a", href: assignment_groups_path

    ## "Click" on the AssignmentGroup link.
    get assignment_groups_path
    assert_template "assignment_groups/index"
    assert_select "a", href: assignment_group_path(assignment_group.id)

    ## "Click" on the assignment_group page link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"

    ## Delete the page.
    assert_select "a[href=?][data-method=delete]", assignment_group_path(assignment_group.id), 
      count: 1
    delete assignment_group_path(assignment_group.id)
    follow_redirect!
    assert_template 'assignment_groups/index'

    ## "Click" on the Assignment link.
    get assignment_groups_path
    assert_template "assignment_groups/index"

    ## Confirm that the deleted assignment_group page is not there.
    assert_select "a[href=?]", assignment_group_path(assignment_group.id), count: 0

  end


end