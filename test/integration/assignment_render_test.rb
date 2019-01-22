require 'test_helper'
require 'erb'
class AssignmentRenderTest < ActionDispatch::IntegrationTest


  ## Tests for show.
  test "should display assignment page that exists without being logged in" do 
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group

    get assignment_group_assignment_path(assignment_group.id, assignment.id)
    assert_template "assignment_groups/show"
    assert_select ".name-text", assignment.name
    assert_select ".author", assignment.authors.first.full_name
    assert_select ".summary", assignment.summary
    assert_select ".learning_curve", assignment.learning_curve
    assert_select ".instruction_hours", assignment.instruction_hours.to_s
    assert_select ".description", assignment.description

    assert_select ".instructor", assignment.instructors.first.full_name
    assert_select ".instructor", assignment.instructors[1].full_name
    assert_select ".learning_curve", assignment.learning_curve
    assert_select ".field_of_study", assignment.field_of_study
    
    assert_select ".name-text", "#{assignment.course} #{assignment.course_title}, #{assignment.semester}"

    assert_select "a[href=?]", edit_assignment_group_assignment_path(
      assignment_group.id, assignment.id), count: 0
    assert_select "a[href=?][data-method=delete]", 
      assignment_group_assignment_path(assignment_group.id, assignment.id), 
      count: 0
  end

  test "should display edit option on a assignment page when logged in" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_group = assignment.assignment_group

    get assignment_group_assignment_path(assignment_group.id, assignment.id)
    assert_template "assignment_groups/show"
    assert_select ".name-text", assignment.name
    assert_select ".author", assignment.authors.first.full_name
    assert_select ".summary", assignment.summary
    assert_select ".learning_curve", assignment.learning_curve
    assert_select ".instruction_hours", assignment.instruction_hours.to_s
    assert_select ".description", assignment.description

    assert_select ".instructor", assignment.instructors.first.full_name
    assert_select ".instructor", assignment.instructors[1].full_name
    assert_select ".learning_curve", assignment.learning_curve
    assert_select ".field_of_study", assignment.field_of_study
    
    assert_select ".name-text", "#{assignment.course} #{assignment.course_title}, #{assignment.semester}"

    assert_select "a[href=?]", edit_assignment_group_assignment_path(
      assignment_group.id, assignment.id), count: 1
    assert_select "a[href=?][data-method=delete]", 
      assignment_group_assignment_path(assignment_group.id, assignment.id), 
      count: 1
  end

  test "should display a 404 page if id isn't valid" do 
    response = get assignment_group_assignment_path(assignment_groups(:one).id, -1)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  # ## Tests for index.
  # test "should display all assignment entries" do 
  #   assignments = [assignments(:one), assignments(:two), assignments(:three), 
  #                  assignments(:four)]

  #   get assignments_path
  #   assert_template "assignments/index"

  #   assert_select ".assignment.index-entry", count: assignments.size

  #   assignments.each do |assignment|
  #     assert_select "div", "data-assignment-id" => assignment.id do
  #       assert_select ".name", assignment.name
  #       assert_select ".summary", assignment.summary
  #     end
  #   end
  # end


  ## Navigate from the home page to the assignment group index, then visit a specific
  ## assignment group page, and select an assignment.
  test "should be able to navigate to assignment page from home page" do 
    assignment = assignments(:two)
    assignment_group = assignment.assignment_group

    get root_url
    assert_select "a", href: assignment_groups_path

    ## "Click" on the link.
    get assignment_groups_path
    assert_template "assignment_groups/index"
    assert_select "a", href: assignment_group_path(assignment_group.id)

    ## "Click" on the assignment group page link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
    assert_select "a", href: assignment_group_assignment_path(assignment_group.id, assignment.id)

    ## "Click" on the assignment link.
    get assignment_group_assignment_path(assignment_group.id, assignment.id)
    assert_template "assignment_groups/show"
  end


  ## Navigate from the home page to the assignment group index, then visit a specific
  ## assignment group page, select a specific assignment page, edit it, and submit the changes.
  test "should be able to navigate to assignment page and edit from home page" do 
    log_in_as users(:foo)

    assignment = assignments(:two)
    assignment_group = assignment.assignment_group

    get root_url
    assert_select "a", href: assignment_groups_path

    ## "Click" on the link.
    get assignment_groups_path
    assert_template "assignment_groups/index"
    assert_select "a", href: assignment_group_path(assignment_group.id)

    ## "Click" on the assignment group page link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
    assert_select "a", href: assignment_group_assignment_path(assignment_group.id, assignment.id)

    ## "Click" on the assignment link.
    get assignment_group_assignment_path(assignment_group.id, assignment.id)
    assert_template "assignment_groups/show"
    assert_select "a[href=?]", edit_assignment_group_assignment_path(
      assignment_group.id, assignment.id), count: 1

    ## "Click" the edit button.
    get edit_assignment_group_assignment_path(assignment_group.id, assignment.id)
    assert_template "assignments/edit"

    ## Simulate submitting the changes.
    @request.env['CONTENT_TYPE'] = 'application/json'
    patch assignment_group_assignment_path(assignment_group.id, assignment.id)+
      '.json', params: {assignment: {
        course_title: "A VERY NEW NAME!"
    }}
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_group_assignment_path(
      assignment_group.id, assignment.id)
    
    get result['redirect']
    assert_template "assignment_groups/show"

    assert_select ".name-text", "#{assignment.course} A VERY NEW NAME!, #{assignment.semester}"

  end




  ## From the homepage, create a new assignment page and navigate to it from the
  ## assignment index.
  test "should be able to create a new assignment page, navigate to it, "+
      "and delete it" do
    log_in_as users(:foo)

    assignment_group = assignment_groups(:one)

    course_prefix = "CCC"
    course_title = "YABBA DABBA DOO"
    course_number = "174"
    semester = "Fall 2060"
    field_of_study = "CCCCCC"
    instructor = users(:bar).id.to_s
    notes = "LJSLDFJLSKJFLKSDJF"

    get root_url
    assert_select "a", href: assignment_groups_path

    ## "Click" on the link.
    get assignment_groups_path
    assert_template "assignment_groups/index"
    assert_select "a", href: assignment_group_path(assignment_group.id)

    ## "Click" on the assignment group page link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"
    assert_select "a", href: new_assignment_group_assignment_path(assignment_group.id)

    ## "Click" on the link.
    get new_assignment_group_assignment_path(assignment_group.id)
    assert_template "assignments/new"

    ## Simulate submitting the page info.
    @request.env['CONTENT_TYPE'] = 'application/json'
    post assignment_group_assignments_path+'.json', params: {
      assignment_group_id: assignment_group.id,
      assignment: {
        course_prefix: course_prefix, course_title: course_title,
        course_number: course_number, semester: semester,
        field_of_study: field_of_study, instructors: instructor,
        notes: notes
    }}

    assignment = Assignment.last
    assert assignment.course_prefix == course_prefix
    assert assignment.course_title == course_title
    assert assignment.course_number == course_number
    assert assignment.semester == semester
    assert assignment.instructors.exists?(id: users(:bar).id)
    assert assignment.notes == notes
    assert assignment.assignment_group == assignment_group

    result = JSON.parse(@response.body)
    assert result['success']
    get result['redirect']
    assert_template "assignment_groups/show"
    assert_select ".name-text", assignment.name
    assert_select "a", href: assignment_group_assignments_path(assignment_group.id)

    ## Delete the page.
    assert_select "a[href=?][data-method=delete]", 
      assignment_group_assignment_path(assignment_group.id, assignment.id), 
      count: 1
    delete assignment_group_assignment_path(assignment_group.id, assignment.id)
    follow_redirect!
    assert_template 'assignment_groups/show'

    ## "Click" on the Assignment link.
    get assignment_group_path(assignment_group.id)
    assert_template "assignment_groups/show"

    ## Confirm that the deleted assignment page is not there.
    assert_select "a[href=?]", assignment_group_assignment_path(
      assignment_group.id, assignment.id), count: 0

  end


end