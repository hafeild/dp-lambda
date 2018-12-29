require "test_helper"

class AssignmentsControllerTest < ActionController::TestCase

  ##############################################################################
  ## Testing create

  test "should fail when creating an assignment without being logging in" do
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "x",
          course_title: "x", field_of_study: "x", semester: "x" 
        } 
      }
      assert_redirected_to login_path, @response.body
    end
  end

  test "should create assignment result and link to assignment page" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_difference "assignment_group.assignments.count", 1, 
      "Assignment not added to assignment group" do
      assert_difference "Assignment.count", 1, "Assignment not created" do
        post :create, params: { assignment_group_id: assignment_group.id, 
          assignment: { 
            instructors: users(:foo).id, course_prefix: "x", course_number: "y",
            course_title: "z", field_of_study: "a", semester: "b" 
          } 
        }
        assignment = Assignment.last
        assert_redirected_to assignment_path(assignment), @response.body

        assignment_group.reload
        assert assignment_group.assignments.exists?(id: assignment.id)
        assert assignment.instructors.first.id == users(:foo).id
        assert assignment.course_prefix == "x"
        assert assignment.course_number == "y"
        assert assignment.course_title == "z"
        assert assignment.field_of_study == "a"
        assert assignment.semester == "b"
        assert assignment.creator.id == users(:foo).id
      end
    end
  end

  test "should break when creating an assignment result without required fields" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do

      ## Missing instructors.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing instructor not validated."

      ## Missing course_prefix.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing course_prefix not validated."

      ## Missing course_number.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing course_number not validated."

      ## Missing course_title.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing course_title not validated."

      ## Missing field_of_study.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing field_of_study not validated."

      ## Missing semester.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Missing semester not validated."
    end
  end

  test "should break when creating an assignment result with blank required fields" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do

      ## Empty instructors.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: "", course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty instructor not validated."

      ## Empty course_prefix.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty course_prefix not validated."

      ## Empty course_number.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty course_number not validated."

      ## Empty course_title.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty course_title not validated."

      ## Empty field_of_study.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty field_of_study not validated."

      ## Empty semester.
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Empty semester not validated."
    end
  end


  test "should break when creating an assignment result with a too long course prefix, number, or title" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x"*4, course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long course_prefix field not validated."

      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y"*4,
          course_title: "z", field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long course_number field not validated."

      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z"*201, field_of_study: "a", semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long course_title field not validated."
    end
  end


  test "should break when creating an assignment result with a too long field of study" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a"*201, semester: "b" 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long field_of_study field not validated."
    end
  end

  test "should break when creating an assignment result with a too long semester" do
    log_in_as users(:foo)
    assignment_group = assignment_groups(:one)
    assert_no_difference "Assignment.count", "Assignment created" do
      post :create, params: { assignment_group_id: assignment_group.id, 
        assignment: { 
          instructors: users(:foo).id, course_prefix: "x", course_number: "y",
          course_title: "z", field_of_study: "a", semester: "b"*16 
        } 
      }
      assert_redirected_to new_assignment_group_assignment_path(assignment_group), 
        "Too-long semester field not validated."
    end
  end

  ##############################################################################


  ##############################################################################
  ## Testing updating an assignment_result.

  test "should update the assignment_result and redirect to its assignment page" do
    log_in_as users(:foo)
    assignment = assignments(:one)
    patch :update, params: { id: assignment.id, 
      assignment: { 
        instructors: users(:foo).id, course_prefix: "x", course_number: "y",
        course_title: "z", field_of_study: "a", semester: "b"
      } 
    }
    assert_redirected_to assignment_path(assignment), 
      @response.body
      assignment.reload
    assert assignment.instructors.size == 1, "Instructors not updated."
    assert assignment.instructors.exists?(id: users(:foo).id),
      "Instructors not updated."
    assert users(:foo).instructed_assignments.exists?(id: assignment.id)
    assert_not users(:bar).instructed_assignments.exists?(id: assignment.id),
      "Instructors not reciprocated."
    assert assignment.course_prefix == "x", "course_prefix not updated"
    assert assignment.course_number == "y", "course_number not updated"
    assert assignment.course_title == "z", "course_title not updated"
    assert assignment.field_of_study == "a", "field_of_study not updated"
    assert assignment.semester == "b", "semester not updated"
  end

  ##############################################################################

  ##############################################################################
  ## Testing deleting an assignment_result.

  test "should delete the assignment_result and redirect to its assignment page" do
    log_in_as users(:foo)
    assignment = assignments(:six)
    assignment_group = assignment.assignment_group

    assert_difference "assignment_group.assignments.count", -1, 
      "Assignment not removed from assignment group" do
    assert_difference "Assignment.count", -1, "Assignment not deleted" do
    assert_difference "Tag.count", -1, "Solo tag not removed." do
    assert_no_difference "WebResource.count", "Multi web resource removed." do
      delete :destroy, params: { id: assignment.id }
      assert_redirected_to assignment_group_path(assignment_group), @response.body
      assignment_group.reload

      assert_not assignment_group.assignments.exists?(id: assignment.id)
    end
    end
    end
    end
  end

  ##############################################################################

  ## TODO: Add connection tests.
  ## TODO: Add test for broken connections on destroy.

end