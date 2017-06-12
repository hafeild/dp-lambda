require "test_helper"

class AssignmentResultsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should break when creating an assignment result without being logging in" do
    assignment = assignments(:one)
    assert_no_difference "AssignmentResult.count", "AssignmentResult created" do
      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to login_path, @response.body
    end
  end

  test "should create assignment result and link to assignment page" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assert_difference "assignment.assignment_results.count", 1, "AssignmentResult not added to assignment" do
    assert_difference "AssignmentResult.count", 1, "AssignmentResult not created" do
      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to assignment_path(assignment), @response.body

      assignment.reload
      assert assignment.assignment_results.exists?(id: AssignmentResult.last.id)
    end
    end
  end

  test "should break when creating an assignment result without required fields" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assert_no_difference "AssignmentResult.count", "AssignmentResult created" do

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body
    end
  end

  test "should break when creating an assignment result with a too long instructor name" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assert_no_difference "AssignmentResult.count", "AssignmentResult created" do
      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x"*201, course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body
    end
  end

  test "should break when creating an assignment result with a too long course prefix, number, or title" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assert_no_difference "AssignmentResult.count", "AssignmentResult created" do
      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x"*4, course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x"*4,
        course_title: "x", field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body

      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x"*201, field_of_study: "x", semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body
    end
  end


  test "should break when creating an assignment result with a too long field of study" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assert_no_difference "AssignmentResult.count", "AssignmentResult created" do
      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x"*201, semester: "x" } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body
    end
  end

  test "should break when creating an assignment result with a too long semester" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assert_no_difference "AssignmentResult.count", "AssignmentResult created" do
      post :create, params: { assignment_id: assignment.id, assignment_result: { 
        instructor: "x", course_prefix: "x", course_number: "x",
        course_title: "x", field_of_study: "x", semester: "x"*16 } }
      assert_redirected_to new_assignment_assignment_result_path(assignment), 
        @response.body
    end
  end

  ##############################################################################


  ##############################################################################
  ## Testing updating an assignment_result.

  test "should update the assignment_result and redirect to its assignment page" do
    log_in_as users(:foo)
    assignment_result = assignment_results(:one)
    patch :update, params: { id: assignment_result.id, assignment_result: { 
      course_title: "x", field_of_study: "x", semester: "x"} }
    assert_redirected_to assignment_path(assignment_result.assignment), 
      @response.body
    assignment_result.reload
    assert assignment_result.course_title == "x"
  end

  ##############################################################################

  ##############################################################################
  ## Testing deleting an assignment_result.

  test "should delete the assignment_result and redirect to its assignment page" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    assignment_result = assignment_results(:one)

    assert_difference "assignment.assignment_results.count", -1, "AssignmentResult not removed from assignment" do
    assert_difference "AssignmentResult.count", -1, "AssignmentResult not deleted" do
      delete :destroy, params: { id: assignment_result.id }
      assert_redirected_to assignment_path(assignment), @response.body
      assignment.reload
      assert_not assignment.assignment_results.exists?(id: AssignmentResult.last.id)
    end
    end
  end

  ##############################################################################



end