require 'test_helper'
require 'erb'
class AssignmentRenderTest < ActionDispatch::IntegrationTest


  ## Tests for show.
  test "should display assignment page that exists without being logged in" do 
    assignment = assignments(:one)

    get assignment_path(assignment.id)
    assert_template "assignments/show"
    assert_select ".name", assignment.name
    assert_select ".author", assignment.author
    assert_select ".summary", assignment.summary
    assert_select ".learning_curve", assignment.learning_curve
    assert_select ".instruction_hours", assignment.instruction_hours.to_s
    assert_select ".description", assignment.description

    assert_select "a[href=?]", edit_assignment_path(assignment.id), count: 0
    assert_select "a[href=?][data-method=delete]", assignment_path(assignment.id), 
      count: 0
  end

  test "should display edit option on a assignment page when logged in" do
    log_in_as users(:foo)
    assignment = assignments(:one)

    get assignment_path(assignment.id)
    assert_template "assignments/show"
    assert_select ".name", assignment.name
    assert_select ".author", assignment.author
    assert_select ".summary", assignment.summary
    assert_select ".learning_curve", assignment.learning_curve
    assert_select ".instruction_hours", assignment.instruction_hours.to_s
    assert_select ".description", assignment.description

    assert_select "a[href=?]", edit_assignment_path(assignment.id), count: 1
    assert_select "a[href=?][data-method=delete]", assignment_path(assignment.id), 
      count: 1
  end

  test "should display a 404 page if id isn't valid" do 
    response = get assignment_path(-1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  ## Tests for index.
  test "should display all assignment entries" do 
    assignments = [assignments(:one), assignments(:two), assignments(:three), 
                   assignments(:four)]

    get assignments_path
    assert_template "assignments/index"

    assert_select ".assignment.index-entry", count: assignments.size

    assignments.each do |assignment|
      assert_select "div", "data-assignment-id" => assignment.id do
        assert_select ".name", assignment.name
        assert_select ".summary", assignment.summary
      end
    end
  end


  ## Navigate from the home page to the assignment index, then visit a specific
  ## assignment page.
  test "should be able to navigate to assignment page from home page" do 
    assignment = assignments(:two)

    get root_url
    assert_select "a", href: assignments_path

    ## "Click" on the link.
    get assignments_path
    assert_template "assignments/index"
    assert_select "a", href: assignment_path(assignment.id)

    ## "Click" on the assignment page link.
    get assignment_path(assignment.id)
    assert_template "assignments/show"
  end


  ## Navigate from the home page to the assignment index, then visit a specific
  ## assignment page, edit it, and submit the changes.
  test "should be able to navigate to assignment page and edit from home page" do 
    log_in_as users(:foo)

    assignment = assignments(:two)

    get root_url
    assert_select "a", href: assignments_path

    ## "Click" on the link.
    get assignments_path
    assert_template "assignments/index"
    assert_select "a", href: assignment_path(assignment.id)

    ## "Click" on the assignment page link.
    get assignment_path(assignment.id)
    assert_template "assignments/show"
    assert_select "a[href=?]", edit_assignment_path(assignment.id), count: 1

    ## "Click" the edit button.
    get edit_assignment_path(assignment.id)
    assert_template "assignments/edit"

    ## Simulate submitting the changes.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch assignment_path(assignment.id)+'.json', params: {assignment: {
      name: "A VERY NEW NAME!"
    }}
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_path(assignment.id)
    
    get result['redirect']
    assert_template "assignments/show"

    assert_select ".name", "A VERY NEW NAME!"
  end




  ## From the homepage, create a new assignment page and navigate to it from the
  ## assignment index.
  test "should be able to create a new assignment page, navigate to it, "+
      "and delete it" do
    log_in_as users(:foo)

    assignment_name = "MY ASSIGNMENT"
    assignment_description = "YABBA DABBA DOO"
    assignment_summary = "A ASSIGNMENT SUMMARY"
    assignment_author = "AN AUTHOR"

    get root_url
    assert_select "a", href: new_assignment_path

    ## "Click" on the link.
    get new_assignment_path
    assert_template "assignments/new"

    ## Simulate submitting the page info.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post assignments_path+'.json', params: {assignment: {
      author: assignment_author, name: assignment_name,  
      summary: assignment_summary, description: assignment_description
    }}
    assignment = Assignment.last
    assert assignment.name == assignment_name
    assert assignment.summary == assignment_summary
    assert assignment.description == assignment_description
    result = JSON.parse(@response.body)
    assert result['success']
    get result['redirect']
    assert_template "assignments/show"
    assert_select ".name", assignment.name
    assert_select "a", href: assignments_path

    ## "Click" on the Assignment link.
    get assignments_path
    assert_template "assignments/index"
    assert_select "a", href: assignment_path(assignment.id)

    ## "Click" on the assignment page link.
    get assignment_path(assignment.id)
    assert_template "assignments/show"

    ## Delete the page.
    assert_select "a[href=?][data-method=delete]", assignment_path(assignment.id), 
      count: 1
    delete assignment_path(assignment.id)
    follow_redirect!
    assert_template 'assignments/index'

    ## "Click" on the Assignment link.
    get assignments_path
    assert_template "assignments/index"

    ## Confirm that the deleted assignment page is not there.
    assert_select "a[href=?]", assignment_path(assignment.id), count: 0

  end


end