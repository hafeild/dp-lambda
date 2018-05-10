require 'test_helper'
require 'erb'
class AssignmentResultRenderTest < ActionDispatch::IntegrationTest

  test "view an assignment result via an assignment page" do 
    assignment = assignments(:one)
    assignment_result = assignment_results(:one)

    ## Go to assignment page.
    get assignment_path(assignment)
    assert_template "assignments/show"
    check_for_result_on_assignment_page(assignment_result, 0)
    assert_select "a[href=?]", 
      new_assignment_assignment_result_path(assignment), count: 0

    ## Go to result page.
    get assignment_result_path(assignment_result)
    check_result_page_fields(assignment_result, assignment)
    assert_select "a[href=?]", 
      edit_assignment_result_path(assignment_result), count: 0
  end

  test "view an assignment result via an assignment page while logged in" do 
    log_in_as users(:foo)

    assignment = assignments(:one)
    assignment_result = assignment_results(:one)

    ## Go to assignment page.
    get assignment_path(assignment)
    assert_template "assignments/show"
    check_for_result_on_assignment_page(assignment_result, 1)
    assert_select "a[href=?]", 
      new_assignment_assignment_result_path(assignment), count: 1

    ## Go to result page.
    get assignment_result_path(assignment_result)
    check_result_page_fields(assignment_result, assignment)
    assert_select "a[href=?]", 
      edit_assignment_result_path(assignment_result), count: 1
  end

  test "add a new assignment result and then edit it" do 
    log_in_as users(:foo)

    assignment = assignments(:one)
    assignment_result = assignment_results(:one)

    ## Go to assignment page.
    get assignment_path(assignment)
    assert_template "assignments/show"
    check_for_result_on_assignment_page(assignment_result, 1)
    assert_select "a[href=?]", 
      new_assignment_assignment_result_path(assignment), count: 1

    ## "click" on "Add result"
    get new_assignment_assignment_result_path(assignment, assignment_result)
    assert_template "assignment_results/new"
    [:instructor, :course_prefix, :course_number, :course_title, :semester,
      :field_of_study, :project_length_weeks, :students_given_assignment,
      :instruction_hours, :average_student_score].each do |field|

      assert_select "input[type=text][name=?]", "assignment_result[#{field}]"
    end
    assert_select "textarea[name=?]", "assignment_result[outcome_summary]"

    ## Create new result.
    post assignment_assignment_results_path(assignment_result), 
      params: {format: :json, assignment_result: {
       instructor: "Bob", course_title: "English Literature", 
       course_prefix: "ENG", course_number: "303", field_of_study: "English",
       semester: "Fall 2010", project_length_weeks: "3", 
       students_given_assignment: "10", instruction_hours: "9",
       average_student_score: "3", outcome_summary: "VERY GOOD!!"
    }}

    ## Make sure we go back to the assignment page and that there are now
    ## two results listed.
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_path(assignment)
    get result['redirect']
    new_assignment_result = AssignmentResult.last
    assert_template "assignments/show"
    check_for_result_on_assignment_page(assignment_results(:one), 1)
    check_for_result_on_assignment_page(new_assignment_result, 1)

    ## "Click" on the "Edit" button.
    get edit_assignment_result_path(new_assignment_result)
    assert_template "assignment_results/edit"
    [:instructor, :course_prefix, :course_number, :course_title, :semester,
      :field_of_study, :project_length_weeks, :students_given_assignment,
      :instruction_hours, :average_student_score].each do |field|

      assert_select "input[type=text][name=?]", 
        "assignment_result[#{field}]", {value: assignment_result[field] }
    end
    assert_select "textarea[name=?]", 
        "assignment_result[outcome_summary]", 
        {value: assignment_result.outcome_summary }
    patch assignment_result_path(new_assignment_result), 
      params: {format: :json, assignment_result: {instructor: "Tina"}}

    ## Make sure we go back to the assignment page and that there the changes
    ## are there.
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_path(assignment)
    get result['redirect']
    new_assignment_result.reload
    assert new_assignment_result.instructor == "Tina"
    assert_template "assignments/show"
    check_for_result_on_assignment_page(assignment_results(:one), 1)
    check_for_result_on_assignment_page(new_assignment_result, 1)
  end

  test "delete an assignment result" do
    log_in_as users(:foo)

    assignment = assignments(:one)
    assignment_result = assignment_results(:one)
    assignment_result_id = assignment_result.id

    ## "click" on "Delete result"
    delete assignment_result_path(assignment_result), params: {format: :json}
    

    ## Make sure we go back to the assignment page and that the result is no
    ## longer there.
    result = JSON.parse(@response.body)
    assert result['success']
    assert result['redirect'] == assignment_path(assignment)
    get result['redirect']
    assert_template "assignments/show"
    assert_select ".assignment-results li", count: 0
    assert_select ".assignment-results ul", 
      "There are currently no results for this assignment."

    ## Trying to go to the assignment result page should give us a 404.
    response = get assignment_result_path(assignment_result_id)
    assert response == 404
    assert_select "h1", "The page you were looking for doesn't exist."
  end


  def check_for_result_on_assignment_page(assignment_result, edit_count=0)
    assert_select ".assignment-results .resource .name", 
      "#{assignment_result.course_title} (#{assignment_result.instructor}, "+
      "#{assignment_result.semester})"
    assert_select "form[action=?]", 
      edit_assignment_result_path(assignment_result), count: edit_count
    assert_select "form[action=?] input[name=_method][value=delete]", 
      assignment_result_path(assignment_result), count: edit_count
  end

  def check_result_page_fields(assignment_result, assignment)
    assert_template "assignment_results/show"
    assert_select ".assignment a[href=?]", assignment_path(assignment) 
    assert_select ".assignment a", assignment.name
    assert_select ".instructor", assignment_result.instructor
    assert_select ".course_number", assignment_result.course_number
    assert_select ".course_prefix", assignment_result.course_prefix
    assert_select ".course_title", assignment_result.course_title
    assert_select ".semester", assignment_result.semester
    assert_select ".field_of_study", assignment_result.field_of_study
    assert_select ".project_length_weeks", 
      assignment_result.project_length_weeks.to_s
    assert_select ".students_given_assignment", 
      assignment_result.students_given_assignment.to_s
    assert_select ".instruction_hours", 
      assignment_result.instruction_hours.to_s
    assert_select ".average_student_score", 
      assignment_result.average_student_score.to_s
    assert_select ".outcome_summary", assignment_result.outcome_summary
  end


end
